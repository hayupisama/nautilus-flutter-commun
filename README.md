# nautilus-flutter-commun

Package Flutter partagé par les applis passager et chauffeur du projet Nautilus (nom de code) :
design system accessible (thèmes, composants). Le client API généré et l'authentification viendront dans des versions ultérieures.

## Prise en main

```dart
import 'package:nautilus_commun/nautilus_commun.dart';
```

### Thèmes

Trois variantes : `NautilusTheme.light`, `NautilusTheme.dark`, `NautilusTheme.highContrast`
(ou `NautilusTheme.forVariant(variant)`). La variante choisie est un état Riverpod :

```dart
class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(nautilusThemeVariantProvider);
    return MaterialApp(theme: NautilusTheme.forVariant(variant), home: const Home());
  }
}
// Changer de variante :
// ref.read(nautilusThemeVariantProvider.notifier).select(NautilusThemeVariant.highContrast);
```

(l'application doit être enveloppée dans un `ProviderScope`).

### NautilusButton

```dart
NautilusButton(
  label: 'Réserver une course',
  semanticLabel: 'Réserver une course accessible', // optionnel
  icon: Icons.directions_car,                       // optionnel
  onPressed: () {},                                 // null = désactivé
)
```

Cible >= 48 dp, texte agrandissable, contour de focus clavier visible (3 dp, séparé du bouton par 2 dp : la zone occupée dépasse le bouton de 5 dp par côté).

### Réutiliser le socle de tests d'accessibilité

`test/support/accessibility.dart` fournit `harness` (thème + facteur de texte),
`allVariants`, `contrastRatio` et `expectMeetsAccessibilityGuidelines`
(tap targets Android/iOS, libellés, contraste du texte) :

```dart
for (final v in allVariants) {
  testWidgets('accessible (${v.name})', (tester) async {
    await tester.pumpWidget(harness(MonWidget(), variant: v, textScale: 2));
    await expectMeetsAccessibilityGuidelines(tester);
  });
}
```

## Licence

[PolyForm Noncommercial 1.0.0](LICENSE)
