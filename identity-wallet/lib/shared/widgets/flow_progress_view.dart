import 'package:flutter/material.dart';

/// Pantalla mínima de espera: indicador centrado y [message] bajo el mismo patrón
/// en flujos por protocolo (resolver URL, enviar presentación, DID Exchange, etc.).
class FlowProgressView extends StatelessWidget {
  const FlowProgressView({
    super.key,
    required this.message,
  });

  /// Texto bajo el [CircularProgressIndicator].
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(message),
          ],
        ),
      ),
    );
  }
}
