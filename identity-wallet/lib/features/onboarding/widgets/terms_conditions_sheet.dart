import 'package:flutter/material.dart';
import 'package:identity_wallet/shared/identity_shared.dart';

/// Abre el drawer (bottom sheet modal) de **Términos y Condiciones**.
///
/// Usa un scrim oscuro (negro al 60%) y deja el sheet a ~84% de la altura de
/// pantalla, con el contenido legal desplazable.
Future<void> showTermsConditionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000), // negro al 60%
    builder: (_) => const _TermsConditionsSheet(),
  );
}

/// Tipo de bloque del texto legal, para darle el formato adecuado.
enum _BlockType { paragraph, heading, bullet }

/// Un bloque del contenido legal (párrafo, encabezado o viñeta).
class _LegalBlock {
  const _LegalBlock(this.type, this.text);

  final _BlockType type;
  final String text;
}

/// Contenido legal de los Términos y Condiciones.
///
/// Aún incompleto: se irá ampliando a medida que se redacte el texto final.
const _termsBlocks = <_LegalBlock>[
  _LegalBlock(
    _BlockType.paragraph,
    'Bienvenido/a a la wallet de Identity. Estos Términos y Condiciones (en '
        'adelante, los”Términos”) y Políticas de Privacidad, rigen el uso de '
        'esta wallet de identidad autosoberana (Self-sovereign identity o SSI '
        'por sus siglas en inglés). Al usar la wallet (en adelante, “Identity '
        'wallet”), se entienden por aceptados los presentes. Si no estás de '
        'acuerdo con la descripción de los Términos, por favor, no la utilices.',
  ),
  _LegalBlock(_BlockType.heading, 'ACLARACIONES:'),
  _LegalBlock(
    _BlockType.bullet,
    'Los Términos comprenden un apartado de Políticas de Privacidad (punto 4), '
        'que describe el uso de la información.',
  ),
  _LegalBlock(
    _BlockType.bullet,
    'En estos Términos se hace mención a Identity como framework tecnológico '
        '(será únicamente “Identity” o como “Identity wallet”, de acuerdo con lo '
        'definido en el primer párrafo).',
  ),
  _LegalBlock(_BlockType.heading, 'DEFINICIONES:'),
  _LegalBlock(
    _BlockType.paragraph,
    'Identity es un framework de confianza digital descentralizado, público, no '
        'permisionado, de código abierto, extensible y capaz de interoperar con '
        'otros protocolos similares. Sigue estándares internacionales '
        'similares. Sigue estándares internacionales utilizados en frameworks',
  ),
];

/// Contenido del drawer de Términos y Condiciones: notch, encabezado y caja
/// desplazable con el texto legal.
class _TermsConditionsSheet extends StatelessWidget {
  const _TermsConditionsSheet();

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.84,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderNeutral),
            left: BorderSide(color: AppColors.borderNeutral),
            right: BorderSide(color: AppColors.borderNeutral),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _NotchHandle(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado.
                    const Text(
                      'Términos y condiciones',
                      style: TextStyle(
                        fontSize: 16,
                        height: 22 / 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textNeutralPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Revisá la información legal, privacidad y condiciones de '
                      'uso de la plataforma Identity.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 18 / 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textNeutralSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Caja con el texto legal desplazable.
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundNeutralSecondary,
                          border: Border.all(color: AppColors.borderNeutral),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const SingleChildScrollView(
                          child: _LegalText(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra superior del drawer con el "notch" (manija) centrado.
class _NotchHandle extends StatelessWidget {
  const _NotchHandle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 19,
      child: Center(
        child: Container(
          width: 100,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFF181D27).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

/// Renderiza los [_termsBlocks] con el formato según su tipo.
class _LegalText extends StatelessWidget {
  const _LegalText();

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(
      fontSize: 14,
      height: 18 / 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textNeutralPrimary,
    );

    final children = <Widget>[];
    for (var i = 0; i < _termsBlocks.length; i++) {
      final block = _termsBlocks[i];
      if (i > 0) children.add(const SizedBox(height: 12));

      switch (block.type) {
        case _BlockType.paragraph:
        case _BlockType.heading:
          children.add(Text(block.text, style: bodyStyle));
        case _BlockType.bullet:
          children.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: bodyStyle),
                Expanded(child: Text(block.text, style: bodyStyle)),
              ],
            ),
          );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
