import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_feed_static.dart';
import '../models/home_feed_section.dart';

/// Feed de inicio. Hoy es el seed estático; mañana puede fetch + fallback.
final homeFeedProvider = Provider<List<HomeFeedSection>>((ref) {
  return buildStaticHomeFeed();
});
