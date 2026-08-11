import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_links_handler.dart';
import 'core/router/app_router.dart';
import 'shared/theme/app_colors.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/kuatia_colors.dart';
import 'shared/theme/theme_mode_provider.dart';

/// Arranque de la app: binding de Flutter, bloqueo de orientación vertical,
/// [ProviderScope] y [IdentityWalletApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: IdentityWalletApp()));
}

/// Raíz: [MaterialApp.router] con tema Kuatia (claro/oscuro) y deeplinks.
class IdentityWalletApp extends ConsumerStatefulWidget {
  const IdentityWalletApp({super.key});

  @override
  ConsumerState<IdentityWalletApp> createState() => _IdentityWalletAppState();
}

class _IdentityWalletAppState extends ConsumerState<IdentityWalletApp> {
  late final AppLinksHandler _linksHandler;

  @override
  void initState() {
    super.initState();
    final router = ref.read(routerProvider);
    _linksHandler = AppLinksHandler(router);
    _linksHandler.start();
  }

  @override
  void dispose() {
    _linksHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Kuatia Wallet',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      builder: (context, child) {
        return Builder(
          builder: (context) {
            final kuatia =
                Theme.of(context).extension<KuatiaColors>() ?? KuatiaColors.dark;
            AppColors.bind(kuatia);
            final isLight = Theme.of(context).brightness == Brightness.light;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: (isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light)
                  .copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: kuatia.bg,
                systemNavigationBarIconBrightness:
                    isLight ? Brightness.dark : Brightness.light,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
