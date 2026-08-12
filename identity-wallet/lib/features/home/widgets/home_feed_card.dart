import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';
import '../feed/models/home_feed_action.dart';
import '../feed/models/home_feed_item.dart';

/// Slide hero: imagen full-bleed, degradé, badge, título y CTA.
class HomeFeedCard extends StatelessWidget {
  const HomeFeedCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final HomeFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final isYoutube = item.action is HomeFeedYoutubeAction;

    return Material(
      color: colors.ink,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _FeedImage(item: item),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0x99000000),
                    Color(0xE6000000),
                  ],
                  stops: [0, 0.35, 0.7, 1],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.chipLabel != null) ...[
                    _Badge(label: item.chipLabel!),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      height: 24 / 20,
                      fontWeight: FontWeight.w700,
                      color: colors.textOnDark,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 17 / 13,
                        fontWeight: FontWeight.w400,
                        color: colors.textOnDark.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _CtaButton(
                    label: isYoutube ? 'VER AHORA' : 'ABRIR',
                    icon: isYoutube
                        ? Icons.play_arrow_rounded
                        : Icons.open_in_new_rounded,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.ink.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w600,
          color: colors.textOnDark,
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: colors.textOnDark),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: colors.textOnDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedImage extends StatelessWidget {
  const _FeedImage({required this.item});

  final HomeFeedItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final asset = item.imageAsset;
    final network = item.networkImageUrl;

    final Widget image;
    if (asset != null) {
      image = Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(colors),
      );
    } else if (network != null) {
      image = Image.network(
        network,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(colors),
      );
    } else {
      image = _placeholder(colors);
    }

    return ColoredBox(color: colors.ink, child: image);
  }

  Widget _placeholder(KuatiaColors colors) {
    return Center(
      child: Icon(Icons.image_outlined, color: colors.muted, size: 36),
    );
  }
}
