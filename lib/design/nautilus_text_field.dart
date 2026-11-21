import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Champ texte accessible.
///
/// - Libellé toujours visible (jamais remplacé par un texte indicatif) et lu
///   par le lecteur d'écran ; hauteur >= 48 dp ; contour >= 3:1 contre le fond.
/// - L'erreur est affichée en texte préfixé « Erreur : » (pas seulement en
///   couleur) et annoncée par le lecteur d'écran.
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
class NautilusTextField extends StatelessWidget {
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
  static const errorPrefix = 'Erreur : ';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError ? scheme.error : scheme.onSurface;
    OutlineInputBorder border(double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(NautilusTokens.radius),
      borderSide: BorderSide(color: borderColor, width: width),
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      enabled: enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(color: scheme.onSurface),
        floatingLabelStyle: TextStyle(color: borderColor),
        helperText: helperText,
        helperMaxLines: 5,
        helperStyle: TextStyle(color: scheme.onSurface),
        errorText: hasError ? '$errorPrefix$errorText' : null,
        errorMaxLines: 5,
        errorStyle: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
        constraints: const BoxConstraints(
          minHeight: NautilusTokens.minTapTarget,
        ),
        enabledBorder: border(1.5),
        disabledBorder: border(1),
        focusedBorder: border(3),
        errorBorder: border(2),
        focusedErrorBorder: border(3),
      ),
    );
  }
}
