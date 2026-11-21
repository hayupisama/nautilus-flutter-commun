import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nautilus_commun/nautilus_commun.dart';

import '../support/accessibility.dart';

const _options = <NautilusOption<String>>[
  NautilusOption(value: 'manual', label: 'Fauteuil manuel'),
  NautilusOption(
    value: 'electric',
    label: 'Fauteuil électrique',
    helperText: 'Non disponible avec ce véhicule',
    enabled: false,
  ),
  NautilusOption(value: 'walker', label: 'Déambulateur'),
  NautilusOption(value: 'none', label: 'Aucun', exclusive: true),
];

/// Liste pilotée par un état local, pour tester les interactions.
class _Host extends StatefulWidget {
  const _Host({this.multiple = false, this.initial = const {}, this.error});
  final bool multiple;
  final Set<String> initial;
  final String? error;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late Set<String> selected = widget.initial;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: NautilusOptionList<String>(
      legend: 'Mobilité',
      options: _options,
      multiple: widget.multiple,
      selected: selected,
      errorText: widget.error,
      onChanged: (s) => setState(() => selected = s),
    ),
  );
}

class _SelectorHost extends StatefulWidget {
  const _SelectorHost({this.onChanged});
  final ValueChanged<String>? onChanged;

  @override
  State<_SelectorHost> createState() => _SelectorHostState();
}

class _SelectorHostState extends State<_SelectorHost> {
  String? value;

  @override
  Widget build(BuildContext context) => NautilusSelector<String>(
    label: 'Transfert',
    options: const [
      NautilusOption(value: 'alone', label: 'Peut passer seul'),
      NautilusOption(value: 'help', label: 'Besoin d’aide'),
      NautilusOption(value: 'no', label: 'Ne peut pas passer'),
    ],
    value: value,
    onChanged: (v) {
      setState(() => value = v);
      widget.onChanged?.call(v);
    },
  );
}

Finder _focusedRing() => find.byWidgetPredicate(
  (w) =>
      w is DecoratedBox &&
      w.key == NautilusFocusRing.ringKey &&
      ((w.decoration as BoxDecoration).border! as Border).top.color.a != 0,
);

void main() {
  group('NautilusOptionList accessibilité', () {
    for (final v in allVariants) {
      for (final scale in [1.0, 2.0]) {
        for (final multiple in [false, true]) {
          testWidgets('${multiple ? 'multiple' : 'unique'} ${v.name} x$scale', (
            tester,
          ) async {
            await tester.pumpWidget(
              harness(
                _Host(multiple: multiple, initial: const {'manual'}),
                variant: v,
                textScale: scale,
              ),
            );
            await expectMeetsAccessibilityGuidelines(tester);
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });

  group('NautilusSelector accessibilité', () {
    for (final v in allVariants) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('${v.name} x$scale', (tester) async {
          await tester.pumpWidget(
            harness(const _SelectorHost(), variant: v, textScale: scale),
          );
          await expectMeetsAccessibilityGuidelines(tester);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('page de choix ${NautilusThemeVariant.highContrast.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          const _SelectorHost(),
          variant: NautilusThemeVariant.highContrast,
          textScale: 2,
        ),
      );
      await tester.tap(find.text('Aucun choix fait'));
      await tester.pumpAndSettle();
      await expectMeetsAccessibilityGuidelines(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('NautilusOptionList sémantique', () {
    testWidgets('libellé, état coché, aide et rôle', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const _Host(initial: {'manual'})));
      final checked = tester.getSemantics(find.text('Fauteuil manuel'));
      expect(checked.label, 'Fauteuil manuel');
      expect(checked.flagsCollection.isChecked == CheckedState.isTrue, isTrue);
      final other = tester.getSemantics(find.text('Déambulateur'));
      expect(other.flagsCollection.isChecked == CheckedState.isTrue, isFalse);
      final disabled = tester.getSemantics(find.text('Fauteuil électrique'));
      expect(disabled.label, contains('Non disponible avec ce véhicule'));
      expect(disabled.flagsCollection.isEnabled, Tristate.isFalse);
      expect(
        find.bySemanticsLabel('Mobilité Choisissez une seule réponse.'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('consigne multiple et « (obligatoire) »', (tester) async {
      await tester.pumpWidget(
        harness(
          NautilusOptionList<String>(
            legend: 'Aide',
            required: true,
            multiple: true,
            options: _options,
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Aide (obligatoire)'), findsOneWidget);
      expect(find.text(NautilusOptionList.multipleHint), findsOneWidget);
    });

    testWidgets('erreur préfixée avec espace insécable', (tester) async {
      await tester.pumpWidget(
        harness(const _Host(error: 'Choisissez une option.')),
      );
      expect(find.text('Erreur : Choisissez une option.'), findsOneWidget);
    });

    testWidgets('annonce de l’erreur à son apparition', (tester) async {
      final messages = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (
            m,
          ) async {
            if (m is Map && m['type'] == 'announce') {
              messages.add((m['data'] as Map)['message'] as String);
            }
            return null;
          });
      NautilusOptionList<String> build(String? e) => NautilusOptionList<String>(
        legend: 'Q',
        options: _options,
        selected: const {},
        errorText: e,
        onChanged: (_) {},
      );
      await tester.pumpWidget(harness(build(null)));
      expect(messages, isEmpty);
      await tester.pumpWidget(harness(build('Choisissez une option.')));
      expect(messages, ['Erreur : Choisissez une option.']);
    });

    testWidgets('liste vide et chargement : texte de statut', (tester) async {
      await tester.pumpWidget(
        harness(
          NautilusOptionList<String>(
            legend: 'Q',
            options: const [],
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text(NautilusOptionList.emptyText), findsOneWidget);
      await tester.pumpWidget(
        harness(
          NautilusOptionList<String>(
            legend: 'Q',
            options: _options,
            isLoading: true,
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text(NautilusOptionList.loadingText), findsOneWidget);
      expect(find.text('Déambulateur'), findsNothing);
    });
  });

  group('NautilusOptionList clavier et focus', () {
    late SemanticsHandle handle;
    setUp(
      () => handle = TestWidgetsFlutterBinding.ensureInitialized()
          .ensureSemantics(),
    );
    tearDown(() => handle.dispose());
    testWidgets('choix unique : Tab, flèches cochent, ne boucle pas, saute '
        'l’option désactivée', (tester) async {
      await tester.pumpWidget(
        harness(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(child: _Host()),
              NautilusButton(label: 'Suivant', onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedRing(), findsOneWidget);
      // Focus sur la première option, rien de coché.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(
        tester
                .getSemantics(find.text('Fauteuil manuel'))
                .flagsCollection
                .isChecked ==
            CheckedState.isTrue,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // L'option électrique est désactivée : on passe au déambulateur.
      expect(
        tester
                .getSemantics(find.text('Déambulateur'))
                .flagsCollection
                .isChecked ==
            CheckedState.isTrue,
        isTrue,
      );
      expect(_focusedRing(), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      // « Aucun » est le dernier ; pas de bouclage.
      expect(
        tester.getSemantics(find.text('Aucun')).flagsCollection.isChecked ==
            CheckedState.isTrue,
        isTrue,
      );
      // Un seul arrêt de focus : Tab quitte le groupe.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedRing(), findsNothing);
    });

    testWidgets(
      'choix multiple : Tab par option, Espace bascule, exclusivité',
      (tester) async {
        await tester.pumpWidget(harness(const _Host(multiple: true)));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab); // saute le désactivé
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        bool checked(String l) =>
            tester.getSemantics(find.text(l)).flagsCollection.isChecked ==
            CheckedState.isTrue;
        expect(checked('Fauteuil manuel'), isTrue);
        expect(checked('Déambulateur'), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(
          LogicalKeyboardKey.space,
        ); // « Aucun » exclusif
        await tester.pump();
        expect(checked('Aucun'), isTrue);
        expect(checked('Fauteuil manuel'), isFalse);
        expect(checked('Déambulateur'), isFalse);
        await tester.sendKeyEvent(LogicalKeyboardKey.space); // décoche
        await tester.pump();
        expect(checked('Aucun'), isFalse);
      },
    );

    testWidgets('appui sur une ligne : coche et donne le focus', (
      tester,
    ) async {
      await tester.pumpWidget(harness(const _Host(multiple: true)));
      await tester.tap(find.text('Déambulateur'));
      await tester.pump();
      expect(_focusedRing(), findsOneWidget);
    });

    testWidgets('option désactivée : appui sans effet', (tester) async {
      await tester.pumpWidget(harness(const _Host()));
      await tester.tap(find.text('Fauteuil électrique'));
      await tester.pump();
      expect(
        tester
                .getSemantics(find.text('Fauteuil électrique'))
                .flagsCollection
                .isChecked ==
            CheckedState.isTrue,
        isFalse,
      );
    });
  });

  group('NautilusSelector comportement', () {
    testWidgets('rien choisi puis choix validé', (tester) async {
      final handle = tester.ensureSemantics();
      String? got;
      await tester.pumpWidget(
        harness(_SelectorHost(onChanged: (v) => got = v)),
      );
      expect(find.text('Aucun choix fait'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Transfert : Aucun choix fait'),
        findsOneWidget,
      );
      await tester.tap(find.text('Aucun choix fait'));
      await tester.pumpAndSettle();
      expect(find.text(NautilusSelector.validateLabel), findsOneWidget);
      await tester.tap(find.text('Besoin d’aide'));
      await tester.pump();
      expect(got, isNull, reason: 'pas de choix avant la validation');
      await tester.tap(find.text(NautilusSelector.validateLabel));
      await tester.pumpAndSettle();
      expect(got, 'help');
      expect(find.text('Besoin d’aide'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Transfert : Besoin d’aide'),
        findsOneWidget,
      );
      // Le focus est rendu au sélecteur.
      expect(_focusedRing(), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Valider sans choix : erreur, page reste ouverte', (
      tester,
    ) async {
      await tester.pumpWidget(harness(const _SelectorHost()));
      await tester.tap(find.text('Aucun choix fait'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(NautilusSelector.validateLabel));
      await tester.pump();
      expect(
        find.text('Erreur : ${NautilusSelector.missingChoice}'),
        findsOneWidget,
      );
    });

    testWidgets('Retour et Échap ferment sans changer le choix', (
      tester,
    ) async {
      String? got;
      await tester.pumpWidget(
        harness(_SelectorHost(onChanged: (v) => got = v)),
      );
      await tester.tap(find.text('Aucun choix fait'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Peut passer seul'));
      await tester.tap(find.text(NautilusSelector.backLabel));
      await tester.pumpAndSettle();
      expect(got, isNull);
      expect(find.text('Aucun choix fait'), findsOneWidget);

      await tester.tap(find.text('Aucun choix fait'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(got, isNull);
      expect(find.text(NautilusSelector.validateLabel), findsNothing);
    });

    testWidgets('clavier : Tab, anneau, Entrée ouvre la page', (tester) async {
      await tester.pumpWidget(harness(const _SelectorHost()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedRing(), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text(NautilusSelector.validateLabel), findsOneWidget);
      // Le focus arrive sur la première option de la page.
      expect(_focusedRing(), findsWidgets);
    });

    testWidgets('désactivé : pas d’ouverture', (tester) async {
      await tester.pumpWidget(
        harness(
          NautilusSelector<String>(
            label: 'Transfert',
            options: const [NautilusOption(value: 'a', label: 'A')],
            value: null,
            onChanged: null,
            helperText: 'Choix non modifiable',
          ),
        ),
      );
      await tester.tap(find.text('Aucun choix fait'));
      await tester.pumpAndSettle();
      expect(find.text(NautilusSelector.validateLabel), findsNothing);
      expect(find.text('Choix non modifiable'), findsOneWidget);
    });

    testWidgets('erreur affichée en texte préfixé', (tester) async {
      await tester.pumpWidget(
        harness(
          NautilusSelector<String>(
            label: 'Transfert',
            options: const [NautilusOption(value: 'a', label: 'A')],
            value: null,
            onChanged: (_) {},
            errorText: 'Choix obligatoire',
          ),
        ),
      );
      expect(find.text('Erreur : Choix obligatoire'), findsOneWidget);
    });
  });
}
