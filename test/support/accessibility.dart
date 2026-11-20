import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nautilus_commun/nautilus_commun.dart';

/// Ratio de contraste WCAG 2.x entre deux couleurs opaques.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Toutes les variantes de thème, pour tester chaque composant partout.
const allVariants = NautilusThemeVariant.values;

/// Affiche [child] dans une appli avec le thème et le facteur de texte voulus.
Widget harness(
  Widget child, {
  NautilusThemeVariant variant = NautilusThemeVariant.light,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: NautilusTheme.forVariant(variant),
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: app!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

/// Vérifie les 4 guidelines d'accessibilité du projet sur l'écran courant.
Future<void> expectMeetsAccessibilityGuidelines(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}
