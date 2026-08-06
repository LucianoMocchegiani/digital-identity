import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navegación de conveniencia con [GoRouter] para flujos modales y deeplinks.
extension QuarkWalletNavigation on BuildContext {
  /// Si la pila permite [pop], hace pop; si no, [go] a [location].
  void popOrGo(String location) {
    if (canPop()) {
      pop();
    } else {
      go(location);
    }
  }

  /// Equivale a `popOrGo('/home')`.
  void popOrGoHome() => popOrGo('/home');
}
