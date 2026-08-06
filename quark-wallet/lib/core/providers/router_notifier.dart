import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/onboarding_progress_repository.dart';
import '../wallet_state.dart';
import 'onboarding_progress_notifier.dart';
import 'wallet_notifier.dart';

/// [ChangeNotifier] que refresca [GoRouter] ante cambios de wallet u onboarding.
///
/// Registrado como `refreshListenable` en [routerProvider]. Cada vez que
/// [walletNotifierProvider] o [onboardingProgressNotifierProvider] emiten un
/// valor nuevo, notifica a GoRouter para re-evaluar [GoRouter.redirect].
///
/// Esto permite, por ejemplo, redirigir a `/onboarding` cuando la wallet se
/// desbloquea pero `onboarding_complete` sigue en `false`, sin reiniciar la app.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen<AsyncValue<WalletState>>(
      walletNotifierProvider,
      (_, __) => notifyListeners(),
    );
    ref.listen<AsyncValue<OnboardingProgressData>>(
      onboardingProgressNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
}

/// Instancia compartida de [RouterNotifier] para [routerProvider].
final routerNotifierProvider = Provider<RouterNotifier>(RouterNotifier.new);
