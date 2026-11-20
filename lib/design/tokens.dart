import 'package:material_ui/material_ui.dart';

/// Tokens du design system Nautilus (dimensions et couleurs de base).
abstract final class NautilusTokens {
  /// Taille minimale d'une cible tactile (WCAG 2.2 AA, 48 dp).
  static const double minTapTarget = 48;

  static const double spacing = 8;
  static const double radius = 12;

  // Thème clair
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightPrimary = Color(0xFF0B4F8A);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFB00020);

  // Thème sombre
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Color(0xFFEDEDED);
  static const Color darkPrimary = Color(0xFF9CC9F5);
  static const Color darkOnPrimary = Color(0xFF0A1929);
  static const Color darkError = Color(0xFFFFB4AB);

  // Contraste élevé (noir / blanc / jaune)
  static const Color highContrastBackground = Color(0xFF000000);
  static const Color highContrastOnBackground = Color(0xFFFFFFFF);
  static const Color highContrastPrimary = Color(0xFFFFEB3B);
  static const Color highContrastOnPrimary = Color(0xFF000000);
  static const Color highContrastError = Color(0xFFFF8A80);
}
