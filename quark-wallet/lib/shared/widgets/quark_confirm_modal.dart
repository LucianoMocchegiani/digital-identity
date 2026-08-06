import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'concentric_rings.dart';
import 'quark_danger_button.dart';
import 'quark_outline_button.dart';

/// Modal de confirmación destructiva (paridad visual con [QuarkErrorModal]).
///
/// Muestra el tacho sobre anillos concéntricos, un [title], una [description] y
/// dos acciones: cancelar y confirmar. Lo comparten el borrado de credencial y
/// el de categoría; [show] resuelve `true` solo si el usuario confirma.
class QuarkConfirmModal extends StatelessWidget {
  const QuarkConfirmModal({
    super.key,
    required this.title,
    required this.description,
    this.confirmLabel = 'Eliminar',
    this.cancelLabel = 'Cancelar',
  });

  /// Título del modal (ej. "Eliminar credencial").
  final String title;

  /// Texto descriptivo bajo el título.
  final String description;

  /// Etiqueta de la acción destructiva.
  final String confirmLabel;

  /// Etiqueta de la acción que descarta el modal.
  final String cancelLabel;

  /// Muestra el modal sobre un fondo oscuro; resuelve `true` si se confirma.
  ///
  /// Cerrar con la cruz, tocar cancelar o descartar el modal resuelven `false`,
  /// de modo que quien llama puede tratar cualquier salida como "no borrar".
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String description,
    String confirmLabel = 'Eliminar',
    String cancelLabel = 'Cancelar',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => QuarkConfirmModal(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
    return confirmed ?? false;
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
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.dangerSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderNeutral),
                    ),
                    child: Image.asset(
                      'public/images/icons/Trash-Bin-Trash.png',
                      width: 24,
                      height: 24,
                      color: AppColors.dangerIcon,
                      colorBlendMode: BlendMode.srcIn,
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: QuarkOutlineButton(
                                  label: cancelLabel,
                                  expand: true,
                                  onTap: () =>
                                      Navigator.of(context).pop(false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: QuarkDangerButton(
                                  label: confirmLabel,
                                  onTap: () => Navigator.of(context).pop(true),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
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
}
