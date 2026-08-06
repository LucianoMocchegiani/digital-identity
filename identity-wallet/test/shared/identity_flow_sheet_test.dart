import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_wallet/shared/theme/app_colors.dart';
import 'package:identity_wallet/shared/widgets/identity_flow_sheet.dart';

void main() {
  Widget host(Widget sheet) => MaterialApp(
        home: FlowSheetScaffold(sheet: sheet),
      );

  group('IdentityFlowSheet', () {
    testWidgets('renderiza título, contenido y botones', (tester) async {
      await tester.pumpWidget(host(
        IdentityFlowSheet(
          title: 'Título del sheet',
          secondaryLabel: 'Cancelar',
          onSecondary: () {},
          primaryLabel: 'Continuar',
          onPrimary: () {},
          children: const [Text('contenido')],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Título del sheet'), findsOneWidget);
      expect(find.text('contenido'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('los botones invocan sus callbacks', (tester) async {
      var secondary = 0;
      var primary = 0;
      await tester.pumpWidget(host(
        IdentityFlowSheet(
          title: 't',
          secondaryLabel: 'Cancelar',
          onSecondary: () => secondary++,
          primaryLabel: 'Compartir',
          onPrimary: () => primary++,
          children: const [SizedBox()],
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.tap(find.text('Compartir'));
      expect(secondary, 1);
      expect(primary, 1);
    });

    testWidgets('onPrimary null deshabilita el botón primario', (tester) async {
      await tester.pumpWidget(host(
        IdentityFlowSheet(
          title: 't',
          secondaryLabel: 'Cancelar',
          onSecondary: () {},
          primaryLabel: 'Compartir',
          onPrimary: null,
          children: const [SizedBox()],
        ),
      ));
      await tester.pumpAndSettle();

      // No debe lanzar: el tap sobre un botón deshabilitado es un no-op.
      await tester.tap(find.text('Compartir'));
      await tester.pumpAndSettle();
      expect(find.text('Compartir'), findsOneWidget);

      // Estado visual deshabilitado: el Container del botón se pinta gris.
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Compartir'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.borderNeutral);
    });

    testWidgets('con reduce-motion el contenido es visible sin animar',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: FlowSheetScaffold(
            sheet: IdentityFlowSheet(
              title: 't',
              secondaryLabel: 'Cancelar',
              onSecondary: () {},
              primaryLabel: 'Continuar',
              onPrimary: () {},
              children: const [Text('contenido')],
            ),
          ),
        ),
      ));
      // Un solo pump (sin settle): el contenido ya debe estar en opacidad 1.
      await tester.pump();

      final fade = tester.widget<FadeTransition>(
        find.ancestor(
          of: find.text('contenido'),
          matching: find.byType(FadeTransition),
        ).first,
      );
      expect(fade.opacity.value, 1.0);
    });
  });

  group('SheetFieldRow', () {
    testWidgets('muestra etiqueta y valor', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SheetFieldRow(label: 'Nombre', value: 'Juan Pérez'),
        ),
      ));
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsOneWidget);
    });

    testWidgets('omite la línea de valor cuando está vacío', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SheetFieldRow(label: 'Nombre', value: ''),
        ),
      ));
      expect(find.text('Nombre'), findsOneWidget);
      // Solo existe el Text de la etiqueta.
      expect(find.byType(Text), findsOneWidget);
    });
  });
}
