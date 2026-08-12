import '../models/home_feed_action.dart';
import '../models/home_feed_item.dart';
import '../models/home_feed_section.dart';

/// Seed local del feed (contenido ficticio de demo). Sustituible por CMS.
List<HomeFeedSection> buildStaticHomeFeed() {
  return [
    const HomeFeedSection(
      id: 'guides',
      title: 'Guías rápidas',
      items: [
        HomeFeedItem(
          id: 'guide-60s',
          title: 'Tu primera credencial en 60 segundos',
          subtitle: 'Del QR a la wallet, sin vueltas',
          chipLabel: 'Tutorial',
          imageUrl:
              'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=900&q=80',
          action: HomeFeedYoutubeAction('aqz-KE-bpKQ'),
        ),
        HomeFeedItem(
          id: 'guide-age',
          title: 'Mostrá solo la edad. Nada más.',
          subtitle: 'Divulgación selectiva, explicada fácil',
          chipLabel: 'Privacidad',
          imageUrl:
              'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=900&q=80',
          action: HomeFeedYoutubeAction('aqz-KE-bpKQ'),
        ),
        HomeFeedItem(
          id: 'guide-gate',
          title: 'El QR que abre la puerta',
          subtitle: 'Presentá en un toque en el acceso',
          chipLabel: 'Tutorial',
          imageUrl:
              'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=900&q=80',
          action: HomeFeedYoutubeAction('aqz-KE-bpKQ'),
        ),
      ],
    ),
    HomeFeedSection(
      id: 'news',
      title: 'Novedades Kuatia',
      items: [
        HomeFeedItem(
          id: 'news-stadium',
          title: 'Kuatia llega a los estadios',
          subtitle: 'Membresía digital en la platea',
          chipLabel: 'Lanzamiento',
          imageUrl:
              'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=900&q=80',
          action: HomeFeedExternalUrlAction(
            Uri.parse('https://kuatia.xyz'),
          ),
        ),
        HomeFeedItem(
          id: 'news-console',
          title: 'Emití desde la consola en un click',
          subtitle: 'Ofertas OID4VCI listas para compartir',
          chipLabel: 'Producto',
          imageUrl:
              'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=900&q=80',
          action: HomeFeedExternalUrlAction(
            Uri.parse('https://billing.kuatia.xyz'),
          ),
        ),
        HomeFeedItem(
          id: 'news-privacy',
          title: 'Vos elegís qué compartir',
          subtitle: 'Menos datos, misma confianza',
          chipLabel: 'Producto',
          imageUrl:
              'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=900&q=80',
          action: HomeFeedExternalUrlAction(
            Uri.parse('https://kuatia.xyz'),
          ),
        ),
      ],
    ),
    HomeFeedSection(
      id: 'events',
      title: 'Esta semana con Kuatia',
      items: [
        HomeFeedItem(
          id: 'event-norte',
          title: 'Club Norte · Temporada 2026',
          subtitle: 'Entrada y socio en la misma wallet',
          chipLabel: 'Fútbol',
          imageUrl:
              'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=900&q=80',
          action: HomeFeedExternalUrlAction(
            Uri.parse('https://kuatia.xyz'),
          ),
        ),
        HomeFeedItem(
          id: 'event-lolla',
          title: 'Lolla BA · Acceso sin papel',
          subtitle: 'Ticket digital en el control',
          chipLabel: 'Festival',
          imageUrl:
              'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=900&q=80',
          action: HomeFeedExternalUrlAction(
            Uri.parse('https://kuatia.xyz'),
          ),
        ),
        HomeFeedItem(
          id: 'event-kuatia-night',
          title: 'Kuatia Night · After tech',
          subtitle: 'Credencial de invitado en la puerta',
          chipLabel: 'Meetup',
          imageUrl:
              'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=900&q=80',
          action: HomeFeedExternalUrlAction(
            Uri.parse('https://kuatia.xyz'),
          ),
        ),
      ],
    ),
  ];
}
