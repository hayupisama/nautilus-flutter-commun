import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme.dart';

/// Variante de thème choisie (état Riverpod). Les applis peuvent l'initialiser
/// depuis les réglages système (luminosité, contraste élevé).
class NautilusThemeVariantNotifier extends Notifier<NautilusThemeVariant> {
  @override
  NautilusThemeVariant build() => NautilusThemeVariant.light;

  void select(NautilusThemeVariant variant) => state = variant;
}

final nautilusThemeVariantProvider =
    NotifierProvider<NautilusThemeVariantNotifier, NautilusThemeVariant>(
      NautilusThemeVariantNotifier.new,
    );
