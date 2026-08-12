import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity_core_dart/identity_core.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Estado visual del marco de escaneo.
enum ScanFeedback { idle, success, error }

/// Tipo de error mostrado en el badge cuando el feedback es [ScanFeedback.error].
enum ScanError { acercate, qrInvalido, qrExpirado, sinConexion }

/// Texto del badge para cada [ScanError].
String scanErrorLabel(ScanError error) => switch (error) {
      ScanError.acercate => 'Acercate un poco más.',
      ScanError.qrInvalido => 'Código QR invalido',
      ScanError.qrExpirado => 'El código QR expiró',
      ScanError.sinConexion => 'Sin conexión a internet',
    };

/// Pantalla de cámara para leer un QR y abrir el flujo de protocolo correspondiente.
///
/// Sobre la cámara en vivo ([MobileScanner]) se dibuja un overlay oscuro con una
/// ventana central limpia (256×256, radio 24) enmarcada por cuatro vértices. Cuando
/// se detecta un QR válido, los vértices pasan a verde y aparece el badge "Escaneo
/// exitoso"; tras una breve pausa se navega al flujo OID4VCI / OID4VP / DIDComm.
///
/// Normaliza el payload con [InvitationParser.canonicalizeForResolve] antes de
/// inferir el tipo (soporta `haip-vci://` y QRs mal formateados). Un solo escaneo
/// por montaje gracias a [_handled].
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

/// Estado del escáner: evita dobles navegaciones tras el primer QR válido.
class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  bool _handled = false;

  /// Controller propio: con controller externo, [MobileScanner] **no** hace
  /// stop/start en `inactive`/`resumed` (eso reiniciaba el pedido de permiso
  /// y titilaba "Necesitamos la cámara" tras tocar No permitir).
  MobileScannerController? _controller;

  /// Pantalla fija de permiso/error; el scanner no vuelve a montarse solo.
  bool _cameraBlocked = false;
  String _blockMessage =
      'Para escanear QR, activá el permiso de cámara en los ajustes del sistema.';
  bool _awaitingSettingsReturn = false;

  ScanFeedback _feedback = ScanFeedback.idle;
  ScanError _error = ScanError.qrInvalido;

  Color get _frameColor => switch (_feedback) {
        ScanFeedback.idle => AppColors.textOnDark,
        ScanFeedback.success => AppColors.scanSuccessFrame,
        ScanFeedback.error => AppColors.errorDot,
      };

  static const double _windowSize = 256;
  static const double _windowRadius = 24;
  static const double _minCodeWidthFraction = 0.15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _createController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  void _createController() {
    final controller = MobileScannerController();
    controller.addListener(_onControllerUpdate);
    _controller = controller;
  }

  void _disposeController() {
    final controller = _controller;
    if (controller == null) return;
    controller.removeListener(_onControllerUpdate);
    _controller = null;
    unawaited(controller.dispose());
  }

  void _onControllerUpdate() {
    final controller = _controller;
    if (controller == null || _cameraBlocked) return;
    final error = controller.value.error;
    if (error == null) return;

    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    setState(() {
      _cameraBlocked = true;
      _blockMessage = denied
          ? 'Para escanear QR, activá el permiso de cámara en los ajustes del sistema.'
          : 'No se pudo iniciar la cámara.';
    });
    // Sacamos el scanner del árbol en este frame; dispose del controller después.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _disposeController();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_awaitingSettingsReturn) return;
    _awaitingSettingsReturn = false;
    _retryCamera();
  }

  void _retryCamera() {
    _disposeController();
    _createController();
    setState(() => _cameraBlocked = false);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    if (capture.barcodes.isEmpty) return;

    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);

    if (raw == null || _codeTooSmall(capture)) {
      setState(() {
        _feedback = ScanFeedback.error;
        _error = ScanError.acercate;
      });
      return;
    }

    final value = InvitationParser.canonicalizeForResolve(raw);
    if (value.isEmpty) {
      setState(() {
        _feedback = ScanFeedback.error;
        _error = ScanError.qrInvalido;
      });
      return;
    }

    final type = InvitationParser.detectType(value);
    if (type == null) {
      setState(() {
        _feedback = ScanFeedback.error;
        _error = ScanError.qrInvalido;
      });
      return;
    }

    _handled = true;
    final encoded = Uri.encodeComponent(value);

    setState(() => _feedback = ScanFeedback.success);

    switch (type) {
      case InvitationType.openid4vciOffer:
        context.pushReplacement('/notifications/oid4vci?url=$encoded');
      case InvitationType.openid4vpRequest:
        context.pushReplacement('/notifications/oid4vp?url=$encoded');
      case InvitationType.didcommInvitation:
        context.pushReplacement('/notifications/didcomm?url=$encoded');
    }
  }

  bool _codeTooSmall(BarcodeCapture capture) {
    final frameWidth = capture.size.width;
    if (frameWidth <= 0) return false;

    final codeWidth = capture.barcodes
        .map((b) => b.size.width)
        .fold<double>(0, (max, w) => w > max ? w : max);
    if (codeWidth <= 0) return false;

    return codeWidth / frameWidth < _minCodeWidthFraction;
  }

  Future<void> _openSystemSettings() async {
    _awaitingSettingsReturn = true;
    await AppSettings.openAppSettings(type: AppSettingsType.settings);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final showScanner = !_cameraBlocked && controller != null;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: IdentityBottomNav.forTab(
        context,
        IdentityNavTab.scan,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: showScanner
                ? MobileScanner(
                    controller: controller,
                    onDetect: _onDetect,
                    errorBuilder: (context, error, child) =>
                        const ColoredBox(color: Colors.black),
                  )
                : _CameraPermissionGate(
                    message: _blockMessage,
                    onOpenSettings: _openSystemSettings,
                    onRetry: _retryCamera,
                  ),
          ),
          if (showScanner) ...[
            const Positioned.fill(
              child: CustomPaint(
                painter: _ScanOverlayPainter(
                  windowSize: _windowSize,
                  windowRadius: _windowRadius,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: _windowSize,
                height: _windowSize,
                child: CustomPaint(
                  painter: _ScanCornersPainter(
                    color: _frameColor,
                    radius: _windowRadius,
                  ),
                ),
              ),
            ),
            if (_feedback != ScanFeedback.idle)
              Align(
                alignment: const Alignment(0, -0.42),
                child: _ScanFeedbackBadge(feedback: _feedback, error: _error),
              ),
            const Align(
              alignment: Alignment(0, 0.62),
              child: _ScanHint(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pantalla de bloqueo cuando el permiso de cámara no está concedido.
class _CameraPermissionGate extends StatelessWidget {
  const _CameraPermissionGate({
    required this.message,
    required this.onOpenSettings,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.kuatia;
    return ColoredBox(
      color: colors.bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 48,
                color: colors.muted,
              ),
              const SizedBox(height: 16),
              Text(
                'Necesitamos la cámara',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: colors.muted,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onOpenSettings,
                child: const Text('Abrir ajustes'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  const _ScanOverlayPainter({
    required this.windowSize,
    required this.windowRadius,
  });

  final double windowSize;
  final double windowRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final window = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: windowSize,
        height: windowSize,
      ),
      Radius.circular(windowRadius),
    );

    final overlay = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(window)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlay,
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      oldDelegate.windowSize != windowSize ||
      oldDelegate.windowRadius != windowRadius;
}

class _ScanCornersPainter extends CustomPainter {
  const _ScanCornersPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arm = size.width * 0.2;
    final r = radius;

    canvas.drawPath(
      Path()
        ..moveTo(0, r + arm)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..lineTo(r + arm, 0),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width - r - arm, 0)
        ..lineTo(size.width - r, 0)
        ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
        ..lineTo(size.width, r + arm),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - r - arm)
        ..lineTo(size.width, size.height - r)
        ..arcToPoint(
          Offset(size.width - r, size.height),
          radius: Radius.circular(r),
        )
        ..lineTo(size.width - r - arm, size.height),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(r + arm, size.height)
        ..lineTo(r, size.height)
        ..arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r))
        ..lineTo(0, size.height - r - arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanCornersPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _ScanFeedbackBadge extends StatelessWidget {
  const _ScanFeedbackBadge({required this.feedback, required this.error});

  final ScanFeedback feedback;
  final ScanError error;

  static const _checkAsset = 'public/images/icons/Check-Circle.png';
  static const _forbiddenAsset = 'public/images/icons/Forbidden.png';

  @override
  Widget build(BuildContext context) {
    final isError = feedback == ScanFeedback.error;
    final surface = isError ? AppColors.errorSurface : AppColors.successSurface;
    final textColor = isError ? AppColors.errorText : AppColors.successText;
    final icon = isError ? _forbiddenAsset : _checkAsset;
    final label = isError ? scanErrorLabel(error) : 'Escaneo exitoso';

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 2, 8, 2),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, width: 12, height: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanHint extends StatelessWidget {
  const _ScanHint();

  static const _qrAsset = 'public/images/icons/QR Code.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(_qrAsset, width: 32, height: 32),
        const SizedBox(height: 12),
        SizedBox(
          width: 231,
          child: Text(
            'Escanear el QR para proceder a la descarga.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textOnDark,
            ),
          ),
        ),
      ],
    );
  }
}
