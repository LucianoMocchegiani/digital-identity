import 'package:flutter/material.dart';

import '../theme/app_shadows.dart';
import '../theme/kuatia_colors.dart';
import 'concentric_rings.dart';

/// Modal de confirmación de éxito.
class IdentitySuccessModal extends StatelessWidget {
  const IdentitySuccessModal({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (_) => IdentitySuccessModal(title: title, description: description),
    );
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
                    decoration: BoxDecoration(
                      color: colors.successSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 24,
                      color: colors.successIcon,
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
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 120),
                            child: SingleChildScrollView(
                              child: Text(
                                description,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 18 / 14,
                                  fontWeight: FontWeight.w400,
                                  color: colors.muted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _continueButton(context, colors),
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

  Widget _continueButton(BuildContext context, KuatiaColors colors) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 34),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: colors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: const [kShadowXs],
        ),
        child: Text(
          'Continuar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 18 / 14,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
      ),
    );
  }
}
