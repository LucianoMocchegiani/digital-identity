import 'package:flutter/material.dart';

import '../widgets/onboarding_slide.dart';

/// Datos de un slide de bienvenida (ilustración + textos).
class _SlideData {
  const _SlideData({
    required this.illustrationAsset,
    required this.title,
    required this.description,
  });

  final String illustrationAsset;
  final String title;
  final String description;
}

/// Carrusel de slides de bienvenida que se muestra al inicio del onboarding,
/// antes de la creación del PIN.
///
/// Contiene un [PageView] propio con los slides de intro. El botón "Siguiente"
/// avanza entre slides y, en el último, llama a [onContinue]. El botón "Omitir"
/// salta los slides restantes invocando también [onContinue] (que en el flujo
/// lleva directo a la creación del PIN).
class WelcomeSlidesScreen extends StatefulWidget {
  const WelcomeSlidesScreen({super.key, required this.onContinue});

  /// Acción al terminar (último "Siguiente") o saltar ("Omitir") los slides.
  final VoidCallback onContinue;

  @override
  State<WelcomeSlidesScreen> createState() => _WelcomeSlidesScreenState();
}

class _WelcomeSlidesScreenState extends State<WelcomeSlidesScreen> {
  final _controller = PageController();

  /// Contenido de los slides de intro.
  static const _slides = <_SlideData>[
    _SlideData(
      illustrationAsset: 'public/images/login/Ilustración-1.png',
      title: 'Bienvenido',
      description:
          'Tu identidad digital en un solo lugar. Accedé a tus credenciales, '
          'documentos y accesos desde una experiencia simple y segura.',
    ),
    _SlideData(
      illustrationAsset: 'public/images/login/Ilustración-2.png',
      title: 'Guardá tus credenciales de forma segura',
      description:
          'Protegé tu información con tecnología segura y control total sobre '
          'tus datos personales y accesos.',
    ),
    _SlideData(
      illustrationAsset: 'public/images/login/Ilustración-3.png',
      title: 'Ingresá a edificios, oficinas y eventos',
      description:
          'Usá tus credenciales digitales para validar accesos de manera '
          'rápida, práctica y sin contacto.',
    ),
  ];

  /// Avanza al siguiente slide o, si es el último, continúa el flujo.
  void _onNext(int index) {
    if (index < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onContinue();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: _slides.length,
      itemBuilder: (context, index) {
        final slide = _slides[index];
        final isLast = index == _slides.length - 1;
        return OnboardingSlide(
          illustrationAsset: slide.illustrationAsset,
          title: slide.title,
          description: slide.description,
          stepIndex: index,
          stepCount: _slides.length,
          onNext: () => _onNext(index),
          // El último slide presenta un único CTA "¡Empezar!" (sin "Omitir").
          nextLabel: isLast ? '¡Empezar!' : 'Siguiente',
          onSkip: isLast ? null : widget.onContinue,
        );
      },
    );
  }
}
