import '../did/did_resolver.dart';
import '../did/did_service.dart';
import '../kms/kms_service.dart';
import '../kms/software_kms.dart';
import '../invitation/invitation_resolver.dart';
import '../protocol/didcomm/didcomm_service.dart';
import '../protocol/openid4vc/oid4vci/oid4vci_service.dart';
import '../protocol/openid4vc/oid4vp/oid4vp_service.dart';
import '../trust/trust_config.dart';
import '../record/activity_record_store.dart';
import '../record/connection_record_store.dart';
import '../record/credential_record_store.dart';
import '../record/deferred_credential_record_store.dart';
import '../record/did_record_store.dart';
import '../record/key_record_store.dart';
import '../record/record_store.dart';
import '../crypto/wallet_crypto_context.dart';
import 'wallet_exceptions.dart';

/// Sesión activa de un wallet desbloqueado.
///
/// Expone los stores de persistencia, el KMS y los servicios de alto nivel.
/// Todos los getters lanzan [WalletLockedError] si la sesión fue bloqueada
/// mediante [lock] o [WalletService.lock].
class WalletSession {
  WalletSession._({
    required RecordStore recordStore,
    WalletCryptoContext? cryptoContext,
    required CredentialRecordStore credentialStore,
    required DidRecordStore didStore,
    required KeyRecordStore keyStore,
    required ActivityRecordStore activityStore,
    required DeferredCredentialRecordStore deferredStore,
    required ConnectionRecordStore connectionStore,
    required KmsService kms,
    required DidService didService,
    required Oid4VciService openid4vci,
    required Oid4VpService openid4vp,
    required InvitationResolver invitation,
    required DidCommService didcomm,
  })  : _recordStore = recordStore,
        _cryptoContext = cryptoContext,
        _credentialStore = credentialStore,
        _didStore = didStore,
        _keyStore = keyStore,
        _activityStore = activityStore,
        _deferredStore = deferredStore,
        _connectionStore = connectionStore,
        _kms = kms,
        _didService = didService,
        _openid4vci = openid4vci,
        _openid4vp = openid4vp,
        _invitation = invitation,
        _didcomm = didcomm;

  /// Ensambla una sesión con todos los stores y servicios de protocolo SSI.
  ///
  /// [recordStore] base de datos Isar ya abierta.
  /// [trustConfig] mecanismos de confianza opcionales para OID4VP.
  /// [kms] backend criptográfico; por defecto [SoftwareKms].
  /// [cryptoContext] clave y cifrador de campos; requerido para persistencia
  /// cifrada cuando se usa vía [WalletService]. Puede ser `null` si el
  /// integrador abre el [RecordStore] manualmente sin pasar por el servicio.
  factory WalletSession.fromRecordStore(
    RecordStore recordStore, {
    TrustConfig? trustConfig,
    KmsService? kms,
    WalletCryptoContext? cryptoContext,
  }) {
    final resolvedKms = kms ?? SoftwareKms();
    final credentialStore = CredentialRecordStore(recordStore);
    final didStore = DidRecordStore(recordStore);
    final keyStore = KeyRecordStore(recordStore);
    final activityStore = ActivityRecordStore(recordStore);
    final deferredStore = DeferredCredentialRecordStore(recordStore);
    final resolver = UniversalDidResolver();

    final didService = DidService(
      kms: resolvedKms,
      keyStore: keyStore,
      didStore: didStore,
      resolver: resolver,
    );

    final openid4vci = Oid4VciService(
      credentialStore: credentialStore,
      deferredStore: deferredStore,
      kms: resolvedKms,
      didService: didService,
      keyStore: keyStore,
    );

    final openid4vp = Oid4VpService(
      credentialStore: credentialStore,
      activityStore: activityStore,
      kms: resolvedKms,
      didService: didService,
      keyStore: keyStore,
      didResolver: resolver,
      trustConfig: trustConfig,
    );

    final connectionStore = ConnectionRecordStore(recordStore);

    final didcomm = DidCommService(
      kms: resolvedKms,
      didService: didService,
      keyStore: keyStore,
      connectionStore: connectionStore,
    );

    final invitation = InvitationResolver(
      oid4vciService: openid4vci,
      oid4vpService: openid4vp,
    );

    return WalletSession._(
      recordStore: recordStore,
      cryptoContext: cryptoContext,
      credentialStore: credentialStore,
      didStore: didStore,
      keyStore: keyStore,
      activityStore: activityStore,
      deferredStore: deferredStore,
      connectionStore: connectionStore,
      kms: resolvedKms,
      didService: didService,
      openid4vci: openid4vci,
      openid4vp: openid4vp,
      invitation: invitation,
      didcomm: didcomm,
    );
  }

  final RecordStore _recordStore;
  final WalletCryptoContext? _cryptoContext;
  final CredentialRecordStore _credentialStore;
  final DidRecordStore _didStore;
  final KeyRecordStore _keyStore;
  final ActivityRecordStore _activityStore;
  final DeferredCredentialRecordStore _deferredStore;
  final ConnectionRecordStore _connectionStore;
  final KmsService _kms;
  final DidService _didService;
  final Oid4VciService _openid4vci;
  final Oid4VpService _openid4vp;
  final InvitationResolver _invitation;
  final DidCommService _didcomm;

  bool _locked = false;

  /// Verdadero si el wallet fue bloqueado y los stores ya no están disponibles.
  bool get isLocked => _locked;

  void _assertUnlocked() {
    if (_locked) throw const WalletLockedError();
  }

  /// Contexto de cifrado de la sesión actual, si fue abierta con [WalletService].
  ///
  /// Contiene la clave AES derivada del PIN y un [FieldCipher] para que los
  /// stores cifren `privateJwkJson`, JWTs y tokens antes de escribir en Isar.
  ///
  /// Retorna `null` si la sesión se creó con [fromRecordStore] sin
  /// [WalletCryptoContext] (integración avanzada).
  ///
  /// Lanza [WalletLockedError] si la sesión ya fue bloqueada.
  WalletCryptoContext? get cryptoContext {
    _assertUnlocked();
    return _cryptoContext;
  }

  /// Store de credenciales verificables (SD-JWT VC, W3C, mDoc).
  CredentialRecordStore get credentialStore {
    _assertUnlocked();
    return _credentialStore;
  }

  /// Store de DIDs controlados por el wallet.
  DidRecordStore get didStore {
    _assertUnlocked();
    return _didStore;
  }

  /// Store de pares de claves criptográficas.
  KeyRecordStore get keyStore {
    _assertUnlocked();
    return _keyStore;
  }

  /// Store del historial de actividad (emisión y presentación).
  ActivityRecordStore get activityStore {
    _assertUnlocked();
    return _activityStore;
  }

  /// Store de credenciales diferidas pendientes.
  DeferredCredentialRecordStore get deferredStore {
    _assertUnlocked();
    return _deferredStore;
  }

  /// KMS activo (software o hardware-backed según configuración de [WalletService]).
  KmsService get kms {
    _assertUnlocked();
    return _kms;
  }

  /// Servicio de DIDs: creación, resolución y lookup de DIDs locales.
  DidService get dids {
    _assertUnlocked();
    return _didService;
  }

  /// Servicio OID4VCI: flujo completo de issuance de credenciales verificables.
  Oid4VciService get openid4vci {
    _assertUnlocked();
    return _openid4vci;
  }

  /// Servicio OID4VP: flujo completo de presentación de credenciales verificables.
  Oid4VpService get openid4vp {
    _assertUnlocked();
    return _openid4vp;
  }

  /// Router universal de invitaciones (QR / deeplink / clipboard).
  ///
  /// Detecta el tipo de URL y delega al servicio correspondiente.
  InvitationResolver get invitation {
    _assertUnlocked();
    return _invitation;
  }

  /// Store de conexiones DIDComm establecidas.
  ConnectionRecordStore get connectionStore {
    _assertUnlocked();
    return _connectionStore;
  }

  /// Fachada DIDComm: conexiones, intercambio de credenciales y pruebas.
  DidCommService get didcomm {
    _assertUnlocked();
    return _didcomm;
  }

  /// Cierra la base de datos subyacente y marca la sesión como bloqueada.
  ///
  /// Después de llamar a [lock] cualquier acceso a los stores lanza
  /// [WalletLockedError]. Normalmente se llama a través de [WalletService.lock].
  Future<void> lock() async {
    _locked = true;
    await _recordStore.close();
  }
}
