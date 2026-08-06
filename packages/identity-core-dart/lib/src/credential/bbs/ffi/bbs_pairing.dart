import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;

/// Low-level BBS+ pairing API (MATTR `blsCreateProof` / `blsVerifyProof`).
abstract class BbsPairingApi {
  Future<Uint8List> blsCreateProof({
    required Uint8List publicKey,
    required Uint8List signature,
    required List<Uint8List> messages,
    required List<int> revealed,
    required Uint8List nonce,
  });

  Future<bool> blsVerifyProof({
    required Uint8List publicKey,
    required Uint8List proof,
    required List<Uint8List> messages,
    required Uint8List nonce,
  });
}

typedef _FreeNative = Void Function(Pointer<Uint8> ptr, Int32 len);
typedef _FreeDart = void Function(Pointer<Uint8> ptr, int len);

typedef _CreateProofNative = Int32 Function(
  Pointer<Uint8> publicKey,
  Int32 publicKeyLen,
  Pointer<Uint8> signature,
  Int32 signatureLen,
  Pointer<Pointer<Uint8>> messages,
  Pointer<Int32> messageLens,
  Int32 messageCount,
  Pointer<Uint32> revealed,
  Int32 revealedCount,
  Pointer<Uint8> nonce,
  Int32 nonceLen,
  Pointer<Pointer<Uint8>> outProof,
  Pointer<Int32> outProofLen,
  Pointer<Pointer<Uint8>> outErr,
  Pointer<Int32> outErrLen,
);
typedef _CreateProofDart = int Function(
  Pointer<Uint8> publicKey,
  int publicKeyLen,
  Pointer<Uint8> signature,
  int signatureLen,
  Pointer<Pointer<Uint8>> messages,
  Pointer<Int32> messageLens,
  int messageCount,
  Pointer<Uint32> revealed,
  int revealedCount,
  Pointer<Uint8> nonce,
  int nonceLen,
  Pointer<Pointer<Uint8>> outProof,
  Pointer<Int32> outProofLen,
  Pointer<Pointer<Uint8>> outErr,
  Pointer<Int32> outErrLen,
);

typedef _VerifyProofNative = Int32 Function(
  Pointer<Uint8> publicKey,
  Int32 publicKeyLen,
  Pointer<Uint8> proof,
  Int32 proofLen,
  Pointer<Pointer<Uint8>> messages,
  Pointer<Int32> messageLens,
  Int32 messageCount,
  Pointer<Uint8> nonce,
  Int32 nonceLen,
  Pointer<Int32> outVerified,
  Pointer<Pointer<Uint8>> outErr,
  Pointer<Int32> outErrLen,
);
typedef _VerifyProofDart = int Function(
  Pointer<Uint8> publicKey,
  int publicKeyLen,
  Pointer<Uint8> proof,
  int proofLen,
  Pointer<Pointer<Uint8>> messages,
  Pointer<Int32> messageLens,
  int messageCount,
  Pointer<Uint8> nonce,
  int nonceLen,
  Pointer<Int32> outVerified,
  Pointer<Pointer<Uint8>> outErr,
  Pointer<Int32> outErrLen,
);

/// Loads `libbbs` / `bbs.dll` and exposes MATTR-compatible pairing ops.
class FfiBbsPairingApi implements BbsPairingApi {
  FfiBbsPairingApi._(this._lib, this._free, this._createProof, this._verifyProof);

  // Retain DynamicLibrary so native symbols stay mapped for the process lifetime.
  // ignore: unused_field
  final DynamicLibrary _lib;
  final _FreeDart _free;
  final _CreateProofDart _createProof;
  final _VerifyProofDart _verifyProof;

  static FfiBbsPairingApi? _instance;

  /// Opens the native library (Android jniLibs, or [libraryPath] override for tests).
  factory FfiBbsPairingApi.open({String? libraryPath}) {
    if (_instance != null && libraryPath == null) return _instance!;
    final lib = DynamicLibrary.open(libraryPath ?? _defaultLibraryName());
    final api = FfiBbsPairingApi._(
      lib,
      lib.lookupFunction<_FreeNative, _FreeDart>('quark_bbs_free'),
      lib.lookupFunction<_CreateProofNative, _CreateProofDart>(
        'quark_bbs_bls_create_proof',
      ),
      lib.lookupFunction<_VerifyProofNative, _VerifyProofDart>(
        'quark_bbs_bls_verify_proof',
      ),
    );
    if (libraryPath == null) _instance = api;
    return api;
  }

  static String _defaultLibraryName() {
    if (Platform.isAndroid) return 'libbbs.so';
    if (Platform.isIOS || Platform.isMacOS) return 'bbs.framework/bbs';
    if (Platform.isWindows) {
      final candidates = <String>[
        p.join(Directory.current.path, 'native', 'bbs', 'target', 'release', 'bbs.dll'),
        'bbs.dll',
      ];
      for (final c in candidates) {
        if (File(c).existsSync()) return c;
      }
      return 'bbs.dll';
    }
    if (Platform.isLinux) {
      final candidates = <String>[
        p.join(Directory.current.path, 'native', 'bbs', 'target', 'release', 'libbbs.so'),
        'libbbs.so',
      ];
      for (final c in candidates) {
        if (File(c).existsSync()) return c;
      }
      return 'libbbs.so';
    }
    throw UnsupportedError('BBS FFI unsupported on ${Platform.operatingSystem}');
  }

  @override
  Future<Uint8List> blsCreateProof({
    required Uint8List publicKey,
    required Uint8List signature,
    required List<Uint8List> messages,
    required List<int> revealed,
    required Uint8List nonce,
  }) async {
    return using((arena) {
      final pk = _copyBytes(arena, publicKey);
      final sig = _copyBytes(arena, signature);
      final noncePtr = _copyBytes(arena, nonce);
      final msgPtrs = arena<Pointer<Uint8>>(messages.length);
      final msgLens = arena<Int32>(messages.length);
      for (var i = 0; i < messages.length; i++) {
        msgPtrs[i] = _copyBytes(arena, messages[i]);
        msgLens[i] = messages[i].length;
      }
      final revealedPtr = arena<Uint32>(revealed.length);
      for (var i = 0; i < revealed.length; i++) {
        revealedPtr[i] = revealed[i];
      }
      final outProof = arena<Pointer<Uint8>>();
      final outProofLen = arena<Int32>();
      final outErr = arena<Pointer<Uint8>>();
      final outErrLen = arena<Int32>();

      final rc = _createProof(
        pk,
        publicKey.length,
        sig,
        signature.length,
        msgPtrs,
        msgLens,
        messages.length,
        revealedPtr,
        revealed.length,
        noncePtr,
        nonce.length,
        outProof,
        outProofLen,
        outErr,
        outErrLen,
      );
      if (rc != 0) {
        final err = _takeError(outErr, outErrLen);
        throw StateError('quark_bbs_bls_create_proof failed: $err');
      }
      return _takeBytes(outProof.value, outProofLen.value);
    });
  }

  @override
  Future<bool> blsVerifyProof({
    required Uint8List publicKey,
    required Uint8List proof,
    required List<Uint8List> messages,
    required Uint8List nonce,
  }) async {
    return using((arena) {
      final pk = _copyBytes(arena, publicKey);
      final proofPtr = _copyBytes(arena, proof);
      final noncePtr = _copyBytes(arena, nonce);
      final msgPtrs = arena<Pointer<Uint8>>(messages.length);
      final msgLens = arena<Int32>(messages.length);
      for (var i = 0; i < messages.length; i++) {
        msgPtrs[i] = _copyBytes(arena, messages[i]);
        msgLens[i] = messages[i].length;
      }
      final outVerified = arena<Int32>();
      final outErr = arena<Pointer<Uint8>>();
      final outErrLen = arena<Int32>();

      final rc = _verifyProof(
        pk,
        publicKey.length,
        proofPtr,
        proof.length,
        msgPtrs,
        msgLens,
        messages.length,
        noncePtr,
        nonce.length,
        outVerified,
        outErr,
        outErrLen,
      );
      if (rc != 0) {
        final err = _takeError(outErr, outErrLen);
        throw StateError('quark_bbs_bls_verify_proof failed: $err');
      }
      return outVerified.value == 1;
    });
  }

  Pointer<Uint8> _copyBytes(Allocator arena, Uint8List bytes) {
    final ptr = arena<Uint8>(bytes.length);
    final list = ptr.asTypedList(bytes.length);
    list.setAll(0, bytes);
    return ptr;
  }

  Uint8List _takeBytes(Pointer<Uint8> ptr, int len) {
    if (ptr == nullptr || len <= 0) return Uint8List(0);
    final copy = Uint8List.fromList(ptr.asTypedList(len));
    _free(ptr, len);
    return copy;
  }

  String _takeError(Pointer<Pointer<Uint8>> outErr, Pointer<Int32> outErrLen) {
    final ptr = outErr.value;
    final len = outErrLen.value;
    if (ptr == nullptr || len <= 0) return 'unknown error';
    final msg = utf8.decode(ptr.asTypedList(len));
    _free(ptr, len);
    return msg;
  }
}
