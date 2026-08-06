package com.phinx.identity_core_dart

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.interfaces.ECPublicKey
import java.util.Base64

class IdentityCorePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "identity_core_dart/hardware_kms")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isAvailable" -> result.success(isAvailable())
            "createKey" -> {
                val keyId = call.argument<String>("keyId") ?: return result.error("INVALID_ARGS", "keyId required", null)
                createKey(keyId, result)
            }
            "sign" -> {
                val keyId = call.argument<String>("keyId") ?: return result.error("INVALID_ARGS", "keyId required", null)
                val payload = call.argument<ByteArray>("payload") ?: return result.error("INVALID_ARGS", "payload required", null)
                sign(keyId, payload, result)
            }
            "deleteKey" -> {
                val keyId = call.argument<String>("keyId") ?: return result.error("INVALID_ARGS", "keyId required", null)
                deleteKey(keyId, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun isAvailable(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.M

    private fun createKey(keyId: String, result: Result) {
        try {
            val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
            kpg.initialize(
                KeyGenParameterSpec.Builder(
                    keyId,
                    KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY,
                )
                    .setAlgorithmParameterSpec(java.security.spec.ECGenParameterSpec("secp256r1"))
                    .setDigests(KeyProperties.DIGEST_SHA256)
                    .setUserAuthenticationRequired(false)
                    .build()
            )
            val keyPair = kpg.generateKeyPair()
            val ecPub = keyPair.public as ECPublicKey
            val w = ecPub.w
            val x = w.affineX.toByteArray().stripLeadingZero(32)
            val y = w.affineY.toByteArray().stripLeadingZero(32)

            result.success(
                mapOf(
                    "x" to Base64.getUrlEncoder().withoutPadding().encodeToString(x),
                    "y" to Base64.getUrlEncoder().withoutPadding().encodeToString(y),
                )
            )
        } catch (e: Exception) {
            result.error("CREATE_KEY_FAILED", e.message, null)
        }
    }

    private fun sign(keyId: String, payload: ByteArray, result: Result) {
        try {
            val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
            val entry = ks.getEntry(keyId, null) as? KeyStore.PrivateKeyEntry
                ?: return result.error("KEY_NOT_FOUND", "No key found for id: $keyId", null)

            val derSig = Signature.getInstance("SHA256withECDSA").run {
                initSign(entry.privateKey)
                update(payload)
                sign()
            }

            result.success(derToP1363(derSig))
        } catch (e: Exception) {
            result.error("SIGN_FAILED", e.message, null)
        }
    }

    private fun deleteKey(keyId: String, result: Result) {
        try {
            val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
            ks.deleteEntry(keyId)
            result.success(null)
        } catch (e: Exception) {
            result.error("DELETE_KEY_FAILED", e.message, null)
        }
    }

    // — DER → IEEE P1363 (r||s, 64 bytes) —

    private fun derToP1363(der: ByteArray): ByteArray {
        // DER: 0x30 <len> 0x02 <rLen> <r> 0x02 <sLen> <s>
        var pos = 2
        pos++ // skip INTEGER tag
        val rLen = der[pos++].toInt() and 0xFF
        val r = der.slice(pos until pos + rLen).toByteArray()
        pos += rLen
        pos++ // skip INTEGER tag
        val sLen = der[pos++].toInt() and 0xFF
        val s = der.slice(pos until pos + sLen).toByteArray()

        return ByteArray(64).also { out ->
            val rTrim = r.stripLeadingZero(32)
            val sTrim = s.stripLeadingZero(32)
            rTrim.copyInto(out, 32 - rTrim.size)
            sTrim.copyInto(out, 64 - sTrim.size)
        }
    }

    private fun ByteArray.stripLeadingZero(targetLen: Int): ByteArray {
        val src = if (isNotEmpty() && this[0] == 0.toByte()) drop(1).toByteArray() else this
        return if (src.size > targetLen) src.takeLast(targetLen).toByteArray() else src
    }
}
