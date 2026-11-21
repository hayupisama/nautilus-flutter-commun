import 'package:material_ui/material_ui.dart';

import 'nautilus_focus_ring.dart';
import 'tokens.dart';

/// Carte d'information accessible (titre, texte, icône décorative facultative).
///
/// - Lue comme un seul bloc par le lecteur d'écran ([semanticLabel] si le
///   libellé doit différer du texte visible).
/// - Si [onTap] est fourni, la carte est un bouton : cible >= 48 dp, anneau de
///   focus externe (comme `NautilusButton`). Sinon elle est purement informative.
/// - Contour >= 3:1, texte qui passe à la ligne jusqu'à 200 %.
///
/// Exemple (temps d'approche en texte, jamais seulement sur la carte) :
/// ```dart
/// NautilusInfoCard(
///   title: 'Votre chauffeur arrive',
///   body: 'Arrivée dans 4 minutes, 12 rue des Lilas.',
///   icon: Icons.directions_car,
/// )
/// ```
///
/// Carte bouton :
/// ```dart
/// NautilusInfoCard(
///   title: 'Course de mardi',
///   body: 'Gare de Nantes, 14 h 30',
///   semanticLabel: 'Voir le détail de la course de mardi',
///   onTap: openDetail,
/// )
/// ```
class NautilusInfoCard extends StatefulWidget {
  const NautilusInfoCard({
    super.key,
    required this.title,
    required this.body,
    this.icon,
    this.semanticLabel,
    this.onTap,
  }) : assert(
         onTap == null || semanticLabel != null,
         "Une carte bouton doit fournir semanticLabel (verbe d'action, "
         'ex. « Voir le détail de la course »).',
       );

  final String title;
  final String body;

  /// Icône décorative (exclue de la sémantique).
  final IconData? icon;

  /// Libellé lu par le lecteur d'écran, si différent de « titre. texte ».
  final String? semanticLabel;

  /// Non null : la carte est un bouton ; [semanticLabel] est alors obligatoire
  /// et doit commencer par un verbe d'action.
  final VoidCallback? onTap;

  @override
  State<NautilusInfoCard> createState() => _NautilusInfoCardState();
}

class _NautilusInfoCardState extends State<NautilusInfoCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final interactive = widget.onTap != null;
    final radius = BorderRadius.circular(NautilusTokens.radius);
    final content = Padding(
      padding: const EdgeInsets.all(NautilusTokens.spacing * 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: scheme.onSurface),
            const SizedBox(width: NautilusTokens.spacing * 2),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: text.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: NautilusTokens.spacing / 2),
                Text(
                  widget.body,
                  style: text.bodyLarge?.copyWith(color: scheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: radius,
        border: Border.all(color: scheme.onSurface, width: 1.5),
      ),
      child: interactive
          ? InkWell(
              borderRadius: radius,
              onTap: widget.onTap,
              onFocusChange: (v) => setState(() => _focused = v),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: NautilusTokens.minTapTarget,
                ),
                child: content,
              ),
            )
          : content,
    );
    final shown = interactive
        ? NautilusFocusRing(focused: _focused, child: card)
        : card;
    // Hauteur du contenu, même sous une contrainte stricte (Expanded).
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: Semantics(
        container: true,
        button: interactive,
        label: widget.semanticLabel ?? '${widget.title}. ${widget.body}',
        excludeSemantics: true,
        onTap: widget.onTap,
        child: shown,
      ),
    );
  }
}
