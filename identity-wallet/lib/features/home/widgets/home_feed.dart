import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../feed/home_feed_links.dart';
import '../feed/models/home_feed_action.dart';
import '../feed/models/home_feed_item.dart';
import '../feed/providers/home_feed_provider.dart';
import 'home_feed_section.dart';
import 'youtube_player_sheet.dart';

/// Feed vertical de guías / novedades / eventos sobre el panel de credenciales.
///
/// [bottomPadding] deja aire para el peek del CategoriesPanel (~120 + margen).
class HomeFeed extends ConsumerWidget {
  const HomeFeed({
    super.key,
    this.bottomPadding = 140,
  });

  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(homeFeedProvider);

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(0, 12, 0, bottomPadding),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final section = sections[index];
        return HomeFeedSectionView(
          section: section,
          onItemTap: (item) => _onItemTap(context, item),
        );
      },
    );
  }

  Future<void> _onItemTap(BuildContext context, HomeFeedItem item) async {
    switch (item.action) {
      case final HomeFeedYoutubeAction youtube:
        await showYoutubePlayerSheet(
          context,
          action: youtube,
          title: item.title,
        );
      case HomeFeedExternalUrlAction(:final uri):
        await openHomeFeedLink(context, uri);
      case HomeFeedRouteAction(:final path):
        if (context.mounted) context.push(path);
    }
  }
}
