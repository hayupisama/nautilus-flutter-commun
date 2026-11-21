import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Variantes de thème proposées par Nautilus.
enum NautilusThemeVariant { light, dark, highContrast }

/// Fabrique des thèmes accessibles (clair, sombre, contraste élevé).
abstract final class NautilusTheme {
  static ThemeData get light => forVariant(NautilusThemeVariant.light);
  static ThemeData get dark => forVariant(NautilusThemeVariant.dark);
  static ThemeData get highContrast =>
      forVariant(NautilusThemeVariant.highContrast);

  static ThemeData forVariant(NautilusThemeVariant variant) {
    final (brightness, bg, fg, primary, onPrimary, error) = switch (variant) {
      NautilusThemeVariant.light => (
        Brightness.light,
        NautilusTokens.lightBackground,
        NautilusTokens.lightOnBackground,
        NautilusTokens.lightPrimary,
        NautilusTokens.lightOnPrimary,
        NautilusTokens.lightError,
      ),
      NautilusThemeVariant.dark => (
        Brightness.dark,
        NautilusTokens.darkBackground,
        NautilusTokens.darkOnBackground,
        NautilusTokens.darkPrimary,
        NautilusTokens.darkOnPrimary,
        NautilusTokens.darkError,
      ),
      NautilusThemeVariant.highContrast => (
        Brightness.dark,
        NautilusTokens.highContrastBackground,
        NautilusTokens.highContrastOnBackground,
        NautilusTokens.highContrastPrimary,
        NautilusTokens.highContrastOnPrimary,
        NautilusTokens.highContrastError,
      ),
    };
    final high = variant == NautilusThemeVariant.highContrast;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      error: error,
      onError: bg,
      surface: bg,
      onSurface: fg,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      focusColor: primary,
      textTheme: _accessibleTextTheme(
        ThemeData(brightness: brightness).textTheme
            .apply(bodyColor: fg, displayColor: fg),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            NautilusTokens.minTapTarget,
            NautilusTokens.minTapTarget,
          ),
          backgroundColor: primary,
          foregroundColor: onPrimary,
          side: high ? BorderSide(color: fg, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NautilusTokens.radius),
          ),
        ),
      ),
    );
  }

  /// Tailles de base (avant le réglage système) : corps 18 sp, titres de carte
  /// 20 sp gras, boutons 18 sp gras, interligne 1,4.
  static TextTheme _accessibleTextTheme(TextTheme t) {
    TextStyle? sized(TextStyle? s, double size, [FontWeight? weight]) =>
        s?.copyWith(fontSize: size, height: 1.4, fontWeight: weight);
    return t.copyWith(
      bodyLarge: sized(t.bodyLarge, 18),
      bodyMedium: sized(t.bodyMedium, 18),
      bodySmall: sized(t.bodySmall, 16),
      titleMedium: sized(t.titleMedium, 20, FontWeight.w700),
      labelLarge: sized(t.labelLarge, 18, FontWeight.w700),
    );
  }
}
