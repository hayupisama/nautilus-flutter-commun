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

Version 0.2.0 (U25, U47, U48 : champ, carte, étape, `NautilusOptionList`, `NautilusSelector`) ; base 0.1.0 (U25) : `lib/design/` livré (tokens, 3 thèmes, provider Riverpod de variante, `NautilusButton` avec focus visible). Socle de tests a11y dans `test/support/accessibility.dart`. Dépendance UI : `material_ui` (BSD-3-Clause). `api/`, `auth/`, `realtime/`, `l10n/` : à venir. CI : couverte par U26.

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
- Commits : Conventional Commits.
- Mode de travail : Claude développe seul et pilote le projet en Scrum autogéré. Fouad est le client (MOA/MOE) : il supervise et teste, il ne lit pas les tickets. Processus complet : `nautilus/.claude/scrum/PROCESS.md` (à lire avant toute action sur le backlog).
- Autonomie : branches, commits, push de branches, PR, fusion après CI verte, gestion des issues et du tableau de projet sont autorisés sans demander. Demander à Fouad avant : déploiement en production, secret ou service payant, publication sur les stores, opération destructive (force push, suppression), changement de périmètre ou de règle métier du cahier des charges.
- Accessibilité WCAG 2.2 AA obligatoire sur toute interface : c'est un critère d'acceptation, pas une option.
- Données : profil de besoins = besoins fonctionnels, jamais de pathologie. Aucune donnée personnelle réelle dans le code, les tests ou les fixtures.
- Secrets : jamais dans le dépôt (même privé).
- Contrat d'API : la source de vérité est `nautilus-contrat-api`. Ne jamais modifier un client généré à la main.

## Sessions Claude Code

- Au démarrage, le dernier résumé est injecté automatiquement (hook SessionStart). Commande `/reprise` pour reprendre proprement.
- En fin de session, ou quand l'utilisateur annonce une pause : `/cloture`.
- Protocole : `.claude/sessions/_PROTOCOLE.md`. Ce dossier est réservé à Claude Code ; ne pas le mentionner dans la documentation destinée aux humains.
