import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Bouton principal accessible : cible >= 48 dp, libellé Semantics en français,
/// texte agrandissable (retour à la ligne, pas de troncature).
class NautilusButton extends StatelessWidget {
  const NautilusButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
    this.icon,
  });

  /// Texte visible du bouton.
  final String label;

  /// Libellé lu par le lecteur d'écran, si différent du texte visible.
  final String? semanticLabel;

  /// Null = bouton désactivé.
  final VoidCallback? onPressed;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: NautilusTokens.minTapTarget,
          minHeight: NautilusTokens.minTapTarget,
        ),
        child: icon == null
            ? FilledButton(onPressed: onPressed, child: text)
            : FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: text,
              ),
      ),
    );
  }
}
