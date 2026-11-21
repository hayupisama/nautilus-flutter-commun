## 0.2.0

* `NautilusTextField` : libellé visible, erreur en texte préfixé, cible >= 48 dp, contour >= 3:1.
* `NautilusInfoCard` : carte d'information (informative ou bouton), lue en un bloc.
* `NautilusStepIndicator` : « Étape X sur N » en texte + segments.
* Exemple d'usage : `example/components_example.dart`.

## 0.1.0

* Version initiale du design system.
* Thèmes accessibles : clair, sombre, contraste élevé (`NautilusTheme`, tokens).
* Provider Riverpod de variante de thème (`nautilusThemeVariantProvider`).
* `NautilusButton` : cible >= 48 dp, libellé Semantics, texte agrandissable à 200 %, indicateur de focus clavier (contour 3 dp + espace 2 dp, entièrement visible).
* Socle de tests d'accessibilité (`test/support/accessibility.dart`).
