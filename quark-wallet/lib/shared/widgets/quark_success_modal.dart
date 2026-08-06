import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import 'concentric_rings.dart';

/// Modal de confirmación de éxito (componente `Modal-creación-exitosa`).
///
/// Muestra el ícono de éxito (check verde sobre anillos concéntricos), un
/// [title], una [description] y el botón "Continuar". Tanto "Continuar" como el
/// botón cerrar descartan el modal; [show] resuelve cuando se cierra.
///
/// Es genérico: lo reutilizan distintos flujos (ej. categoría creada, PIN
/// creado) variando solo los textos.
class QuarkSuccessModal extends StatelessWidget {
  const QuarkSuccessModal({
    super.key,
    required this.title,
    required this.description,
  });

  /// Título del modal (ej. "PIN creado correctamente").
  final String title;

  /// Texto descriptivo bajo el título.
  final String description;

  /// Muestra el modal sobre un fondo oscuro; resuelve al cerrarse.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x99000000), // rgba(0,0,0,0.6)
      builder: (_) => QuarkSuccessModal(title: title, description: description),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 297,
            child: Stack(
              children: [
                // Anillos concéntricos: se recortan contra el borde del modal,
                // pero el disco verde queda siempre intacto.
                ...concentricRings(),
                // Disco verde con el check (48px, centro en (40,40)).
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF3),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderNeutral),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 24,
                      color: Color(0xFF12B76A),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banda de cabecera (deja ver el check + anillos superiores).
                    const SizedBox(height: 72),
                    // Texto + botón sobre fondo blanco (cubre las elipses inferiores).
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 22 / 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textNeutralPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 120),
                            child: SingleChildScrollView(
                              child: Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 18 / 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textNeutralSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _continueButton(context),
                        ],
                      ),
                    ),
                  ],
                ),
                // Botón cerrar (esquina superior derecha).
                Positioned(
                  right: 16,
                  top: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Image.asset(
                      'public/images/icons/Close-Circle.png',
                      width: 24,
                      height: 24,
                      color: AppColors.textNeutralSecondary,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Botón "Continuar".
  Widget _continueButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Alto mínimo en lugar de fijo: crece con la fuente del sistema.
        constraints: const BoxConstraints(minHeight: 34),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderNeutral),
          boxShadow: const [kShadowXs],
        ),
        child: const Text(
          'Continuar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 18 / 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textNeutralPrimary,
          ),
        ),
      ),
    );
  }
}
