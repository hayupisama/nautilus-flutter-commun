import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Bouton principal accessible : cible >= 48 dp, libellé Semantics en français,
/// texte agrandissable (retour à la ligne, pas de troncature) et indicateur
/// de focus clavier explicite (contour de [NautilusTokens.focusRingWidth] dp
/// dans la couleur de texte du thème, séparé du bouton par
/// [NautilusTokens.focusRingGap] dp ; surcroît de 5 dp par côté, toujours réservé).
class NautilusButton extends StatefulWidget {
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

  /// Clé du contour de focus (utile aux tests).
  static const focusRingKey = ValueKey<String>('nautilus-button-focus-ring');

  @override
  State<NautilusButton> createState() => _NautilusButtonState();
}

class _NautilusButtonState extends State<NautilusButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final ringColor = Theme.of(context).colorScheme.onSurface;
    final text = Text(widget.label, textAlign: TextAlign.center);
    const gap = NautilusTokens.focusRingGap;
    const radius = NautilusTokens.radius + gap + NautilusTokens.focusRingWidth;
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (value) => setState(() => _focused = value),
        child: DecoratedBox(
          key: NautilusButton.focusRingKey,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: _focused ? ringColor : const Color(0x00000000),
              width: NautilusTokens.focusRingWidth,
            ),
          ),
          child: Padding(
            // La bordure d'un DecoratedBox ne réserve pas d'espace : on décale
            // le bouton de (contour + espace) pour que le contour soit entier.
            padding: const EdgeInsets.all(gap + NautilusTokens.focusRingWidth),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: NautilusTokens.minTapTarget,
                minHeight: NautilusTokens.minTapTarget,
              ),
              child: widget.icon == null
                  ? FilledButton(onPressed: widget.onPressed, child: text)
                  : FilledButton.icon(
                      onPressed: widget.onPressed,
                      icon: Icon(widget.icon),
                      label: text,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
