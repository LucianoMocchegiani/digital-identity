import 'package:flutter/material.dart';

import '../../../shared/identity_shared.dart';
import '../feed/models/home_feed_item.dart';
import '../feed/models/home_feed_section.dart';
import 'home_feed_card.dart';

/// Sección hero: título + carrusel full-width con flechas y dots.
class HomeFeedSectionView extends StatefulWidget {
  const HomeFeedSectionView({
    super.key,
    required this.section,
    required this.onItemTap,
  });

  final HomeFeedSection section;
  final void Function(HomeFeedItem item) onItemTap;

  @override
  State<HomeFeedSectionView> createState() => _HomeFeedSectionViewState();
}

class _HomeFeedSectionViewState extends State<HomeFeedSectionView> {
  late final PageController _controller = PageController();
  var _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    final last = widget.section.items.length - 1;
    _controller.animateToPage(
      index.clamp(0, last),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final items = widget.section.items;
    if (items.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    final heroHeight = ((width - 32) * 10 / 16).clamp(188.0, 260.0);
    final multi = items.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            widget.section.title,
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: heroHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: items.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return HomeFeedCard(
                        item: item,
                        onTap: () => widget.onItemTap(item),
                      );
                    },
                  ),
                  if (multi) ...[
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          _NavArrow(
                            icon: Icons.chevron_left_rounded,
                            enabled: _index > 0,
                            onTap: () => _goTo(_index - 1),
                          ),
                          const SizedBox(width: 6),
                          _NavArrow(
                            icon: Icons.chevron_right_rounded,
                            enabled: _index < items.length - 1,
                            onTap: () => _goTo(_index + 1),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: _PageDots(
                        count: items.length,
                        index: _index,
                        color: colors.textOnDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.index,
    required this.color,
  });

  final int count;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? color : color.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return Material(
      color: colors.ink.withValues(alpha: enabled ? 0.55 : 0.28),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 22,
            color: colors.textOnDark.withValues(alpha: enabled ? 1 : 0.4),
          ),
        ),
      ),
    );
  }
}
