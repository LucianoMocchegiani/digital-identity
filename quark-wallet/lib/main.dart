import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/app_links_handler.dart';
import 'core/router/app_router.dart';

/// Arranque de la app: binding de Flutter, bloqueo de orientación vertical,
/// [ProviderScope] y [QuarkWalletApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // La app se mantiene siempre en vertical (sin giro de pantalla).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: QuarkWalletApp()));
}

/// Raíz de la aplicación: [MaterialApp.router] con [routerProvider] y deeplinks.
///
/// En [initState] lee [routerProvider], crea [AppLinksHandler] y llama [AppLinksHandler.start]
/// para enlaces iniciales y en caliente. En [dispose] cancela la suscripción con [AppLinksHandler.dispose].
class QuarkWalletApp extends ConsumerStatefulWidget {
  const QuarkWalletApp({super.key});

  @override
  ConsumerState<QuarkWalletApp> createState() => _QuarkWalletAppState();
}

/// Mantiene [AppLinksHandler] y observa [routerProvider] para reconstruir [MaterialApp.router].
class _QuarkWalletAppState extends ConsumerState<QuarkWalletApp> {
  late final AppLinksHandler _linksHandler;

  @override
  void initState() {
    super.initState();
    final router = ref.read(routerProvider);
    _linksHandler = AppLinksHandler(router);
    _linksHandler.start();
  }

  /// Cancela la escucha de deeplinks antes de desmontar.
  @override
  void dispose() {
    _linksHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // Theme base Material 3 con la tipografía Manrope del design system aplicada
    // de forma global (conserva los colores de texto del tema base).
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo);
    return MaterialApp.router(
      title: 'Wallet',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: base.copyWith(
        textTheme: GoogleFonts.manropeTextTheme(base.textTheme),
      ),
    );
  }
}
