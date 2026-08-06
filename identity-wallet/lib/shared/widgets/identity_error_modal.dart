import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import 'concentric_rings.dart';

/// Modal de error (paridad visual con [IdentitySuccessModal]).
///
/// Muestra el ícono de error (cruz roja sobre anillos concéntricos), un [title],
/// una [description] y el botón "Cerrar". Tanto "Cerrar" como el botón cerrar
/// descartan el modal; [show] resuelve cuando se cierra.
class IdentityErrorModal extends StatelessWidget {
  const IdentityErrorModal({
    super.key,
    required this.title,
    required this.description,
  });

  /// Título del modal (ej. "No se pudo verificar").
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
      barrierColor: const Color(0x99000000),
      builder: (_) => IdentityErrorModal(title: title, description: description),
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
                ...concentricRings(),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderNeutral),
                    ),
                    child: const Icon(
                      Icons.highlight_off_rounded,
                      size: 24,
                      color: AppColors.errorDot,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 72),
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
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 18 / 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textNeutralSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _closeButton(context),
                        ],
                      ),
                    ),
                  ],
                ),
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

  Widget _closeButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
          'Cerrar',
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
