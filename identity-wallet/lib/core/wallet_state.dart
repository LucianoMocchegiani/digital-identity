import 'package:identity_core_dart/identity_core.dart';

/// Suma discriminada del ciclo de vida del wallet en la app.
///
/// Subtipos: [WalletNotConfigured], [WalletLocked], [WalletUnlocked]. El estado
/// vivo lo expone [WalletNotifier] como `AsyncValue<WalletState>` vía
/// [walletNotifierProvider]; [GoRouter] en [routerProvider] redirige según el caso.
///
/// Al ser `sealed`, un `switch` o cadena de `if (state is ...)` sobre [WalletState]
/// puede ser exhaustivo: el compilador avisa si falta un subtipo.

sealed class WalletState {
  const WalletState();
}

/// Aún no hay wallet creada (no existe salt en almacenamiento seguro).
///
/// La UI guía a onboarding hasta [WalletNotifier.create]; después pasa a
/// [WalletUnlocked] o, si el usuario cierra sin terminar, puede seguir aquí según flujo.

class WalletNotConfigured extends WalletState {
  const WalletNotConfigured();
}

/// Wallet creada en disco pero sin sesión desbloqueada (PIN / biometría pendiente).
///
/// Tras un PIN incorrecto, [WalletNotifier.unlock] puede dejar este estado con
/// [error] no nulo para mostrar feedback en [AuthenticateScreen] sin perder el resto
/// del flujo de auth.

class WalletLocked extends WalletState {
  const WalletLocked({this.error});

  /// Mensaje del último fallo (p. ej. PIN incorrecto); null si solo está bloqueada.
  final String? error;
}

/// Sesión activa del paquete Identity Core: credenciales, DIDComm y almacenes accesibles.
///
/// Quien necesite [WalletSession] debe asegurarse de estar en este estado (o usar
/// [WalletNotifier.session], que valida y lanza [WalletLockedError] si no).

class WalletUnlocked extends WalletState {
  const WalletUnlocked(this.session);

  final WalletSession session;
}
