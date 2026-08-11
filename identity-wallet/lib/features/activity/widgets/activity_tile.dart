import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Fila de lista para un [Activity] (emisión o presentación).
///
/// Muestra título según [IssuanceActivity] vs [PresentationActivity], subtítulo
/// con nombre/host/id de [Activity.entity], un disco con icono de descarga o
/// compartir teñido por [ActivityStatus], y a la derecha el icono de estado y la
/// hora local. Usa los tokens del design system, igual que el resto del menú.
///
/// Usado en [ActivityScreen]; [onTap] suele navegar al detalle.
class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.activity, this.onTap});

  final Activity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIssuance = activity is IssuanceActivity;
    final entityLabel = activity.entity.name ??
        activity.entity.host ??
        activity.entity.id ??
        'Entidad desconocida';
    final accent = _statusColor(activity.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _statusSurface(activity.status),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIssuance ? Icons.download_outlined : Icons.share_outlined,
                  size: 20,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIssuance
                          ? 'Credencial recibida'
                          : 'Credencial presentada',
                      style: TextStyle(
                        fontSize: 14,
                        height: 18 / 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textNeutralPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entityLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textNeutralSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(_statusIcon(activity.status), size: 16, color: accent),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(activity.date),
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textNeutralMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Color del acento de estado (éxito, fallo, cancelado).
  Color _statusColor(ActivityStatus status) => switch (status) {
        ActivityStatus.success => AppColors.successIcon,
        ActivityStatus.failed => AppColors.dangerIcon,
        ActivityStatus.stopped => AppColors.textNeutralMuted,
      };

  /// Fondo del disco del avatar, en el mismo tono que el acento.
  Color _statusSurface(ActivityStatus status) => switch (status) {
        ActivityStatus.success => AppColors.successSurface,
        ActivityStatus.failed => AppColors.dangerSurface,
        ActivityStatus.stopped => AppColors.borderNeutral,
      };

  /// Icono pequeño del trailing según [ActivityStatus].
  IconData _statusIcon(ActivityStatus status) => switch (status) {
        ActivityStatus.success => Icons.check_circle_outline,
        ActivityStatus.failed => Icons.error_outline,
        ActivityStatus.stopped => Icons.cancel_outlined,
      };

  /// Hora local `hh:mm` para el trailing.
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
