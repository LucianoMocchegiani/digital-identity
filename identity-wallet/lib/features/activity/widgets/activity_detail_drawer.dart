import 'package:flutter/material.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Drawer de detalle de un registro de actividad.
///
/// Se eleva desde abajo sobre la lista oscurecida (vía [showActivityDetail]),
/// igual que el detalle de credencial: cabecera con el estado y, debajo, filas
/// etiqueta/valor con [SheetFieldRow].
///
/// Distingue emisión ([IssuanceActivity]) de presentación
/// ([PresentationActivity]): en presentación agrega nombre y propósito de la
/// solicitud, y una nota fija cuando el estado es [ActivityStatus.failed].
class ActivityDetailDrawer extends StatelessWidget {
  const ActivityDetailDrawer({super.key, required this.activity});

  /// Evento de actividad a describir.
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final isPresentation = activity is PresentationActivity;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          // Se ajusta al contenido, sin pasar de casi toda la pantalla.
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.backgroundNeutralSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusHeader(status: activity.status),
                const SizedBox(height: 24),
                IdentityCard(
                  // Sin relleno inferior: cada fila ya aporta 16px abajo.
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SheetFieldRow(
                        label: 'Tipo',
                        value: isPresentation ? 'Presentación' : 'Emisión',
                      ),
                      SheetFieldRow(
                        label: 'Entidad',
                        value: activity.entity.name ??
                            activity.entity.host ??
                            activity.entity.id ??
                            '—',
                      ),
                      SheetFieldRow(
                        label: 'Fecha',
                        value: _formatDateTime(activity.date),
                      ),
                      ..._presentationFields(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Botón cerrar por fuera del sheet, sobre el área oscurecida.
        Positioned(
          right: 16,
          top: -46,
          child: IdentitySheetCloseButton(
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  /// Filas extra de una [PresentationActivity]: solicitud, propósito y rechazo.
  List<Widget> _presentationFields() {
    final presentation = activity;
    if (presentation is! PresentationActivity) return const [];

    return [
      if (presentation.request.name != null)
        SheetFieldRow(label: 'Solicitud', value: presentation.request.name!),
      if (presentation.request.purpose != null)
        SheetFieldRow(label: 'Propósito', value: presentation.request.purpose!),
      if (presentation.status == ActivityStatus.failed)
        const SheetFieldRow(
          label: 'Estado',
          value: 'La presentación fue rechazada por el verificador.',
        ),
    ];
  }

  /// Fecha y hora local en formato `dd/mm/aaaa hh:mm`.
  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$d/$mo/${dt.year} $h:$mi';
  }
}

/// Cabecera del drawer: disco con el ícono del estado y su etiqueta.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.status});

  final ActivityStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, accent, surface, label) = switch (status) {
      ActivityStatus.success => (
          Icons.check_rounded,
          AppColors.successIcon,
          AppColors.successSurface,
          'Exitosa',
        ),
      ActivityStatus.failed => (
          Icons.close_rounded,
          AppColors.dangerIcon,
          AppColors.dangerSurface,
          'Fallida',
        ),
      ActivityStatus.stopped => (
          Icons.stop_rounded,
          AppColors.textNeutralSecondary,
          AppColors.borderNeutral,
          'Cancelada',
        ),
    };

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
          child: Icon(icon, color: accent, size: 36),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            height: 26 / 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textNeutralPrimary,
          ),
        ),
      ],
    );
  }
}

/// Eleva el detalle de [activity] desde abajo sobre la lista de actividad.
///
/// Backdrop oscurecido (`rgba(0,0,0,0.6)`) y animación nativos del bottom sheet,
/// igual que `showCredentialDetail`. Devuelve cuando el usuario lo cierra.
Future<void> showActivityDetail(BuildContext context, Activity activity) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
    // Clip.none deja que el botón cerrar sobresalga por encima del sheet.
    clipBehavior: Clip.none,
    builder: (_) => ActivityDetailDrawer(activity: activity),
  );
}
