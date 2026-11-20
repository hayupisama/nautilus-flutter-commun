import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nautilus_commun/nautilus_commun.dart';

import '../support/accessibility.dart';

void main() {
  group('contrastes des thèmes (WCAG 2.2 AA)', () {
    for (final v in allVariants) {
      test('${v.name} : texte >= 4,5:1 et composants >= 3:1', () {
        final s = NautilusTheme.forVariant(v).colorScheme;
        expect(
          contrastRatio(s.onSurface, s.surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(s.onPrimary, s.primary),
          greaterThanOrEqualTo(4.5),
        );
        expect(contrastRatio(s.error, s.surface), greaterThanOrEqualTo(4.5));
        // Le bouton doit se distinguer du fond (composant d'interface).
        expect(contrastRatio(s.primary, s.surface), greaterThanOrEqualTo(3));
      });
    }

    test('contraste élevé : au moins 7:1 (AAA)', () {
      final s = NautilusTheme.highContrast.colorScheme;
      expect(contrastRatio(s.onSurface, s.surface), greaterThanOrEqualTo(7));
      expect(contrastRatio(s.onPrimary, s.primary), greaterThanOrEqualTo(7));
    });
  });

  test('luminosités : clair, sombre, contraste élevé sombre', () {
    expect(NautilusTheme.light.brightness, Brightness.light);
    expect(NautilusTheme.dark.brightness, Brightness.dark);
    expect(NautilusTheme.highContrast.brightness, Brightness.dark);
  });

  test('provider Riverpod de variante de thème', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(nautilusThemeVariantProvider), NautilusThemeVariant.light);
    c
        .read(nautilusThemeVariantProvider.notifier)
        .select(NautilusThemeVariant.highContrast);
    expect(
      c.read(nautilusThemeVariantProvider),
      NautilusThemeVariant.highContrast,
    );
  });
}
