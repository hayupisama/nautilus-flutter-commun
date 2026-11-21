import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'nautilus_focus_ring.dart';
import 'tokens.dart';

/// Une option de [NautilusOptionList] ou de `NautilusSelector`.
class NautilusOption<T> {
  const NautilusOption({
    required this.value,
    required this.label,
    this.helperText,
    this.enabled = true,
    this.exclusive = false,
  });

  /// Valeur métier (jamais lue par le lecteur d'écran).
  final T value;

  /// Libellé visible et lu, en français, sans « bouton » ni « case ».
  final String label;

  /// Aide de l'option (ex. « Non disponible avec ce véhicule »).
  final String? helperText;
  final bool enabled;

  /// Choix multiple : cocher cette option décoche les autres (ex. « Aucun »).
  final bool exclusive;
}

/// Liste d'options accessible : choix unique (boutons radio) ou multiple
/// (cases à cocher). Pour 2 à 7 options ; au-delà, utiliser `NautilusSelector`.
///
/// - Légende + consigne obligatoire, lues avec le groupe.
/// - Chaque ligne (>= 48 dp, pleine largeur) expose libellé et état coché ;
///   le rôle (radio ou case) vient du système.
/// - Choix unique : un seul arrêt de focus (Tab), flèches = déplacer et cocher.
///   Choix multiple : Tab par option, Espace/Entrée bascule.
/// - Focus : anneau externe ([NautilusFocusRing]).
/// - L'erreur est préfixée « Erreur : » et annoncée à son apparition.
///
/// Exemple :
/// ```dart
/// NautilusOptionList<String>(
///   legend: 'Mobilité',
///   multiple: true,
///   options: const [
///     NautilusOption(value: 'crutches', label: 'Béquilles'),
///     NautilusOption(value: 'none', label: 'Aucun', exclusive: true),
///   ],
///   selected: selected,
///   onChanged: (s) => setState(() => selected = s),
/// )
/// ```
class NautilusOptionList<T> extends StatefulWidget {
  const NautilusOptionList({
    super.key,
    required this.legend,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.multiple = false,
    this.required = false,
    this.helperText,
    this.errorText,
    this.isLoading = false,
    this.autofocus = false,
  });

  /// La question, lue en tête du groupe.
  final String legend;
  final List<NautilusOption<T>> options;

  /// Valeurs cochées (au plus une en choix unique).
  final Set<T> selected;

  /// Null = liste désactivée.
  final ValueChanged<Set<T>>? onChanged;
  final bool multiple;

  /// Ajoute « (obligatoire) » à la légende.
  final bool required;
  final String? helperText;

  /// Message d'erreur du groupe (null = aucune).
  final String? errorText;
  final bool isLoading;

  /// Donne le focus à l'option cochée (ou à la première) à l'affichage.
  final bool autofocus;

  static const singleHint = 'Choisissez une seule réponse.';
  static const multipleHint = 'Vous pouvez choisir plusieurs réponses.';
  static const requiredSuffix = '(obligatoire)';
  static const errorPrefix = 'Erreur : ';
  static const emptyText = 'Aucune option disponible pour le moment.';
  static const loadingText = 'Chargement des choix…';

  @override
  State<NautilusOptionList<T>> createState() => _NautilusOptionListState<T>();
}

class _NautilusOptionListState<T> extends State<NautilusOptionList<T>> {
  static const _inset =
      NautilusTokens.focusRingGap + NautilusTokens.focusRingWidth;

  final List<FocusNode> _nodes = [];
  int? _focusedIndex;

  @override
  void initState() {
    super.initState();
    _syncNodes();
    if (widget.autofocus && _nodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final i = _tabStop;
        if (mounted && i != null) _nodes[i].requestFocus();
      });
    }
  }

  void _syncNodes() {
    while (_nodes.length < widget.options.length) {
      _nodes.add(FocusNode(debugLabel: 'option-${_nodes.length}'));
    }
    while (_nodes.length > widget.options.length) {
      _nodes.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String? get _error => (widget.errorText == null || widget.errorText!.isEmpty)
      ? null
      : '${NautilusOptionList.errorPrefix}${widget.errorText}';

  @override
  void didUpdateWidget(NautilusOptionList<T> old) {
    super.didUpdateWidget(old);
    _syncNodes();
    final hadError = old.errorText != null && old.errorText!.isNotEmpty;
    final message = _error;
    // Flutter n'annonce pas l'apparition d'une erreur : on l'annonce (WCAG 4.1.3).
    if (message != null && (!hadError || old.errorText != widget.errorText)) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        Directionality.of(context),
        assertiveness: Assertiveness.assertive,
      );
    }
  }

  bool _canUse(int i) => widget.options[i].enabled && widget.onChanged != null;

  /// Choix unique : seul arrêt de focus du groupe (« roving focus »).
  int? get _tabStop {
    final opts = widget.options;
    for (var i = 0; i < opts.length; i++) {
      if (_canUse(i) && widget.selected.contains(opts[i].value)) return i;
    }
    for (var i = 0; i < opts.length; i++) {
      if (_canUse(i)) return i;
    }
    return null;
  }

  void _activate(int i) {
    if (!_canUse(i)) return;
    final option = widget.options[i];
    final current = widget.selected;
    final Set<T> next;
    if (!widget.multiple) {
      next = {option.value};
    } else if (current.contains(option.value)) {
      next = {...current}..remove(option.value);
    } else if (option.exclusive) {
      next = {option.value};
    } else {
      final exclusive = {
        for (final o in widget.options)
          if (o.exclusive) o.value,
      };
      next = {...current.where((v) => !exclusive.contains(v)), option.value};
    }
    widget.onChanged!(next);
  }

  int? _neighbor(int from, int step) {
    for (var i = from + step; i >= 0 && i < widget.options.length; i += step) {
      if (_canUse(i)) return i;
    }
    return null;
  }

  KeyEventResult _onKey(int i, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    int? step;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowRight) {
      step = 1;
    } else if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft) {
      step = -1;
    }
    if (step != null) {
      final target = _neighbor(i, step);
      if (target != null) {
        _nodes[target].requestFocus();
        if (!widget.multiple) _activate(target);
      }
      return KeyEventResult.handled; // ne boucle pas au bord
    }
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter) {
      _activate(i);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instruction = widget.multiple
        ? NautilusOptionList.multipleHint
        : NautilusOptionList.singleHint;
    final legend = widget.required
        ? '${widget.legend} ${NautilusOptionList.requiredSuffix}'
        : widget.legend;
    final error = _error;
    final tabStop = _tabStop;

    Widget status(String text) => Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(NautilusTokens.spacing),
        child: Text(text, style: theme.textTheme.bodyLarge),
      ),
    );

    final Widget body;
    if (widget.isLoading) {
      body = status(NautilusOptionList.loadingText);
    } else if (widget.options.isEmpty) {
      body = status(NautilusOptionList.emptyText);
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widget.options.length; i++)
            _row(context, i, tabStop),
        ],
      );
    }

    return Semantics(
      container: true,
      role: widget.multiple ? null : SemanticsRole.radioGroup,
      label: '$legend $instruction',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    legend,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(instruction, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          if (widget.helperText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(_inset, 4, _inset, 0),
              child: Text(widget.helperText!, style: theme.textTheme.bodyLarge),
            ),
          const SizedBox(height: NautilusTokens.spacing),
          body,
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _inset,
                NautilusTokens.spacing,
                _inset,
                0,
              ),
              child: Text(
                error,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, int i, int? tabStop) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final option = widget.options[i];
    final checked = widget.selected.contains(option.value);
    final usable = _canUse(i);
    final focused = _focusedIndex == i;
    final skip = !widget.multiple && i != tabStop;
    final semanticLabel = option.helperText == null
        ? option.label
        : '${option.label}. ${option.helperText}';

    // La forme (point ou coche) porte l'état, pas seulement la couleur.
    final indicator = Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: widget.multiple ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: widget.multiple ? BorderRadius.circular(4) : null,
          border: Border.all(color: scheme.onSurface, width: usable ? 1.5 : 1),
        ),
        alignment: Alignment.center,
        child: !checked
            ? null
            : widget.multiple
            ? Container(
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.check, size: 18, color: scheme.onPrimary),
              )
            : Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticLabel,
      checked: checked,
      inMutuallyExclusiveGroup: !widget.multiple,
      enabled: usable,
      focusable: usable,
      focused: focused,
      onTap: usable ? () => _activate(i) : null,
      child: Focus(
        focusNode: _nodes[i],
        canRequestFocus: usable,
        skipTraversal: skip,
        onFocusChange: (v) => setState(() {
          if (v) {
            _focusedIndex = i;
          } else if (_focusedIndex == i) {
            _focusedIndex = null;
          }
        }),
        onKeyEvent: (_, event) => _onKey(i, event),
        child: NautilusFocusRing(
          focused: focused,
          child: InkWell(
            canRequestFocus: false,
            borderRadius: BorderRadius.circular(NautilusTokens.radius),
            onTap: usable
                ? () {
                    _nodes[i].requestFocus();
                    _activate(i);
                  }
                : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: NautilusTokens.minTapTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.all(NautilusTokens.spacing),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    indicator,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option.label,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: checked
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          if (option.helperText != null)
                            Text(
                              option.helperText!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
