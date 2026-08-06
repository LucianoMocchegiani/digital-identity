import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/onboarding_progress_notifier.dart';
import '../providers/router_notifier.dart';
import '../providers/wallet_notifier.dart';
import '../wallet_state.dart';
import '../../features/auth/authenticate_screen.dart';
import '../../features/auth/pin_locked_screen.dart';
import '../../features/activity/screens/activity_screen.dart';
import '../../features/inbox/screens/inbox_screen.dart';
import '../../features/protocol_flows/didcomm/didcomm_flow_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/menu/screens/about_screen.dart';
import '../../features/menu/screens/menu_screen.dart';
import '../../features/menu/screens/reset_wallet_screen.dart';
import '../../features/menu/screens/settings_screen.dart';
import '../../features/protocol_flows/oid4vci/oid4vci_flow_screen.dart';
import '../../features/protocol_flows/oid4vp/oid4vp_flow_screen.dart';
import '../../features/onboarding/onboarding_flow.dart';
import '../../features/scan/scan_screen.dart';

/// Router principal de la app ([GoRouter]) provisto por Riverpod.
///
/// Observa [routerNotifierProvider] como [GoRouter.refreshListenable] para que,
/// ante cada cambio en [walletNotifierProvider], se vuelva a evaluar
/// [GoRouter.redirect].
///
/// Redirecciones según [WalletState] y progreso de onboarding:
/// - [WalletNotConfigured]: cualquier ruta que no sea onboarding → `/onboarding`.
/// - [WalletLocked]: rutas distintas de autenticación o PIN bloqueado → `/authenticate`.
/// - [WalletUnlocked] con `onboarding_complete == false` → `/onboarding` (paso credencial).
/// - [WalletUnlocked] con onboarding completo: splash, onboarding o auth → `/home`.
///
/// Mientras [walletNotifierProvider] está en carga, no redirige.
/// Si hubo error al leer estado, envía a `/onboarding` como recuperación conservadora.
///
/// Rutas anidadas bajo `/home` (escaneo, actividad, inbox, menú y submenú). El
/// detalle de una credencial no es una ruta: se abre como drawer sobre el home
/// (`showCredentialDetail`). Las pantallas de notificación OID4VCI, OID4VP y
/// DIDComm viven en rutas absolutas y esperan el query `url`.

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, routerState) {
      final async = ref.read(walletNotifierProvider);
      final onboardingProgress = ref.read(onboardingProgressNotifierProvider);
      final onboardingComplete = isOnboardingComplete(onboardingProgress);

      return async.when(
        loading: () => null,
        error: (_, __) => '/onboarding',
        data: (ws) {
          final loc = routerState.matchedLocation;
          final onOnboarding = loc.startsWith('/onboarding');
          final onAuth = loc == '/authenticate' || loc == '/pin-locked';
          final onSplash = loc == '/';

          if (ws is WalletNotConfigured) {
            return onOnboarding ? null : '/onboarding';
          }
          if (ws is WalletLocked) {
            return onAuth ? null : '/authenticate';
          }
          if (ws is WalletUnlocked) {
            if (!onboardingComplete) {
              return _allowedDuringIncompleteOnboarding(loc) ? null : '/onboarding';
            }
            return (onOnboarding || onAuth || onSplash) ? '/home' : null;
          }
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingFlow(),
      ),
      GoRoute(
        path: '/authenticate',
        builder: (_, __) => const AuthenticateScreen(),
      ),
      GoRoute(
        path: '/pin-locked',
        builder: (_, __) => const PinLockedScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'scan',
            builder: (_, __) => const ScanScreen(),
          ),
          GoRoute(
            path: 'activity',
            builder: (_, __) => const ActivityScreen(),
          ),
          GoRoute(
            path: 'inbox',
            builder: (_, __) => const InboxScreen(),
          ),
          GoRoute(
            path: 'menu',
            builder: (_, __) => const MenuScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (_, __) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'about',
                builder: (_, __) => const AboutScreen(),
              ),
              GoRoute(
                path: 'reset',
                builder: (_, __) => const ResetWalletScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/notifications/oid4vci',
        // Página transparente: el modal de confirmación, el overlay de carga y
        // el modal de éxito se componen sobre el contenido previo (cámara/home).
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          opaque: false,
          barrierColor: Colors.transparent,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          child: Oid4VciNotificationScreen(
            url: state.uri.queryParameters['url']!,
          ),
        ),
      ),
      GoRoute(
        path: '/notifications/oid4vp',
        // Página transparente: el slide de confirmación, el overlay de carga y
        // el modal de éxito se componen sobre el contenido previo (home).
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          opaque: false,
          barrierColor: Colors.transparent,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          child: Oid4VpNotificationScreen(
            url: state.uri.queryParameters['url']!,
          ),
        ),
      ),
      GoRoute(
        path: '/notifications/didcomm',
        // Página transparente: el sheet de confirmación, el overlay de carga y
        // el modal de éxito se componen sobre el contenido previo (home/cámara).
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          opaque: false,
          barrierColor: Colors.transparent,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          child: DidCommNotificationScreen(
            url: state.uri.queryParameters['url']!,
          ),
        ),
      ),
    ],
  );
});

/// Rutas permitidas mientras el onboarding no está marcado como completo.
///
/// Incluye el escáner y los flujos de protocolo disparados por QR, para que el
/// paso final de onboarding pueda emitir la primera credencial sin redirigir
/// de vuelta a [OnboardingFlow].
bool _allowedDuringIncompleteOnboarding(String location) {
  if (location.startsWith('/onboarding')) return true;
  if (location == '/home/scan') return true;
  if (location.startsWith('/notifications/')) return true;
  return false;
}

/// Pantalla de arranque mientras [walletNotifierProvider] termina de resolver.
///
/// No contiene lógica de negocio; el [GoRouter.redirect] de [routerProvider]
/// decide el destino real según [WalletState].

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
