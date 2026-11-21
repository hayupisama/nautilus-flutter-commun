import 'package:material_ui/material_ui.dart';
import 'package:nautilus_commun/nautilus_commun.dart';

/// Exemple d'usage : formulaire en plusieurs étapes composé des trois
/// composants (champ texte, carte d'information, indicateur d'étape).
class ComponentsExample extends StatefulWidget {
  const ComponentsExample({super.key});

  @override
  State<ComponentsExample> createState() => _ComponentsExampleState();
}

class _ComponentsExampleState extends State<ComponentsExample> {
  final _address = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NautilusTokens.spacing * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NautilusStepIndicator(
            currentStep: 1,
            totalSteps: 3,
            stepLabel: 'Départ',
          ),
          const SizedBox(height: NautilusTokens.spacing * 2),
          NautilusTextField(
            label: 'Adresse de départ',
            helperText: 'Numéro et nom de rue',
            controller: _address,
            errorText: _invalid ? 'Adresse obligatoire' : null,
          ),
          const SizedBox(height: NautilusTokens.spacing * 2),
          const NautilusInfoCard(
            title: 'Prise en charge',
            body: 'Le chauffeur vous attend devant l\'entrée principale.',
            icon: Icons.info_outline,
          ),
          const SizedBox(height: NautilusTokens.spacing * 2),
          NautilusButton(
            label: 'Continuer',
            onPressed: () => setState(() => _invalid = _address.text.isEmpty),
          ),
        ],
      ),
    );
  }
}
