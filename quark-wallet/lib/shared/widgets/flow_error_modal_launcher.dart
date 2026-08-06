import 'package:flutter/material.dart';

import 'quark_error_modal.dart';

/// Muestra [QuarkErrorModal] una sola vez al montarse y ejecuta [onClose] al cerrarlo.
///
/// Usado en flujos OID4VCI/OID4VP: el scaffold queda transparente mientras el modal
/// de error se superpone al contenido anterior.
class FlowErrorModalLauncher extends StatefulWidget {
  const FlowErrorModalLauncher({
    super.key,
    required this.title,
    required this.description,
    required this.onClose,
  });

  /// Título del modal de error.
  final String title;

  /// Descripción o detalle del error.
  final String description;

  /// Callback tras cerrar el modal (p. ej. pop o ir a home).
  final VoidCallback onClose;

  @override
  State<FlowErrorModalLauncher> createState() => _FlowErrorModalLauncherState();
}

class _FlowErrorModalLauncherState extends State<FlowErrorModalLauncher> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_shown || !mounted) return;
      _shown = true;
      await QuarkErrorModal.show(
        context,
        title: widget.title,
        description: widget.description,
      );
      if (mounted) widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}
