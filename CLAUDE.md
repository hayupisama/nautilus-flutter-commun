# CLAUDE.md — nautilus-flutter-commun

## Rôle

Package Dart/Flutter importé par `nautilus-app-passager` et `nautilus-app-chauffeur`.

```
lib/
  api/          # client Dart GÉNÉRÉ depuis nautilus-contrat-api (ne jamais éditer à la main)
  auth/         # OIDC Keycloak, Authorization Code + PKCE, stockage sécurisé des jetons
  design/       # thème (clair, sombre, contraste élevé), composants accessibles, tokens
  realtime/     # client WebSocket (position chauffeur)
  l10n/         # textes FR (seule langue au MVP), formulations simples (FALC pour les écrans clés)
```

## État

Dépôt vide. Première tâche : `flutter create --template=package --project-name nautilus_commun .`

## Règles

- Versionnement sémantique par tag git ; les applis dépendent d'un tag, jamais d'une branche.
- Chaque composant du design system est accessible par construction (Semantics, 48 dp, contraste, texte agrandissable) et a un test de widget avec les guidelines d'accessibilité.
- Régénérer le client à chaque nouvelle version du contrat ; changement cassant = version majeure.

## Règles Flutter

- Gestion d'état : Riverpod (avec génération de code si adoptée dans `nautilus-flutter-commun`).
- Composants visuels, client API, authentification : toujours depuis `nautilus-flutter-commun`. Ne pas dupliquer.
- Navigation : go_router (à confirmer dans le package commun).

## Accessibilité (critère d'acceptation)

- Chaque élément interactif a un libellé `Semantics` explicite, en français.
- Cibles tactiles >= 48 x 48 dp. Aucune action accessible uniquement par geste complexe.
- Respect de la taille de texte système jusqu'à 200 % sans perte d'information.
- Contrastes >= 4,5:1 (texte), >= 3:1 (composants). Thème sombre et contraste élevé.
- La carte n'est jamais la seule source d'information : adresse et temps d'approche en texte.
- Toute info importante en texte + son + vibration.
- Tests : `meetsGuideline(androidTapTargetGuideline)`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline` dans les tests de widgets.
- Tester sous VoiceOver et TalkBack avant de considérer un écran terminé.

## Contexte projet (commun)

- Projet : **Nautilus** (nom de code), appli VTC marketplace dédiée aux PMR, lancement à Nantes (métropole + aéroport + gare).
- Side project, développeur unique, budget quasi nul, < 5 h/semaine, démarrage janvier 2027.
- Référence fonctionnelle : `nautilus/docs/cahier-des-charges.md`. Glossaire : `nautilus/docs/glossaire.md`. Décisions transverses : `nautilus/docs/decisions.md`.
- Lot en cours : **lot 0 – prototype** avec données fictives. Objectif : un prototype fonctionnel et démontrable. La validation terrain est faite par un autre intervenant.
- Licence : PolyForm Noncommercial 1.0.0. Ne jamais ajouter de dépendance dont la licence interdit cet usage.

## Règles transverses

- Langue : identifiants de code en anglais (voir glossaire FR -> EN) ; docs, commits et messages à l'utilisateur en français.
- Commits : Conventional Commits. Ne jamais pousser ni ouvrir de PR sans accord explicite.
- Accessibilité WCAG 2.2 AA obligatoire sur toute interface : c'est un critère d'acceptation, pas une option.
- Données : profil de besoins = besoins fonctionnels, jamais de pathologie. Aucune donnée personnelle réelle dans le code, les tests ou les fixtures.
- Secrets : jamais dans le dépôt (même privé).
- Contrat d'API : la source de vérité est `nautilus-contrat-api`. Ne jamais modifier un client généré à la main.

## Sessions Claude Code

- Au démarrage, le dernier résumé est injecté automatiquement (hook SessionStart). Commande `/reprise` pour reprendre proprement.
- En fin de session, ou quand l'utilisateur annonce une pause : `/cloture`.
- Protocole : `.claude/sessions/_PROTOCOLE.md`. Ce dossier est réservé à Claude Code ; ne pas le mentionner dans la documentation destinée aux humains.
