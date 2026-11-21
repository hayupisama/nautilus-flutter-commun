import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nautilus_commun/nautilus_commun.dart';

import '../support/accessibility.dart';

Border _ring(WidgetTester t) =>
    (t.widget<DecoratedBox>(find.byKey(NautilusFocusRing.ringKey)).decoration
                as BoxDecoration)
            .border!
        as Border;

void main() {
  group('E1 anneau de focus externe', () {
    for (final v in allVariants) {
      testWidgets('champ (${v.name})', (tester) async {
        await tester.pumpWidget(
          harness(const NautilusTextField(label: 'Nom'), variant: v),
        );
        final scheme = NautilusTheme.forVariant(v).colorScheme;
        expect(_ring(tester).top.color.a, 0);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(_ring(tester).top.color, scheme.onSurface);
        expect(_ring(tester).top.width, 3);
        expect(
          contrastRatio(_ring(tester).top.color, scheme.surface),
          greaterThanOrEqualTo(3),
        );
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .unfocus();
        await tester.pump();
        await tester.pumpAndSettle();
        expect(_ring(tester).top.color.a, 0);
      });

      testWidgets('carte bouton (${v.name})', (tester) async {
        await tester.pumpWidget(
          harness(
            NautilusInfoCard(
              title: 'A',
              body: 'B',
              semanticLabel: 'Ouvrir A',
              onTap: () {},
            ),
            variant: v,
          ),
        );
        final scheme = NautilusTheme.forVariant(v).colorScheme;
        expect(_ring(tester).top.color.a, 0);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(_ring(tester).top.color, scheme.onSurface);
        expect(_ring(tester).top.width, 3);
      });
    }

    testWidgets("carte informative : pas d'anneau", (tester) async {
      await tester.pumpWidget(
        harness(const NautilusInfoCard(title: 'A', body: 'B')),
      );
      expect(find.byKey(NautilusFocusRing.ringKey), findsNothing);
    });
  });

  group("E2 annonce de l'erreur", () {
    testWidgets("annoncée à l'apparition, pas à chaque rebuild", (
      tester,
    ) async {
      final announces = <String>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        (message) async {
          final m = message as Map;
          if (m['type'] == 'announce') {
            announces.add((m['data'] as Map)['message'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => messenger.setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
      );
      Widget field(String? e) =>
          harness(NautilusTextField(label: 'Nom', errorText: e));
      await tester.pumpWidget(field(null));
      expect(announces, isEmpty);
      await tester.pumpWidget(field('Obligatoire'));
      expect(announces, ['Erreur : Obligatoire']);
      await tester.pumpWidget(field('Obligatoire'));
      expect(announces, hasLength(1));
      await tester.pumpWidget(field(null));
      expect(announces, hasLength(1));
    });
  });

  group('E3 taille de texte de base', () {
    for (final v in allVariants) {
      test('${v.name} : corps 18 sp, titre 20 sp, interligne 1,4', () {
        final t = NautilusTheme.forVariant(v).textTheme;
        expect(t.bodyLarge!.fontSize, 18);
        expect(t.bodyMedium!.fontSize, 18);
        expect(t.titleMedium!.fontSize, 20);
        expect(t.titleMedium!.fontWeight, FontWeight.w700);
        expect(t.labelLarge!.fontSize, 18);
        expect(t.bodyLarge!.height, 1.4);
      });
    }
  });

  group('E4 segment en cours', () {
    testWidgets('contour plus épais que les autres', (tester) async {
      await tester.pumpWidget(
        harness(const NautilusStepIndicator(currentStep: 2, totalSteps: 3)),
      );
      final widths = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .map((d) => (d.border! as Border).top.width)
          .toList();
      expect(widths, [1.5, 3.0, 1.5]);
    });
  });

  group('contrastes sur les widgets rendus', () {
    for (final v in allVariants) {
      testWidgets("${v.name} : contours, segments, texte d'erreur", (
        tester,
      ) async {
        await tester.pumpWidget(
          harness(
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NautilusInfoCard(title: 'A', body: 'B'),
                NautilusStepIndicator(currentStep: 1, totalSteps: 2),
                NautilusTextField(label: 'Nom', errorText: 'Obligatoire'),
              ],
            ),
            variant: v,
          ),
        );
        final s = NautilusTheme.forVariant(v).colorScheme;
        final withBorder = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((d) => d.decoration)
            .whereType<BoxDecoration>()
            .where(
              (d) => d.border != null && (d.border! as Border).top.color.a > 0,
            );
        expect(withBorder, isNotEmpty);
        for (final d in withBorder) {
          expect(
            contrastRatio((d.border! as Border).top.color, s.surface),
            greaterThanOrEqualTo(3),
          );
        }
        // Segment plein (couleur primaire rendue) contre le fond.
        final filled = tester
            .widgetList<Container>(find.byType(Container))
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .firstWhere((d) => d.color == s.primary);
        expect(
          contrastRatio(filled.color!, s.surface),
          greaterThanOrEqualTo(3),
        );
        final err = tester.widget<Text>(find.text('Erreur : Obligatoire'));
        expect(
          contrastRatio(err.style!.color!, s.surface),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  });
}
