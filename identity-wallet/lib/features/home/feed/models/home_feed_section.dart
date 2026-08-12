import 'home_feed_item.dart';

/// Sección horizontal del feed (Guías, Novedades, Eventos, …).
class HomeFeedSection {
  const HomeFeedSection({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<HomeFeedItem> items;
}
