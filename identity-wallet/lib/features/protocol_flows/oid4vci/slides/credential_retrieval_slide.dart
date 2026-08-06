import 'package:flutter/material.dart';

/// Vista de progreso mientras [Oid4VciNotifier.accept] ejecuta [Oid4VciService.acquireCredentials].
///
/// Se muestra desde [Oid4VciNotificationScreen] cuando el estado es [Oid4VciAcquiringState].

class CredentialRetrievalSlide extends StatelessWidget {
  const CredentialRetrievalSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Obteniendo credencial...'),
          ],
        ),
      ),
    );
  }
}
