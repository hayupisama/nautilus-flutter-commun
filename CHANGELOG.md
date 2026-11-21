## 0.2.0

* `NautilusTextField` : libellé visible, erreur en texte préfixé, cible >= 48 dp, contour >= 3:1.
* `NautilusInfoCard` : carte d'information (informative ou bouton), lue en un bloc.
* `NautilusStepIndicator` : « Étape X sur N » en texte + segments.
* Anneau de focus externe commun (`NautilusFocusRing`) pour le champ et la carte bouton ; erreur du champ annoncée au lecteur d'écran ; segment en cours distinct ; espace insécable avant les deux-points.
* Thèmes : texte de base 18 sp (titres 20 sp, boutons 18 sp gras), interligne 1,4.
* Carte bouton : `semanticLabel` obligatoire (assertion).
* Exemple d'usage : `example/components_example.dart`.

## 0.1.0

* Version initiale du design system.
* Thèmes accessibles : clair, sombre, contraste élevé (`NautilusTheme`, tokens).
* Provider Riverpod de variante de thème (`nautilusThemeVariantProvider`).
* `NautilusButton` : cible >= 48 dp, libellé Semantics, texte agrandissable à 200 %, indicateur de focus clavier (contour 3 dp + espace 2 dp, entièrement visible).
* Socle de tests d'accessibilité (`test/support/accessibility.dart`).
