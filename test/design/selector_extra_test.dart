import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nautilus_commun/nautilus_commun.dart';

import '../support/accessibility.dart';

const _five = <NautilusOption<String>>[
  NautilusOption(value: 'a', label: 'Premier critère de classement'),
  NautilusOption(value: 'b', label: 'Deuxième critère de classement'),
  NautilusOption(value: 'c', label: 'Troisième critère de classement'),
  NautilusOption(value: 'd', label: 'Quatrième critère de classement'),
  NautilusOption(value: 'e', label: 'Cinquième critère de classement'),
];

const _transfer = <NautilusOption<String>>[
  NautilusOption(value: 'alone', label: 'Peut passer seul'),
  NautilusOption(value: 'help', label: 'Besoin d’aide'),
];

const _emptyLabel = 'Transfert : Aucun choix fait';

class _Host extends StatefulWidget {
  const _Host();
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String? value;
  @override
  Widget build(BuildContext context) => NautilusSelector<String>(
    label: 'Transfert',
    options: _transfer,
    value: value,
    onChanged: (v) => setState(() => value = v),
  );
}

Finder _focusedRing() => find.byWidgetPredicate(
  (w) =>
      w is DecoratedBox &&
      w.key == NautilusFocusRing.ringKey &&
      ((w.decoration as BoxDecoration).border! as Border).top.color.a != 0,
);

String? _focusLabel() => FocusManager.instance.primaryFocus?.debugLabel;

void main() {
  late SemanticsHandle handle;
  setUp(
    () => handle = TestWidgetsFlutterBinding.ensureInitialized()
        .ensureSemantics(),
  );
  tearDown(() => handle.dispose());

  for (final v in allVariants) {
    testWidgets('liste de 5 options à 200 % (${v.name})', (tester) async {
      await tester.pumpWidget(
        harness(
          SingleChildScrollView(
            child: NautilusOptionList<String>(
              legend: 'Critère de classement',
              options: _five,
              selected: const {'c'},
              onChanged: (_) {},
            ),
          ),
          variant: v,
          textScale: 2,
        ),
      );
      await expectMeetsAccessibilityGuidelines(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Cinquième critère de classement'), findsOneWidget);
    });

    testWidgets('page de choix (${v.name}) à 100 % et 200 %', (tester) async {
      for (final scale in [1.0, 2.0]) {
        await tester.pumpWidget(
          harness(const _Host(), variant: v, textScale: scale),
        );
        await tester.tap(find.text('Aucun choix fait'));
        await tester.pumpAndSettle();
        await expectMeetsAccessibilityGuidelines(tester);
        expect(tester.takeException(), isNull);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
      }
    });
  }

  testWidgets('espacement >= 8 dp entre deux lignes', (tester) async {
    await tester.pumpWidget(
      harness(
        SingleChildScrollView(
          child: NautilusOptionList<String>(
            legend: 'Q',
            options: _five,
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      ),
    );
    final rows = find.byType(InkWell);
    for (var i = 0; i < 4; i++) {
      final gap =
          tester.getTopLeft(rows.at(i + 1)).dy -
          tester.getBottomLeft(rows.at(i)).dy;
      expect(gap, greaterThanOrEqualTo(NautilusTokens.spacing));
    }
  });

  testWidgets('flèches haut et gauche remontent et cochent, sans boucler', (
    tester,
  ) async {
    Set<String> got = const {'e'};
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder: (context, setState) => NautilusOptionList<String>(
            legend: 'Q',
            options: _five,
            selected: got,
            onChanged: (s) => setState(() => got = s),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // option cochée
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(got, {'d'});
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(got, {'c'});
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
    }
    expect(got, {'a'});
  });

  testWidgets('aide du groupe affichée', (tester) async {
    await tester.pumpWidget(
      harness(
        NautilusOptionList<String>(
          legend: 'Q',
          helperText: 'Une aide pour le groupe',
          options: _five,
          selected: const {},
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.text('Une aide pour le groupe'), findsOneWidget);
  });

  testWidgets('action sémantique tap : ligne et sélecteur', (tester) async {
    Set<String>? got;
    await tester.pumpWidget(
      harness(
        NautilusOptionList<String>(
          legend: 'Q',
          options: _five,
          selected: const {},
          onChanged: (s) => got = s,
        ),
      ),
    );
    tester.semantics.tap(
      find.semantics.byLabel('Deuxième critère de classement'),
    );
    await tester.pump();
    expect(got, {'b'});

    await tester.pumpWidget(harness(const _Host()));
    tester.semantics.tap(find.semantics.byLabel(_emptyLabel));
    await tester.pumpAndSettle();
    expect(find.text(NautilusSelector.validateLabel), findsOneWidget);
  });

  testWidgets('indication « Appuyez pour choisir / changer »', (tester) async {
    await tester.pumpWidget(harness(const _Host()));
    expect(
      tester.getSemantics(find.bySemanticsLabel(_emptyLabel)).hint,
      NautilusSelector.chooseHint,
    );
    await tester.tap(find.text('Aucun choix fait'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Peut passer seul'));
    await tester.tap(find.text(NautilusSelector.validateLabel));
    await tester.pumpAndSettle();
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Transfert : Peut passer seul'))
          .hint,
      NautilusSelector.changeHint,
    );
  });

  testWidgets('focus : titre à l’ouverture, retour au sélecteur', (
    tester,
  ) async {
    for (final close in ['escape', 'retour']) {
      await tester.pumpWidget(harness(const _Host()));
      await tester.tap(find.text('Aucun choix fait'));
      await tester.pumpAndSettle();
      expect(_focusLabel(), 'selector-title');
      expect(_focusedRing(), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusLabel(), 'option-0');
      if (close == 'escape') {
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      } else {
        await tester.tap(find.text(NautilusSelector.backLabel));
      }
      await tester.pumpAndSettle();
      expect(find.text(NautilusSelector.validateLabel), findsNothing);
      expect(_focusLabel(), 'selector');
      expect(_focusedRing(), findsOneWidget);
    }
  });

  testWidgets('erreur du sélecteur annoncée une seule fois', (tester) async {
    final messages = <String>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (m) async {
        if (m is Map && m['type'] == 'announce') {
          messages.add((m['data'] as Map)['message'] as String);
        }
        return null;
      },
    );
    NautilusSelector<String> build(String? e) => NautilusSelector<String>(
      label: 'Transfert',
      options: _transfer,
      value: null,
      onChanged: (_) {},
      errorText: e,
    );
    await tester.pumpWidget(harness(build(null)));
    expect(messages, isEmpty);
    await tester.pumpWidget(harness(build('Choix obligatoire')));
    await tester.pumpWidget(harness(build('Choix obligatoire')));
    expect(messages, ['Erreur : Choix obligatoire']);
    await tester.pumpWidget(harness(build('Autre erreur')));
    expect(messages.length, 2);
    await tester.pumpWidget(harness(build(null)));
    expect(messages.length, 2);
  });
}
