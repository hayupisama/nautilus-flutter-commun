import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Indicateur d'étape accessible (« Étape 2 sur 4 »).
///
/// - La progression est toujours donnée en texte, jamais seulement par la
///   couleur : texte « Étape X sur N », segments pleins (faites/en cours) ou
///   vides (à venir) ; l'étape en cours a un contour plus épais.
/// - Lu d'un seul bloc : « Étape 2 sur 4 : Destination ».
/// - Informatif (non interactif) ; texte agrandissable jusqu'à 200 %.
///
/// Exemple :
/// ```dart
/// NautilusStepIndicator(
///   currentStep: 2,
///   totalSteps: 4,
///   stepLabel: 'Destination',
/// )
/// ```
class NautilusStepIndicator extends StatelessWidget {
  const NautilusStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabel,
  }) : assert(totalSteps > 0),
       assert(currentStep >= 1 && currentStep <= totalSteps);

  /// Étape courante, à partir de 1.
  final int currentStep;
  final int totalSteps;

  /// Nom de l'étape courante (facultatif).
  final String? stepLabel;

  /// Texte « Étape X sur N » (visible et lu).
  String get progressText => 'Étape $currentStep sur $totalSteps';

  /// Espace insécable avant le deux-points (jamais seul en début de ligne).
  static const separator = ' : ';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final label = stepLabel == null
        ? progressText
        : '$progressText$separator$stepLabel';
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: text.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: NautilusTokens.spacing),
          Row(
            children: [
              for (var i = 1; i <= totalSteps; i++) ...[
                if (i > 1) const SizedBox(width: NautilusTokens.spacing / 2),
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: i <= currentStep ? scheme.primary : scheme.surface,
                      border: Border.all(
                        color: scheme.onSurface,
                        // Repère de forme : contour épais sur l'étape en cours.
                        width: i == currentStep ? 3 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
