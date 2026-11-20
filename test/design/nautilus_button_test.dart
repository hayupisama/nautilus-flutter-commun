import 'dart:ui' show Tristate;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nautilus_commun/nautilus_commun.dart';

import '../support/accessibility.dart';

void main() {
  for (final v in allVariants) {
    group('NautilusButton (${v.name})', () {
      testWidgets("respecte les guidelines d'accessibilité", (tester) async {
        await tester.pumpWidget(
          harness(
            NautilusButton(label: 'Réserver une course', onPressed: () {}),
            variant: v,
          ),
        );
        await expectMeetsAccessibilityGuidelines(tester);
      });

      testWidgets('guidelines à 200 % de taille de texte', (tester) async {
        await tester.pumpWidget(
          harness(
            NautilusButton(label: 'Réserver une course', onPressed: () {}),
            variant: v,
            textScale: 2,
          ),
        );
        expect(tester.takeException(), isNull);
        await expectMeetsAccessibilityGuidelines(tester);
      });
    });
  }

  testWidgets('cible tactile >= 48 x 48 dp même avec un libellé court', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(NautilusButton(label: 'Ok', onPressed: () {})),
    );
    final size = tester.getSize(find.byType(NautilusButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('texte à 200 % : libellé entier, non tronqué', (tester) async {
    const label = 'Réserver une course accessible maintenant';
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 240,
          child: NautilusButton(label: label, onPressed: () {}),
        ),
        textScale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(label), findsOneWidget);
  });

  testWidgets('sémantique : bouton, libellé français, actif', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harness(NautilusButton(label: 'Valider', onPressed: () {})),
    );
    final node = tester.getSemantics(find.byType(NautilusButton));
    expect(node.label, 'Valider');
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.flagsCollection.isEnabled, Tristate.isTrue);
    handle.dispose();
  });

  testWidgets('libellé sémantique distinct du texte visible', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harness(
        NautilusButton(
          label: 'Ok',
          semanticLabel: 'Confirmer la réservation',
          onPressed: () {},
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(NautilusButton)).label,
      'Confirmer la réservation',
    );
    handle.dispose();
  });

  testWidgets("désactivé : sémantique désactivée, pas d'action", (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      harness(const NautilusButton(label: 'Valider', onPressed: null)),
    );
    final node = tester.getSemantics(find.byType(NautilusButton));
    expect(node.flagsCollection.isEnabled, Tristate.isFalse);
    handle.dispose();
  });

  testWidgets("appui déclenche l'action", (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(NautilusButton(label: 'Valider', onPressed: () => taps++)),
    );
    await tester.tap(find.byType(NautilusButton));
    expect(taps, 1);
  });
}
