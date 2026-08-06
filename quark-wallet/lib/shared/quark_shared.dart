/// Recursos compartidos de la app (un solo import desde features).
///
/// Incluye padding de pantallas auth/onboarding, estilos de botón y títulos,
/// navegación `popOrGo`, snackbars, flujos de protocolo (error/progreso/éxito)
/// y widgets auxiliares (fila de acciones, logo remoto, AppBar con progreso).
///
/// Uso típico:
/// ```dart
/// import 'package:quark_wallet/shared/quark_shared.dart';
/// ```
library quark_shared;

export 'extensions/build_context_navigation.dart';
export 'layout/app_screen_insets.dart';
export 'theme/app_button_styles.dart';
export 'theme/app_colors.dart';
export 'theme/app_shadows.dart';
export 'theme/app_text_theme.dart';
export 'theme/pin_input_theme.dart';
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
export 'widgets/quark_bottom_nav.dart';
export 'widgets/quark_card.dart';
export 'widgets/quark_confirm_modal.dart';
export 'widgets/quark_danger_button.dart';
export 'widgets/quark_empty_state.dart';
export 'widgets/quark_eye_toggle.dart';
export 'widgets/quark_flow_sheet.dart';
export 'widgets/quark_page_app_bar.dart';
export 'widgets/quark_primary_button.dart';
export 'widgets/quark_sheet_close_button.dart';
export 'widgets/quark_success_modal.dart';
export 'widgets/quark_outline_button.dart';
export 'widgets/quark_error_modal.dart';
export 'widgets/quark_top_bar.dart';
export 'widgets/staggered_slide_in.dart';
