import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import 'nautilus_focus_ring.dart';
import 'tokens.dart';

/// Champ texte accessible.
///
/// - Libellé toujours visible (jamais remplacé par un texte indicatif) et lu
///   par le lecteur d'écran ; hauteur >= 48 dp ; contour >= 3:1 contre le fond.
/// - L'erreur est affichée en texte préfixé « Erreur : » (pas seulement en
///   couleur) et annoncée au lecteur d'écran quand elle apparaît.
/// - Au focus : anneau externe (comme `NautilusButton`).
/// - Désactivé ([enabled] faux) : l'appelant explique pourquoi via
///   [helperText] (ex. « Champ non modifiable »).
/// - Le texte suit la taille système jusqu'à 200 % (l'aide et l'erreur passent
///   à la ligne).
///
/// Exemple :
/// ```dart
/// NautilusTextField(
///   label: 'Adresse de départ',
///   helperText: 'Numéro et nom de rue',
///   controller: controller,
///   errorText: invalid ? 'Adresse obligatoire' : null,
/// )
/// ```
class NautilusTextField extends StatefulWidget {
  const NautilusTextField({
    super.key,
    required this.label,
    this.controller,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  /// Libellé visible et lu par le lecteur d'écran.
  final String label;
  final TextEditingController? controller;

  /// Aide à la saisie, affichée sous le champ.
  final String? helperText;

  /// Message d'erreur (null = pas d'erreur).
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Préfixe du message d'erreur.
  static const errorPrefix = 'Erreur : ';

  @override
  State<NautilusTextField> createState() => _NautilusTextFieldState();
}

class _NautilusTextFieldState extends State<NautilusTextField> {
  bool _focused = false;

  String? get _error => (widget.errorText == null || widget.errorText!.isEmpty)
      ? null
      : '${NautilusTextField.errorPrefix}${widget.errorText}';

  @override
  void didUpdateWidget(NautilusTextField old) {
    super.didUpdateWidget(old);
    final message = _error;
    final hadError = old.errorText != null && old.errorText!.isNotEmpty;
    // Flutter n'annonce pas l'apparition d'une erreur : on l'annonce (WCAG 4.1.3).
    if (message != null && (!hadError || old.errorText != widget.errorText)) {
      final view = View.of(context);
      final direction = Directionality.of(context);
      SemanticsService.sendAnnouncement(
        view,
        message,
        direction,
        assertiveness: Assertiveness.assertive,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasError = _error != null;
    final borderColor = hasError ? scheme.error : scheme.onSurface;
    OutlineInputBorder border(double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(NautilusTokens.radius),
      borderSide: BorderSide(color: borderColor, width: width),
    );
    // Le contour garde la même épaisseur au focus : c'est l'anneau externe
    // qui porte l'indicateur de focus.
    final width = hasError ? 2.0 : 1.5;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (v) => setState(() => _focused = v),
      child: NautilusFocusRing(
        focused: _focused,
        child: TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: TextStyle(color: scheme.onSurface),
          decoration: InputDecoration(
            labelText: widget.label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(color: scheme.onSurface),
            floatingLabelStyle: TextStyle(color: borderColor),
            helperText: widget.helperText,
            helperMaxLines: 5,
            helperStyle: TextStyle(color: scheme.onSurface),
            errorText: _error,
            errorMaxLines: 5,
            errorStyle: TextStyle(
              color: scheme.error,
              fontWeight: FontWeight.w600,
            ),
            constraints: const BoxConstraints(
              minHeight: NautilusTokens.minTapTarget,
            ),
            enabledBorder: border(width),
            disabledBorder: border(1),
            focusedBorder: border(width),
            errorBorder: border(2),
            focusedErrorBorder: border(2),
          ),
        ),
      ),
    );
  }
}
