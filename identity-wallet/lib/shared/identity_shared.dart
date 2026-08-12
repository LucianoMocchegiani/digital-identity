/// Recursos compartidos de la app (un solo import desde features).
///
/// Incluye padding de pantallas auth/onboarding, estilos de botón y títulos,
/// navegación `popOrGo`, snackbars, flujos de protocolo (error/progreso/éxito)
/// y widgets auxiliares (fila de acciones, logo remoto, AppBar con progreso).
///
/// Uso típico:
/// ```dart
/// import 'package:identity_wallet/shared/identity_shared.dart';
/// ```
library identity_shared;

export 'extensions/build_context_navigation.dart';
export 'layout/app_screen_insets.dart';
export 'theme/app_button_styles.dart';
export 'theme/app_colors.dart';
export 'theme/app_shadows.dart';
export 'theme/app_text_theme.dart';
export 'theme/app_theme.dart';
export 'theme/kuatia_colors.dart';
export 'theme/pin_input_theme.dart';
export 'theme/theme_mode_provider.dart';
export 'utils/app_snackbar.dart';
export 'widgets/concentric_rings.dart';
export 'widgets/credential_loading_overlay.dart';
export 'widgets/flow_action_row.dart';
export 'widgets/flow_error_modal_launcher.dart';
export 'widgets/flow_progress_view.dart';
export 'widgets/flow_step_app_bar.dart';
export 'widgets/flow_success_modal_launcher.dart';
export 'widgets/network_logo_or_placeholder.dart';
export 'widgets/notification_button.dart';
export 'widgets/identity_bottom_nav.dart';
export 'widgets/identity_card.dart';
export 'widgets/identity_confirm_modal.dart';
export 'widgets/identity_danger_button.dart';
export 'widgets/identity_empty_state.dart';
export 'widgets/identity_eye_toggle.dart';
export 'widgets/identity_flow_sheet.dart';
export 'widgets/identity_page_app_bar.dart';
export 'widgets/identity_primary_button.dart';
export 'widgets/identity_sheet_close_button.dart';
export 'widgets/identity_success_modal.dart';
export 'widgets/identity_outline_button.dart';
export 'widgets/identity_error_modal.dart';
export 'widgets/identity_top_bar.dart';
export 'widgets/kuatia_atmosphere.dart';
export 'widgets/kuatia_mark.dart';
