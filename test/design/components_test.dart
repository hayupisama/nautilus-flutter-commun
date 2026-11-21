import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nautilus_commun/nautilus_commun.dart';

import '../../example/components_example.dart';
import '../support/accessibility.dart';

void main() {
  final cases = <String, Widget Function()>{
    'NautilusTextField': () => const NautilusTextField(
      label: 'Adresse de départ',
      helperText: 'Numéro et nom de rue',
    ),
    'NautilusTextField (erreur)': () => const NautilusTextField(
      label: 'Adresse de départ',
      errorText: 'Adresse obligatoire',
    ),
    'NautilusInfoCard': () => const NautilusInfoCard(
      title: 'Votre chauffeur arrive',
      body: 'Arrivée dans 4 minutes, devant l\'entrée principale de la gare.',
      icon: Icons.directions_car,
    ),
    'NautilusInfoCard (bouton)': () => NautilusInfoCard(
      title: 'Votre chauffeur arrive',
      body: 'Arrivée dans 4 minutes.',
      onTap: () {},
    ),
    'NautilusStepIndicator': () => const NautilusStepIndicator(
      currentStep: 2,
      totalSteps: 4,
      stepLabel: 'Destination',
    ),
    'exemple complet': () =>
        const SingleChildScrollView(child: ComponentsExample()),
  };

  for (final v in allVariants) {
    for (final entry in cases.entries) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          '${entry.key} (${v.name}, texte ${(scale * 100).round()} %) : guidelines',
          (tester) async {
            await tester.pumpWidget(
              harness(entry.value(), variant: v, textScale: scale),
            );
            expect(tester.takeException(), isNull);
            await expectMeetsAccessibilityGuidelines(tester);
          },
        );
      }
    }
  }

  group('NautilusTextField', () {
    testWidgets('libellé visible, lu, et saisie possible', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        final c = TextEditingController();
        await tester.pumpWidget(
          harness(NautilusTextField(label: 'Prénom', controller: c)),
        );
        expect(find.text('Prénom'), findsOneWidget);
        expect(find.semantics.byLabel('Prénom'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'Awa');
        expect(c.text, 'Awa');
        final h = tester.getSize(find.byType(TextField)).height;
        expect(h, greaterThanOrEqualTo(48));
      } finally {
        handle.dispose();
      }
    });

    testWidgets('erreur en texte (pas seulement en couleur)', (tester) async {
      await tester.pumpWidget(
        harness(
          const NautilusTextField(label: 'Prénom', errorText: 'Obligatoire'),
        ),
      );
      expect(find.text('Erreur : Obligatoire'), findsOneWidget);
    });

    testWidgets('texte à 200 % : aide longue passe à la ligne', (tester) async {
      const help = 'Saisissez le numéro et le nom de la rue de départ';
      Future<double> helpHeight(double s) async {
        await tester.pumpWidget(
          harness(
            const SizedBox(
              width: 260,
              child: NautilusTextField(label: 'Adresse', helperText: help),
            ),
            textScale: s,
          ),
        );
        expect(tester.takeException(), isNull);
        return tester.getSize(find.text(help)).height;
      }

      final normal = await helpHeight(1);
      final large = await helpHeight(2);
      expect(large, greaterThan(normal * 2));
    });

    testWidgets('contour >= 3:1 dans chaque thème', (tester) async {
      for (final v in allVariants) {
        final s = NautilusTheme.forVariant(v).colorScheme;
        expect(contrastRatio(s.onSurface, s.surface), greaterThanOrEqualTo(3));
        expect(contrastRatio(s.error, s.surface), greaterThanOrEqualTo(4.5));
      }
    });
  });

  group('NautilusInfoCard', () {
    testWidgets('un seul nœud lu : titre et texte', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          harness(
            const NautilusInfoCard(
              title: 'Arrivée',
              body: 'Dans 4 minutes',
              icon: Icons.schedule,
            ),
          ),
        );
        expect(find.semantics.byLabel('Arrivée. Dans 4 minutes'), findsOne);
        final node = tester.getSemantics(find.byType(NautilusInfoCard));
        expect(node.childrenCount, 0);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('interactive : bouton >= 48 dp, tap déclenche', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        var taps = 0;
        await tester.pumpWidget(
          harness(NautilusInfoCard(title: 'A', body: 'B', onTap: () => taps++)),
        );
        final node = tester.getSemantics(find.byType(NautilusInfoCard));
        expect(node.flagsCollection.isButton, isTrue);
        expect(
          tester.getSize(find.byType(InkWell)).height,
          greaterThanOrEqualTo(48),
        );
        await tester.tap(find.byType(InkWell));
        expect(taps, 1);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('libellé sémantique personnalisé', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          harness(
            const NautilusInfoCard(
              title: 'A',
              body: 'B',
              semanticLabel: 'Information sur la course',
            ),
          ),
        );
        expect(find.semantics.byLabel('Information sur la course'), findsOne);
      } finally {
        handle.dispose();
      }
    });
  });

  group('NautilusStepIndicator', () {
    testWidgets('annonce « Étape X sur N : nom »', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          harness(
            const NautilusStepIndicator(
              currentStep: 2,
              totalSteps: 4,
              stepLabel: 'Destination',
            ),
          ),
        );
        expect(find.text('Étape 2 sur 4 : Destination'), findsOneWidget);
        expect(
          find.semantics.byLabel('Étape 2 sur 4 : Destination'),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('sans nom d\'étape', (tester) async {
      await tester.pumpWidget(
        harness(const NautilusStepIndicator(currentStep: 1, totalSteps: 3)),
      );
      expect(find.text('Étape 1 sur 3'), findsOneWidget);
    });
  });

  testWidgets('exemple : erreur affichée si adresse vide', (tester) async {
    await tester.pumpWidget(
      harness(const SingleChildScrollView(child: ComponentsExample())),
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Erreur : Adresse obligatoire'), findsOneWidget);
  });
}
