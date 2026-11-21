import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Anneau de focus externe commun (même motif que `NautilusButton`) :
/// contour de [NautilusTokens.focusRingWidth] dp en couleur de texte, séparé
/// du composant par [NautilusTokens.focusRingGap] dp. L'espace de l'anneau
/// (5 dp par côté) est toujours réservé pour que la mise en page ne bouge pas.
class NautilusFocusRing extends StatelessWidget {
  const NautilusFocusRing({
    super.key,
    required this.focused,
    required this.child,
    this.innerRadius = NautilusTokens.radius,
  });

  final bool focused;
  final Widget child;
  final double innerRadius;

  /// Clé de l'anneau (utile aux tests).
  static const ringKey = ValueKey<String>('nautilus-focus-ring');

  @override
  Widget build(BuildContext context) {
    const gap = NautilusTokens.focusRingGap;
    const width = NautilusTokens.focusRingWidth;
    return DecoratedBox(
      key: ringKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(innerRadius + gap + width),
        border: Border.all(
          color: focused
              ? Theme.of(context).colorScheme.onSurface
              : const Color(0x00000000),
          width: width,
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(gap + width), child: child),
    );
  }
}
