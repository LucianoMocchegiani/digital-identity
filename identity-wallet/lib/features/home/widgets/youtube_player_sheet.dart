import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../shared/identity_shared.dart';
import '../feed/home_feed_links.dart';
import '../feed/models/home_feed_action.dart';

/// Bottom sheet con embed de YouTube + CTA para abrir en la app externa.
Future<void> showYoutubePlayerSheet(
  BuildContext context, {
  required HomeFeedYoutubeAction action,
  String? title,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _YoutubePlayerSheet(action: action, title: title),
  );
}

class _YoutubePlayerSheet extends StatefulWidget {
  const _YoutubePlayerSheet({required this.action, this.title});

  final HomeFeedYoutubeAction action;
  final String? title;

  @override
  State<_YoutubePlayerSheet> createState() => _YoutubePlayerSheetState();
}

class _YoutubePlayerSheetState extends State<_YoutubePlayerSheet> {
  late final WebViewController _controller;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(widget.action.embedUri);
  }

  Future<void> _openExternal() => openHomeFeedLink(
        context,
        widget.action.watchUri,
        failMessage: 'No se pudo abrir YouTube',
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    final height = MediaQuery.sizeOf(context).height * 0.62;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 34,
            height: 6,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title ?? 'Guía',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 22 / 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: colors.muted),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_loading)
                      ColoredBox(
                        color: colors.bg,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: IdentityOutlineButton(
                  label: 'Ver en YouTube',
                  expand: true,
                  onTap: _openExternal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
