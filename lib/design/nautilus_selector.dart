import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'nautilus_button.dart';
import 'nautilus_focus_ring.dart';
import 'nautilus_option_list.dart';
import 'tokens.dart';

/// Sélecteur à choix unique : une ligne de type champ qui affiche la valeur
/// choisie et ouvre une page de choix (liste + bouton « Valider le choix »).
/// À utiliser au-delà de [NautilusSelector.maxInlineOptions] options.
///
/// - Lu « Question : valeur » (ou « Aucun choix fait »), avec l'indication
///   « Appuyez pour changer / choisir ».
/// - Le choix n'est pris en compte qu'à « Valider le choix » ; « Retour » ou
///   Échap ferme sans rien changer et rend le focus au sélecteur.
class NautilusSelector<T> extends StatefulWidget {
  const NautilusSelector({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  /// Question, aussi titre de la page de choix.
  final String label;
  final List<NautilusOption<T>> options;
  final T? value;

  /// Null = désactivé.
  final ValueChanged<T>? onChanged;
  final String? helperText;
  final String? errorText;

  /// Désactivé : l'appelant explique pourquoi via [helperText].
  final bool enabled;

  /// Au-delà, le sélecteur remplace la liste affichée.
  static const maxInlineOptions = 7;
  static const emptyValue = 'Aucun choix fait';
  static const changeHint = 'Appuyez pour changer';
  static const chooseHint = 'Appuyez pour choisir';
  static const validateLabel = 'Valider le choix';
  static const backLabel = 'Retour';
  static const errorPrefix = 'Erreur : ';
  static const missingChoice = 'Choisissez une option.';

  @override
  State<NautilusSelector<T>> createState() => _NautilusSelectorState<T>();
}

class _NautilusSelectorState<T> extends State<NautilusSelector<T>> {
  static const _inset =
      NautilusTokens.focusRingGap + NautilusTokens.focusRingWidth;

  final _node = FocusNode(debugLabel: 'selector');
  bool _focused = false;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  NautilusOption<T>? get _current {
    for (final o in widget.options) {
      if (o.value == widget.value) return o;
    }
    return null;
  }

  bool get _usable => widget.enabled && widget.onChanged != null;

  Future<void> _open() async {
    if (!_usable) return;
    final result = await Navigator.of(context).push<_Choice<T>>(
      MaterialPageRoute(
        builder: (_) => _ChoicePage<T>(
          title: widget.label,
          options: widget.options,
          initial: widget.value,
        ),
      ),
    );
    if (result != null) widget.onChanged?.call(result.value);
    if (mounted) _node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = _current;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final valueText = current?.label ?? NautilusSelector.emptyValue;
    final borderColor = hasError ? scheme.error : scheme.onSurface;

    Widget pad(Widget w) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: _inset),
      child: w,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        pad(
          ExcludeSemantics(
            child: Text(widget.label, style: theme.textTheme.bodyLarge),
          ),
        ),
        const SizedBox(height: 4),
        Semantics(
          button: true,
          enabled: _usable,
          focusable: _usable,
          focused: _focused,
          excludeSemantics: true,
          label: '${widget.label} : $valueText',
          hint: current == null
              ? NautilusSelector.chooseHint
              : NautilusSelector.changeHint,
          onTap: _usable ? _open : null,
          child: Focus(
            focusNode: _node,
            canRequestFocus: _usable,
            onFocusChange: (v) => setState(() => _focused = v),
            onKeyEvent: (_, event) {
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.space ||
                      event.logicalKey == LogicalKeyboardKey.enter)) {
                _open();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: NautilusFocusRing(
              focused: _focused,
              child: InkWell(
                canRequestFocus: false,
                borderRadius: BorderRadius.circular(NautilusTokens.radius),
                onTap: _usable ? _open : null,
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: NautilusTokens.minTapTarget,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: NautilusTokens.spacing,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(NautilusTokens.radius),
                    border: Border.all(
                      color: borderColor,
                      width: hasError
                          ? 2
                          : _usable
                          ? 1.5
                          : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          valueText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: current == null
                                ? FontWeight.w400
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ExcludeSemantics(
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.helperText != null)
          pad(
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(widget.helperText!, style: theme.textTheme.bodyLarge),
            ),
          ),
        if (hasError)
          pad(
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  '${NautilusSelector.errorPrefix}${widget.errorText}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Choice<T> {
  const _Choice(this.value);
  final T value;
}

class _ChoicePage<T> extends StatefulWidget {
  const _ChoicePage({
    required this.title,
    required this.options,
    required this.initial,
  });

  final String title;
  final List<NautilusOption<T>> options;
  final T? initial;

  @override
  State<_ChoicePage<T>> createState() => _ChoicePageState<T>();
}

class _ChoicePageState<T> extends State<_ChoicePage<T>> {
  late T? _draft = widget.initial;
  bool _missing = false;

  void _close([_Choice<T>? result]) => Navigator.of(context).pop(result);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _close},
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(NautilusTokens.spacing),
                child: Row(
                  children: [
                    NautilusButton(
                      label: NautilusSelector.backLabel,
                      icon: Icons.arrow_back,
                      onPressed: _close,
                    ),
                    const SizedBox(width: NautilusTokens.spacing),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(NautilusTokens.spacing),
                  child: NautilusOptionList<T>(
                    legend: widget.title,
                    options: widget.options,
                    selected: _draft == null ? <T>{} : {_draft as T},
                    autofocus: true,
                    errorText: _missing ? NautilusSelector.missingChoice : null,
                    onChanged: (s) => setState(() {
                      _draft = s.isEmpty ? null : s.first;
                      _missing = false;
                    }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(NautilusTokens.spacing),
                child: NautilusButton(
                  label: NautilusSelector.validateLabel,
                  onPressed: () {
                    final draft = _draft;
                    if (draft == null) {
                      setState(() => _missing = true);
                    } else {
                      _close(_Choice<T>(draft));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
