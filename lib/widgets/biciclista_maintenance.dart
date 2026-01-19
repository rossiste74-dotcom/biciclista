import 'package:flutter/material.dart';

/// Widget showing bike maintenance alerts with Il Biciclista's sarcastic tone
class BiciclistaMaintenance extends StatelessWidget {
  final String? componentName;
  final double? kmRemaining;
  final bool allOk;

  const BiciclistaMaintenance({
    super.key,
    this.componentName,
    this.kmRemaining,
    this.allOk = true,
  });

  String _getMaintenanceComment() {
    if (allOk) {
      return "Per una volta la bici è in ordine. Adesso non hai più scuse per non uscire!";
    }

    if (kmRemaining == null || kmRemaining! <= 0) {
      return "Il limite è superato! Cambia subito quel componente o preparati a camminare.";
    }

    final percentage = (kmRemaining! / 1000 * 100).clamp(0, 100);
    
    if (percentage < 10) {
      return "$componentName grida aiuto! Fra poco si rompe e ti lascia a piedi... anzi, a pedali.";
    } else if (percentage < 30) {
      return "$componentName ha visto giorni migliori. Cambialo prima di ritrovarti con una sorpresa in salita.";
    } else {
      return "$componentName richiede attenzione. Non aspettare l'ultimo momento, che poi ti costa il doppio!";
    }
  }

  Color _getGradientStartColor() {
    if (allOk) return Colors.green.shade400;
    if (kmRemaining == null || kmRemaining! <= 0) return Colors.red.shade600;
    
    final percentage = (kmRemaining! / 1000 * 100).clamp(0, 100);
    if (percentage < 10) return Colors.red.shade500;
    if (percentage < 30) return Colors.orange.shade500;
    return Colors.yellow.shade600;
  }

  Color _getGradientEndColor() {
    if (allOk) return Colors.lime.shade600;
    if (kmRemaining == null || kmRemaining! <= 0) return Colors.red.shade900;
    
    final percentage = (kmRemaining! / 1000 * 100).clamp(0, 100);
    if (percentage < 10) return Colors.red.shade800;
    if (percentage < 30) return Colors.orange.shade700;
    return Colors.yellow.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final comment = _getMaintenanceComment();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getGradientStartColor(),
              _getGradientEndColor(),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allOk ? Icons.check_circle : Icons.build,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manutenzione Bici',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!allOk && componentName != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          componentName!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (kmRemaining != null && kmRemaining! > 0)
                          Text(
                            '${kmRemaining!.toStringAsFixed(0)} km rimanenti',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              '"$comment"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
