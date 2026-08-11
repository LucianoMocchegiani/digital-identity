import 'package:flutter/material.dart';

import '../theme/kuatia_colors.dart';
import 'concentric_rings.dart';
import 'identity_danger_button.dart';
import 'identity_outline_button.dart';

/// Modal de confirmación destructiva (paridad visual con [IdentityErrorModal]).
class IdentityConfirmModal extends StatelessWidget {
  const IdentityConfirmModal({
    super.key,
    required this.title,
    required this.description,
    this.confirmLabel = 'Eliminar',
    this.cancelLabel = 'Cancelar',
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;

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
      builder: (_) => IdentityConfirmModal(
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
    final colors = context.kuatia;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Material(
          color: colors.panel,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 297,
            child: Stack(
              children: [
                ...concentricRings(color: colors.border),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.dangerSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border),
                    ),
                    child: Image.asset(
                      'public/images/icons/Trash-Bin-Trash.png',
                      width: 24,
                      height: 24,
                      color: colors.dangerIcon,
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
                      color: colors.panel,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              height: 22 / 16,
                              fontWeight: FontWeight.w500,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 18 / 14,
                              fontWeight: FontWeight.w400,
                              color: colors.muted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: IdentityOutlineButton(
                                  label: cancelLabel,
                                  expand: true,
                                  onTap: () =>
                                      Navigator.of(context).pop(false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: IdentityDangerButton(
                                  label: confirmLabel,
                                  onTap: () =>
                                      Navigator.of(context).pop(true),
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
                      color: colors.muted,
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
