import 'home_feed_action.dart';

/// Ítem de un carrusel del feed de inicio.
class HomeFeedItem {
  const HomeFeedItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.imageAsset,
    this.chipLabel,
    required this.action,
  });

  final String id;
  final String title;
  final String? subtitle;

  /// Imagen remota (CMS / CDN).
  final String? imageUrl;

  /// Imagen empaquetada en la app.
  final String? imageAsset;

  /// Badge opcional (ej. "Tutorial", "Festival").
  final String? chipLabel;

  final HomeFeedAction action;

  /// URL de red a mostrar si no hay [imageAsset] (incluye thumbnail de YouTube).
  String? get networkImageUrl {
    if (imageUrl != null) return imageUrl;
    final a = action;
    if (a is HomeFeedYoutubeAction) return a.thumbnailUri.toString();
    return null;
  }
}
