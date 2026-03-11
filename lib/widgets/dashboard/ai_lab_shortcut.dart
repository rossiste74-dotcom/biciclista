import 'package:flutter/material.dart';

class AiLabShortcutWidget extends StatelessWidget {
  final VoidCallback onBiomechanicalTap;
  final VoidCallback onAssistantTap;

  const AiLabShortcutWidget({
    super.key,
    required this.onBiomechanicalTap,
    required this.onAssistantTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Lab - I rulli della mente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBiomechanicalTap,
                    icon: const Icon(Icons.accessibility_new),
                    label: const Text('Il Verdetto\n(Biomeccanica)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAssistantTap,
                    icon: const Icon(Icons.build),
                    label: const Text('Assistant\n(Manutenzione)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
