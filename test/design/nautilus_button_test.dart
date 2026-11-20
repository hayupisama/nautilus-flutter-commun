import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nautilus_commun/nautilus_commun.dart';

import '../support/accessibility.dart';

const _longLabel = 'Réserver une course accessible maintenant';

Border _ringBorder(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.byKey(NautilusButton.focusRingKey),
  );
  return (box.decoration as BoxDecoration).border! as Border;
}

void main() {
  for (final v in allVariants) {
    for (final withIcon in [false, true]) {
      final suffix = withIcon ? 'avec icône' : 'sans icône';
      group('NautilusButton (${v.name}, $suffix)', () {
        Widget button({double textScale = 1}) => harness(
          NautilusButton(
            label: 'Réserver une course',
            icon: withIcon ? Icons.directions_car : null,
            onPressed: () {},
          ),
          variant: v,
          textScale: textScale,
        );

        testWidgets("respecte les guidelines d'accessibilité", (tester) async {
          await tester.pumpWidget(button());
          await expectMeetsAccessibilityGuidelines(tester);
        });

        testWidgets('guidelines à 200 % de taille de texte', (tester) async {
          await tester.pumpWidget(button(textScale: 2));
          expect(tester.takeException(), isNull);
          await expectMeetsAccessibilityGuidelines(tester);
        });

        testWidgets('focus clavier : contour visible et distinct', (
          tester,
        ) async {
          await tester.pumpWidget(button());
          final scheme = NautilusTheme.forVariant(v).colorScheme;
          final before = _ringBorder(tester);
          expect(before.top.color.a, 0, reason: 'pas de contour sans focus');

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(
            FocusManager.instance.primaryFocus?.context
                ?.findAncestorWidgetOfExactType<NautilusButton>(),
            isNotNull,
            reason: 'Tab donne le focus au bouton',
          );
          final after = _ringBorder(tester);
          expect(after.top.color, scheme.onSurface);
          expect(after.top.width, greaterThanOrEqualTo(2));
          expect(after, isNot(equals(before)));
          // WCAG 1.4.11 : contour >= 3:1 contre le fond adjacent.
          expect(
            contrastRatio(after.top.color, scheme.surface),
            greaterThanOrEqualTo(3),
          );

          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pump();
          expect(_ringBorder(tester), equals(before));
        });

        testWidgets('texte à 200 % : le libellé passe à la ligne', (
          tester,
        ) async {
          Future<Size> labelSize(double scale) async {
            await tester.pumpWidget(
              harness(
                SizedBox(
                  width: 260,
                  child: NautilusButton(
                    label: _longLabel,
                    icon: withIcon ? Icons.directions_car : null,
                    onPressed: () {},
                  ),
                ),
                variant: v,
                textScale: scale,
              ),
            );
            expect(tester.takeException(), isNull);
            return tester.getSize(find.text(_longLabel));
          }

          final normal = await labelSize(1);
          final large = await labelSize(2);
          expect(large.height, greaterThan(normal.height * 2.5));
          expect(find.text(_longLabel), findsOneWidget);
        });

        testWidgets(
          "sémantique : un seul nœud bouton, tap déclenche l'action",
          (tester) async {
            final handle = tester.ensureSemantics();
            try {
              var taps = 0;
              await tester.pumpWidget(
                harness(
                  NautilusButton(
                    label: 'Valider',
                    icon: withIcon ? Icons.check : null,
                    onPressed: () => taps++,
                  ),
                  variant: v,
                ),
              );
              final nodes = find.semantics.byLabel('Valider');
              expect(nodes, findsOneWidget);
              final node = tester.getSemantics(find.byType(NautilusButton));
              expect(node.label, 'Valider');
              expect(node.flagsCollection.isButton, isTrue);
              expect(node.flagsCollection.isEnabled, Tristate.isTrue);
              expect(node.childrenCount, 0, reason: 'excludeSemantics');
              tester.semantics.tap(nodes);
              expect(taps, 1);
            } finally {
              handle.dispose();
            }
          },
        );
      });
    }
  }

  testWidgets('cible >= 48 dp portée par NautilusButton, pas par le thème', (
    tester,
  ) async {
    // Thème sans aucune contrainte de taille : seul NautilusButton garantit 48 dp.
    await tester.pumpWidget(
      MaterialApp(
        theme: NautilusTheme.light.copyWith(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        home: Scaffold(
          body: Center(
            child: NautilusButton(label: 'Ok', onPressed: () {}),
          ),
        ),
      ),
    );
    final size = tester.getSize(find.byType(FilledButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  group('géométrie et rendu du contour de focus', () {
    for (final v in allVariants) {
      testWidgets('${v.name} : 3 dp de contour, 2 dp d espace, cible >= 48', (
        tester,
      ) async {
        await tester.pumpWidget(
          harness(
            NautilusButton(label: 'Valider', onPressed: () {}),
            variant: v,
          ),
        );
        final ring = tester.getRect(find.byKey(NautilusButton.focusRingKey));
        final btn = tester.getRect(find.byType(FilledButton));
        const expected =
            NautilusTokens.focusRingGap + NautilusTokens.focusRingWidth;
        expect(btn.left - ring.left, expected);
        expect(ring.right - btn.right, expected);
        expect(btn.top - ring.top, expected);
        expect(ring.bottom - btn.bottom, expected);
        expect(_ringBorder(tester).top.width, 3);
        expect(btn.width, greaterThanOrEqualTo(48));
        expect(btn.height, greaterThanOrEqualTo(48));
      });

      testWidgets('${v.name} : contour peint en entier, espace de 2 dp libre', (
        tester,
      ) async {
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: harness(
              NautilusButton(label: 'Valider', onPressed: () {}),
              variant: v,
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final scheme = NautilusTheme.forVariant(v).colorScheme;
        final ring = tester.getRect(find.byKey(NautilusButton.focusRingKey));
        final btn = tester.getRect(find.byType(FilledButton));
        final image = await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final img = await boundary.toImage();
          final bytes = (await img.toByteData())!;
          return (img.width, bytes);
        });
        final (w, bytes) = image!;
        Color at(double x, double y) {
          final o = ((y.floor() * w) + x.floor()) * 4;
          return Color.fromARGB(
            bytes.getUint8(o + 3),
            bytes.getUint8(o),
            bytes.getUint8(o + 1),
            bytes.getUint8(o + 2),
          );
        }

        bool same(Color a, Color b) =>
            (a.r - b.r).abs() < 0.02 &&
            (a.g - b.g).abs() < 0.02 &&
            (a.b - b.b).abs() < 0.02;
        final x =
            ring.center.dx; // bord haut : y entier, pas de flou horizontal
        // Contour : 3 dp pleins (échantillons au centre de chaque dp).
        for (final dx in [0.5, 1.5, 2.5]) {
          expect(
            same(at(x, ring.top + dx), scheme.onSurface),
            isTrue,
            reason: 'contour à $dx dp du bord',
          );
        }
        // Espace : 2 dp de fond de page entre contour et bouton.
        for (final dx in [3.5, 4.5]) {
          expect(
            same(at(x, ring.top + dx), scheme.surface),
            isTrue,
            reason: 'espace à $dx dp du bord',
          );
        }
        // Bouton : commence juste après l'espace.
        expect(same(at(x, btn.top + 6), scheme.surface), isFalse);
        // WCAG 1.4.11 : contour / fond >= 3:1.
        expect(
          contrastRatio(scheme.onSurface, scheme.surface),
          greaterThanOrEqualTo(3),
        );
      });
    }
  });

  testWidgets('libellé sémantique distinct du texte visible', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        harness(
          NautilusButton(
            label: 'Ok',
            semanticLabel: 'Confirmer la réservation',
            onPressed: () {},
          ),
        ),
      );
      expect(find.semantics.byLabel('Confirmer la réservation'), findsOne);
      expect(find.semantics.byLabel('Ok'), findsNothing);
    } finally {
      handle.dispose();
    }
  });

  testWidgets("désactivé : pas d'action tap, aucun déclenchement", (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        harness(const NautilusButton(label: 'Valider', onPressed: null)),
      );
      final node = tester.getSemantics(find.byType(NautilusButton));
      expect(node.flagsCollection.isEnabled, Tristate.isFalse);
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      await tester.tap(find.byType(NautilusButton), warnIfMissed: false);
      await tester.pump();
    } finally {
      handle.dispose();
    }
  });

  testWidgets("appui tactile déclenche l'action une fois", (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(NautilusButton(label: 'Valider', onPressed: () => taps++)),
    );
    await tester.tap(find.byType(FilledButton));
    expect(taps, 1);
  });

  group('contrastes rendus', () {
    for (final v in allVariants) {
      testWidgets('${v.name} : texte du bouton et texte courant', (
        tester,
      ) async {
        await tester.pumpWidget(
          harness(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NautilusButton(label: 'Valider', onPressed: () {}),
                const Text('Texte courant'),
              ],
            ),
            variant: v,
          ),
        );
        Color textColor(Finder f) =>
            (tester.widget<RichText>(f).text as TextSpan).style!.color!;
        Color materialColor(Finder f) =>
            tester.widget<Material>(f.first).color!;

        final buttonText = find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(RichText),
        );
        final buttonBg = find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(Material),
        );
        expect(
          contrastRatio(textColor(buttonText), materialColor(buttonBg)),
          greaterThanOrEqualTo(4.5),
        );

        final bodyRich = find.descendant(
          of: find.text('Texte courant'),
          matching: find.byType(RichText),
        );
        final pageBg = find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Material),
        );
        expect(
          contrastRatio(textColor(bodyRich), materialColor(pageBg)),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  });
}
