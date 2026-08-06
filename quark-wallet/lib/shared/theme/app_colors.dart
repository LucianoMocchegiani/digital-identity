import 'package:flutter/material.dart';

/// Tokens de color del design system de QuarkID Wallet.
///
/// Los nombres replican los tokens de Pencil (ej. `Color/Background/Neutral/
/// Secundario`). Se ampliarán a medida que avancemos en la nueva UI.
abstract final class AppColors {
  /// `Color/Background/Neutral/Secundario` — fondo de superficies neutras.
  static const Color backgroundNeutralSecondary = Color(0xFFFDFDFD);

  /// `Color/Border/Neutral` — borde neutro de componentes.
  static const Color borderNeutral = Color(0xFFE9EAEB);

  /// Texto/ícono neutro primario (ej. labels del navbar inferior).
  static const Color textNeutralPrimary = Color(0xFF252B37);

  /// Texto/ícono neutro atenuado (ej. textos del estado vacío).
  static const Color textNeutralMuted = Color(0xFFA4A7AE);

  /// Texto secundario (ej. subtítulo de cada categoría).
  static const Color textNeutralSecondary = Color(0xFF717680);

  /// Morado de marca para acciones destacadas (ej. botón QR del navbar inferior).
  static const Color brandPrimary = Color(0xFF6941C6);

  /// Azul de acento para el estado seleccionado (ej. tab activo de la barra flotante).
  static const Color accentBlue = Color(0xFF53B1FD);

  /// Fondo celeste del estado seleccionado.
  static const Color accentBlueSurface = Color(0xFFEFF8FF);

  /// Celeste del paso activo en el indicador de progreso del onboarding (slides).
  static const Color progressActive = Color(0xFF7CD4FD);

  /// Relleno del checkbox seleccionado (estado activo).
  static const Color checkboxCheckedFill = Color(0xFF36BFFA);

  /// Azul de enlaces de texto (ej. "Términos y Condiciones").
  static const Color linkBlue = Color(0xFF0BA5EC);

  /// Fondo del badge de advertencia (ej. aviso "Recordá tu PIN").
  static const Color warningSurface = Color(0xFFFFFAEB);

  /// Texto/ícono del badge de advertencia.
  static const Color warningText = Color(0xFF93370D);

  /// Rojo de los puntos del PIN en estado de error.
  static const Color errorDot = Color(0xFFF97066);

  /// Fondo del badge de error (ej. "El código ingresado no coincide").
  static const Color errorSurface = Color(0xFFFEF3F2);

  /// Texto del badge de error.
  static const Color errorText = Color(0xFF912018);

  /// `DetallesCromáticos/Rojo` — rojo del badge de notificaciones.
  static const Color notificationBadge = Color(0xFFE74C3C);

  /// Fondo rosado de las acciones destructivas (ej. botón "Eliminar").
  static const Color dangerSurface = Color(0xFFFEE4E2);

  /// Texto de las acciones destructivas.
  static const Color dangerText = Color(0xFFF04438);

  /// Ícono de las acciones destructivas (un tono más oscuro que el texto).
  static const Color dangerIcon = Color(0xFFD92D20);

  /// Verde de los vértices del marco de escaneo en estado de éxito.
  static const Color scanSuccessFrame = Color(0xFF32D583);

  /// Fondo del badge "Escaneo exitoso".
  static const Color successSurface = Color(0xFFECFDF3);

  /// Verde del check del badge "Escaneo exitoso".
  static const Color successIcon = Color(0xFF12B76A);

  /// Texto del badge "Escaneo exitoso".
  static const Color successText = Color(0xFF05603A);

  /// Blanco de marca para texto/íconos sobre fondos oscuros (ej. overlay de cámara).
  static const Color textOnDark = Color(0xFFFDFDFD);
}
