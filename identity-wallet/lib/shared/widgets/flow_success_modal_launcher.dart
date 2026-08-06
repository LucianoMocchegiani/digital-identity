import 'package:flutter/material.dart';

import 'identity_success_modal.dart';

/// Muestra [IdentitySuccessModal] una sola vez al montarse y ejecuta [onDone] al cerrarlo.
///
/// Usado al final de flujos OID4VCI/OID4VP: el scaffold queda transparente mientras
/// el modal de éxito se superpone al contenido anterior.
class FlowSuccessModalLauncher extends StatefulWidget {
  const FlowSuccessModalLauncher({
    super.key,
    required this.title,
    required this.description,
    required this.onDone,
  });

  /// Título del modal de éxito.
  final String title;

  /// Descripción bajo el título.
  final String description;

  /// Callback tras cerrar el modal (p. ej. navegar a `/home`).
  final VoidCallback onDone;

  @override
  State<FlowSuccessModalLauncher> createState() =>
      _FlowSuccessModalLauncherState();
}

class _FlowSuccessModalLauncherState extends State<FlowSuccessModalLauncher> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_shown || !mounted) return;
      _shown = true;
      await IdentitySuccessModal.show(
        context,
        title: widget.title,
        description: widget.description,
      );
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}
