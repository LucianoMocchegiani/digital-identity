import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/identity_shared.dart';

/// Abre un URI externo; snackbar si falla.
Future<void> openHomeFeedLink(
  BuildContext context,
  Uri uri, {
  String failMessage = 'No se pudo abrir el enlace',
}) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    showAppSnackBar(context, failMessage);
  }
}
