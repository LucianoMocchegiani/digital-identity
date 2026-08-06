import 'package:flutter/material.dart';

/// Anima la entrada de un elemento de lista con un *slide-up* escalonado.
///
/// El hijo entra desde [offsetY] px por debajo de su posición final hasta 0,
/// con opacidad 0 → 1, durante [duration] y curva [Curves.easeOut]. El desfase
/// en cascada se controla con [index]: cada elemento arranca [stagger] después
/// del anterior.
///
/// Replica la "Slide Up Animation" del diseño (translateY 80 → 0, opacidad
/// 0 → 100%, 300ms ease-out). Respeta reduce-motion: con animaciones
/// deshabilitadas muestra el hijo directo, sin animar.
class StaggeredSlideIn extends StatefulWidget {
  const StaggeredSlideIn({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.stagger = const Duration(milliseconds: 60),
    this.offsetY = 80,
  });

  /// Posición del elemento en la lista (0-based); define el desfase en cascada.
  final int index;

  /// Contenido a animar (ej. una `CredentialCard`).
  final Widget child;

  /// Duración del slide-up de cada elemento.
  final Duration duration;

  /// Desfase entre la entrada de un elemento y el siguiente.
  final Duration stagger;

  /// Desplazamiento vertical inicial en píxeles (entra desde abajo).
  final double offsetY;

  @override
  State<StaggeredSlideIn> createState() => _StaggeredSlideInState();
}

class _StaggeredSlideInState extends State<StaggeredSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    // Arranca tras el desfase correspondiente a la posición del elemento.
    Future.delayed(widget.stagger * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return widget.child;

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - _curve.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
