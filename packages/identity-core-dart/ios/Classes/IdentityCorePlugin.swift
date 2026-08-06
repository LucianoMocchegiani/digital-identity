import Flutter
import Foundation
import Security

public class IdentityCorePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "identity_core_dart/hardware_kms",
            binaryMessenger: registrar.messenger()
        )
        let instance = IdentityCorePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAvailable":
            result(isAvailable())
        case "createKey":
            guard let args = call.arguments as? [String: Any],
                  let keyId = args["keyId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "keyId required", details: nil))
                return
            }
            createKey(keyId: keyId, result: result)
        case "sign":
            guard let args = call.arguments as? [String: Any],
                  let keyId = args["keyId"] as? String,
                  let payload = args["payload"] as? FlutterStandardTypedData else {
                result(FlutterError(code: "INVALID_ARGS", message: "keyId and payload required", details: nil))
                return
            }
            sign(keyId: keyId, payload: payload.data, result: result)
        case "deleteKey":
            guard let args = call.arguments as? [String: Any],
                  let keyId = args["keyId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "keyId required", details: nil))
                return
            }
            deleteKey(keyId: keyId, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func isAvailable() -> Bool {
        if #available(iOS 13.0, *) {
            return SecureEnclave.isAvailable
        }
        return false
    }

    private func createKey(keyId: String, result: @escaping FlutterResult) {
        var error: Unmanaged<CFError>?

        guard let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .privateKeyUsage,
            &error
        ) else {
            result(FlutterError(code: "CREATE_KEY_FAILED", message: error.debugDescription, details: nil))
            return
        }

        let attrs: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyId.data(using: .utf8)!,
                kSecAttrAccessControl as String: access,
            ],
        ]

        guard let privateKey = SecKeyCreateRandomKey(attrs as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey),
              let pubDer = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            result(FlutterError(code: "CREATE_KEY_FAILED", message: error.debugDescription, details: nil))
            return
        }

        // Uncompressed EC point: 0x04 || x (32) || y (32)
        let raw = pubDer as Data
        guard raw.count == 65, raw[0] == 0x04 else {
            result(FlutterError(code: "CREATE_KEY_FAILED", message: "Unexpected EC point format", details: nil))
            return
        }
        let x = base64url(raw[1...32])
        let y = base64url(raw[33...64])
        result(["x": x, "y": y])
    }

    private func sign(keyId: String, payload: Data, result: @escaping FlutterResult) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrApplicationTag as String: keyId.data(using: .utf8)!,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecReturnRef as String: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let privateKey = item else {
            result(FlutterError(code: "KEY_NOT_FOUND", message: "No key found for id: \(keyId)", details: nil))
            return
        }

        var error: Unmanaged<CFError>?
        guard let derSig = SecKeyCreateSignature(
            privateKey as! SecKey,
            .ecdsaSignatureMessageX962SHA256,
            payload as CFData,
            &error
        ) as Data? else {
            result(FlutterError(code: "SIGN_FAILED", message: error.debugDescription, details: nil))
            return
        }

        result(FlutterStandardTypedData(bytes: derToP1363(derSig)))
    }

    private func deleteKey(keyId: String, result: @escaping FlutterResult) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyId.data(using: .utf8)!,
        ]
        SecItemDelete(query as CFDictionary)
        result(nil)
    }

    // — DER → IEEE P1363 (r||s, 64 bytes) —

    private func derToP1363(_ der: Data) -> Data {
        var out = Data(count: 64)
        var pos = 2 // skip SEQUENCE header
        pos += 1   // skip INTEGER tag
        let rLen = Int(der[pos]); pos += 1
        let r = der[pos ..< pos + rLen]; pos += rLen
        pos += 1   // skip INTEGER tag
        let sLen = Int(der[pos]); pos += 1
        let s = der[pos ..< pos + sLen]

        copyInt(r, into: &out, offset: 0)
        copyInt(s, into: &out, offset: 32)
        return out
    }

    private func copyInt(_ src: Data, into dst: inout Data, offset: Int) {
        var bytes = Array(src)
        while bytes.first == 0x00 { bytes.removeFirst() }
        if bytes.count > 32 { bytes = Array(bytes.suffix(32)) }
        let start = offset + 32 - bytes.count
        dst.replaceSubrange(start ..< start + bytes.count, with: bytes)
    }

    private func base64url(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
