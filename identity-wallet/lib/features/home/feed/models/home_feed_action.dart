/// Acción al tocar un ítem del feed de inicio.
sealed class HomeFeedAction {
  const HomeFeedAction();
}

/// Abre el player embebido de YouTube ([videoId]) + opción de ver en la app externa.
final class HomeFeedYoutubeAction extends HomeFeedAction {
  const HomeFeedYoutubeAction(this.videoId);

  final String videoId;

  Uri get embedUri => Uri.parse(
        'https://www.youtube-nocookie.com/embed/$videoId'
        '?playsinline=1&rel=0&modestbranding=1',
      );

  Uri get watchUri => Uri.parse('https://youtu.be/$videoId');

  /// Thumbnail oficial de YouTube (fallback si no hay imageUrl/asset).
  Uri get thumbnailUri =>
      Uri.parse('https://img.youtube.com/vi/$videoId/maxresdefault.jpg');
}

/// Abre un enlace externo (web Kuatia, evento, etc.).
final class HomeFeedExternalUrlAction extends HomeFeedAction {
  const HomeFeedExternalUrlAction(this.uri);

  final Uri uri;
}

/// Navegación interna reservada (go_router); no usada en el seed v1.
final class HomeFeedRouteAction extends HomeFeedAction {
  const HomeFeedRouteAction(this.path);

  final String path;
}
