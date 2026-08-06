import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:quark_wallet/shared/quark_shared.dart';

import '../providers/activity_provider.dart';
import '../widgets/activity_detail_drawer.dart';
import '../widgets/activity_tile.dart';

/// Historial de actividad del holder bajo `/home/activity`.
///
/// Observa [activityProvider] (stream de [Activity]). Lista vacía con mensaje; si
/// hay datos, agrupa por mes con [_groupByMonth] y cabeceras
/// [_formatMonthHeader], y cada grupo va en una [QuarkCard]. Cada [ActivityTile]
/// eleva el detalle desde abajo con [showActivityDetail].
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activityProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundNeutralSecondary,
      appBar: QuarkPageAppBar.build(title: 'Actividad'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (activities) {
          if (activities.isEmpty) {
            return const QuarkEmptyState(
              icon: Icons.history_outlined,
              title: 'Sin actividad aún',
              description:
                  'Acá vas a ver las credenciales que recibas y presentes.',
            );
          }

          final groups = _groupByMonth(activities);
          final months = groups.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
            itemCount: months.length,
            itemBuilder: (context, i) {
              final month = months[i];
              final items = groups[month]!;
              return Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                      child: Text(
                        _formatMonthHeader(month),
                        style: const TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textNeutralSecondary,
                        ),
                      ),
                    ),
                    QuarkCard(
                      child: Column(
                        children: [
                          for (var j = 0; j < items.length; j++) ...[
                            if (j > 0)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                indent: 16,
                                color: AppColors.borderNeutral,
                              ),
                            ActivityTile(
                              activity: items[j],
                              onTap: () =>
                                  showActivityDetail(context, items[j]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Agrupa actividades por clave `aaaa-mm` (orden global por fecha descendente).
  Map<String, List<Activity>> _groupByMonth(List<Activity> activities) {
    final sorted = [...activities]..sort((a, b) => b.date.compareTo(a.date));
    final groups = <String, List<Activity>>{};
    for (final activity in sorted) {
      final key =
          '${activity.date.year}-${activity.date.month.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(activity);
    }
    return groups;
  }

  /// Convierte la clave `aaaa-mm` en encabezado legible ("Enero 2026", etc.).
  String _formatMonthHeader(String key) {
    final parts = key.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${months[month]} $year';
  }
}
