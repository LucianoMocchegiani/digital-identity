import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';

import '../credential/models/credential_record.dart';
import '../credential/models/mdoc_record.dart';
import '../credential/models/sd_jwt_vc_record.dart';
import '../credential/models/w3c_credential_record.dart';
import '../crypto/wallet_crypto_context.dart';
import '../utils/base64_utils.dart';
import 'isar/mdoc_isar.dart';
import 'isar/sd_jwt_vc_isar.dart';
import 'isar/w3c_credential_isar.dart';
import 'record_service.dart';
import 'record_store.dart';

/// Implementación de [RecordService] para credenciales verificables.
///
/// Rutea las operaciones a tres colecciones isar separadas según el tipo:
/// - [SdJwtVcRecord] → colección [SdJwtVcIsar]
/// - [W3cCredentialRecord] → colección [W3cCredentialIsar]
/// - [MdocRecord] → colección [MdocIsar]
///
/// Si [RecordStore.cryptoContext] está presente, los campos sensibles (JWT,
/// claims, credential JSON, issuerSigned) se persisten cifrados (`enc:v1:`).
class CredentialRecordStore implements RecordService<CredentialRecord> {
  /// Crea el store a partir del [RecordStore] ya abierto.
  CredentialRecordStore(this._store);

  final RecordStore _store;

  WalletCryptoContext? get _crypto => _store.cryptoContext;

  @override
  Future<void> save(CredentialRecord record) async {
    await _store.db.writeTxn(() async {
      switch (record) {
        case SdJwtVcRecord():
          final existing = await _store.db.sdJwtVcIsars
              .where()
              .recordIdEqualTo(record.id)
              .findFirst();
          if (existing != null) throw DuplicateRecordException(record.id);
          await _store.db.sdJwtVcIsars.put(await _toSdJwtIsar(record));
        case W3cCredentialRecord():
          final existing = await _store.db.w3cCredentialIsars
              .where()
              .recordIdEqualTo(record.id)
              .findFirst();
          if (existing != null) throw DuplicateRecordException(record.id);
          await _store.db.w3cCredentialIsars.put(await _toW3cIsar(record));
        case MdocRecord():
          final existing = await _store.db.mdocIsars
              .where()
              .recordIdEqualTo(record.id)
              .findFirst();
          if (existing != null) throw DuplicateRecordException(record.id);
          await _store.db.mdocIsars.put(await _toMdocIsar(record));
      }
    });
  }

  @override
  Future<void> update(CredentialRecord record) async {
    await _store.db.writeTxn(() async {
      switch (record) {
        case SdJwtVcRecord():
          final existing = await _store.db.sdJwtVcIsars
              .where()
              .recordIdEqualTo(record.id)
              .findFirst();
          if (existing == null) throw RecordNotFoundException(record.id);
          final obj = await _toSdJwtIsar(record)..id = existing.id;
          await _store.db.sdJwtVcIsars.put(obj);
        case W3cCredentialRecord():
          final existing = await _store.db.w3cCredentialIsars
              .where()
              .recordIdEqualTo(record.id)
              .findFirst();
          if (existing == null) throw RecordNotFoundException(record.id);
          final obj = await _toW3cIsar(record)..id = existing.id;
          await _store.db.w3cCredentialIsars.put(obj);
        case MdocRecord():
          final existing = await _store.db.mdocIsars
              .where()
              .recordIdEqualTo(record.id)
              .findFirst();
          if (existing == null) throw RecordNotFoundException(record.id);
          final obj = await _toMdocIsar(record)..id = existing.id;
          await _store.db.mdocIsars.put(obj);
      }
    });
  }

  /// Elimina la credencial con [id] de cualquiera de las tres colecciones.
  ///
  /// No lanza error si el record no existe en ninguna colección.
  @override
  Future<void> delete(String id) async {
    await _store.db.writeTxn(() async {
      await _store.db.sdJwtVcIsars
          .where()
          .recordIdEqualTo(id)
          .deleteFirst();
      await _store.db.w3cCredentialIsars
          .where()
          .recordIdEqualTo(id)
          .deleteFirst();
      await _store.db.mdocIsars
          .where()
          .recordIdEqualTo(id)
          .deleteFirst();
    });
  }

  @override
  Future<CredentialRecord?> getById(String id) async {
    final sdJwt = await _store.db.sdJwtVcIsars
        .where()
        .recordIdEqualTo(id)
        .findFirst();
    if (sdJwt != null) return _fromSdJwtIsar(sdJwt);

    final w3c = await _store.db.w3cCredentialIsars
        .where()
        .recordIdEqualTo(id)
        .findFirst();
    if (w3c != null) return _fromW3cIsar(w3c);

    final mdoc = await _store.db.mdocIsars
        .where()
        .recordIdEqualTo(id)
        .findFirst();
    if (mdoc != null) return _fromMdocIsar(mdoc);

    return null;
  }

  @override
  Future<List<CredentialRecord>> getAll() async {
    final sdJwts = await _store.db.sdJwtVcIsars.where().findAll();
    final w3cs = await _store.db.w3cCredentialIsars.where().findAll();
    final mdocs = await _store.db.mdocIsars.where().findAll();

    final records = <CredentialRecord>[
      ...await Future.wait(sdJwts.map(_fromSdJwtIsar)),
      ...await Future.wait(w3cs.map(_fromW3cIsar)),
      ...await Future.wait(mdocs.map(_fromMdocIsar)),
    ];
    return records;
  }

  /// Emite la lista unificada de credenciales cada vez que cualquier colección cambia.
  ///
  /// Combina los tres streams con `Rx.combineLatest3` para emitir la unión completa.
  @override
  Stream<List<CredentialRecord>> watch() {
    final sdJwtStream = _store.db.sdJwtVcIsars
        .where()
        .watch(fireImmediately: true)
        .asyncMap(
          (isars) => Future.wait(isars.map(_fromSdJwtIsar)),
        );

    final w3cStream = _store.db.w3cCredentialIsars
        .where()
        .watch(fireImmediately: true)
        .asyncMap(
          (isars) => Future.wait(isars.map(_fromW3cIsar)),
        );

    final mdocStream = _store.db.mdocIsars
        .where()
        .watch(fireImmediately: true)
        .asyncMap(
          (isars) => Future.wait(isars.map(_fromMdocIsar)),
        );

    return Rx.combineLatest3(
      sdJwtStream,
      w3cStream,
      mdocStream,
      (a, b, c) => <CredentialRecord>[...a, ...b, ...c],
    );
  }

  Future<String?> _protect(String? plaintext) async {
    final crypto = _crypto;
    if (crypto == null) return plaintext;
    return crypto.protectField(plaintext);
  }

  Future<String> _protectRequired(String plaintext) async {
    final crypto = _crypto;
    if (crypto == null) return plaintext;
    return crypto.protectFieldRequired(plaintext);
  }

  Future<String?> _reveal(String? stored) async {
    final crypto = _crypto;
    if (crypto == null) return stored;
    return crypto.revealField(stored);
  }

  // — SD-JWT VC mappers —

  Future<SdJwtVcIsar> _toSdJwtIsar(SdJwtVcRecord record) async {
    final prettyClaimsJson = jsonEncode(record.prettyClaims);
    final issuerMetadataJson = record.issuerMetadata != null
        ? jsonEncode(record.issuerMetadata)
        : null;
    final displayMetadataJson = record.displayMetadata != null
        ? jsonEncode(record.displayMetadata)
        : null;

    return SdJwtVcIsar()
      ..recordId = record.id
      ..createdAt = record.createdAt
      ..compactSdJwt = await _protectRequired(record.compactSdJwt)
      ..vct = record.vct
      ..prettyClaimsJson = await _protectRequired(prettyClaimsJson)
      ..issuerMetadataJson = await _protect(issuerMetadataJson)
      ..displayMetadataJson = await _protect(displayMetadataJson);
  }

  Future<SdJwtVcRecord> _fromSdJwtIsar(SdJwtVcIsar isar) async {
    final prettyClaimsJson =
        await _reveal(isar.prettyClaimsJson) ?? isar.prettyClaimsJson;
    final issuerMetadataJson = await _reveal(isar.issuerMetadataJson);
    final displayMetadataJson = await _reveal(isar.displayMetadataJson);
    final compactSdJwt =
        await _reveal(isar.compactSdJwt) ?? isar.compactSdJwt;

    return SdJwtVcRecord(
      id: isar.recordId,
      createdAt: isar.createdAt,
      compactSdJwt: compactSdJwt,
      vct: isar.vct,
      prettyClaims:
          jsonDecode(prettyClaimsJson) as Map<String, dynamic>,
      issuerMetadata: issuerMetadataJson != null
          ? jsonDecode(issuerMetadataJson) as Map<String, dynamic>
          : null,
      displayMetadata: displayMetadataJson != null
          ? jsonDecode(displayMetadataJson) as Map<String, dynamic>
          : null,
    );
  }

  // — W3C mappers —

  Future<W3cCredentialIsar> _toW3cIsar(W3cCredentialRecord record) async {
    final credentialJson = jsonEncode(record.credential);
    final displayMetadataJson = record.displayMetadata != null
        ? jsonEncode(record.displayMetadata)
        : null;

    return W3cCredentialIsar()
      ..recordId = record.id
      ..createdAt = record.createdAt
      ..claimFormatIndex = record.claimFormat.index
      ..credentialJson = await _protectRequired(credentialJson)
      ..types = record.types
      ..issuerDid = record.issuerDid
      ..holderDid = record.holderDid
      ..validFrom = record.validFrom
      ..validUntil = record.validUntil
      ..displayMetadataJson = await _protect(displayMetadataJson);
  }

  Future<W3cCredentialRecord> _fromW3cIsar(W3cCredentialIsar isar) async {
    final credentialJson =
        await _reveal(isar.credentialJson) ?? isar.credentialJson;
    final displayMetadataJson = await _reveal(isar.displayMetadataJson);

    return W3cCredentialRecord(
      id: isar.recordId,
      createdAt: isar.createdAt,
      claimFormat: ClaimFormat.values[isar.claimFormatIndex],
      credential: jsonDecode(credentialJson) as Map<String, dynamic>,
      types: isar.types,
      issuerDid: isar.issuerDid,
      holderDid: isar.holderDid,
      validFrom: isar.validFrom,
      validUntil: isar.validUntil,
      displayMetadata: displayMetadataJson != null
          ? jsonDecode(displayMetadataJson) as Map<String, dynamic>
          : null,
    );
  }

  // — mDoc mappers —

  Future<MdocIsar> _toMdocIsar(MdocRecord record) async {
    final namespacesJson = jsonEncode(record.namespaces);
    final issuerSignedBase64 = base64UrlEncode(record.issuerSignedBytes);
    final displayMetadataJson = record.displayMetadata != null
        ? jsonEncode(record.displayMetadata)
        : null;

    return MdocIsar()
      ..recordId = record.id
      ..createdAt = record.createdAt
      ..docType = record.docType
      ..namespacesJson = await _protectRequired(namespacesJson)
      ..issuerSignedBase64 = await _protectRequired(issuerSignedBase64)
      ..displayMetadataJson = await _protect(displayMetadataJson);
  }

  Future<MdocRecord> _fromMdocIsar(MdocIsar isar) async {
    final namespacesJson =
        await _reveal(isar.namespacesJson) ?? isar.namespacesJson;
    final issuerSignedBase64 =
        await _reveal(isar.issuerSignedBase64) ?? isar.issuerSignedBase64;
    final displayMetadataJson = await _reveal(isar.displayMetadataJson);

    return MdocRecord(
      id: isar.recordId,
      createdAt: isar.createdAt,
      docType: isar.docType,
      namespaces: (jsonDecode(namespacesJson) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as Map<String, dynamic>)),
      issuerSignedBytes: base64UrlDecode(issuerSignedBase64),
      displayMetadata: displayMetadataJson != null
          ? jsonDecode(displayMetadataJson) as Map<String, dynamic>
          : null,
    );
  }
}
