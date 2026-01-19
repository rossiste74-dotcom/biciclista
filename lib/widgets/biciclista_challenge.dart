import 'package:flutter/material.dart';

/// Widget showing weekly challenge with Il Biciclista's motivational sarcasm
class BiciclistaChallenge extends StatelessWidget {
  final String challengeTitle;
  final double targetValue;
  final double currentValue;

  const BiciclistaChallenge({
    super.key,
    required this.challengeTitle,
    required this.targetValue,
    required this.currentValue,
  });

  double get progress => (currentValue / targetValue * 100).clamp(0, 100);

  String _getProgressComment() {
    if (progress == 0) {
      return "Ancora niente? La settimana fugge, muoviti!";
    } else if (progress < 25) {
      return "Appena iniziato! Dai che la strada è ancora lunga.";
    } else if (progress < 50) {
      return "Un quarto fatto. Continua così, ma senza mollare adesso!";
    } else if (progress < 75) {
      return "A metà! Adesso non mollare proprio sul più bello.";
    } else if (progress < 100) {
      return "Quasi arrivato! Manca poco, stringi i denti!";
    } else {
      final messages = [
        "Complimenti! Vedi che quando ti impegni?",
        "Ce l'hai fatta! Ora riposa... o fai il bis!",
        "Obiettivo raggiunto! Adesso però non montarti la testa.",
      ];
      return messages[DateTime.now().second % messages.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    final comment = _getProgressComment();
    final completed = progress >= 100;

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
            colors: completed
                ? [Colors.green.shade500, Colors.lime.shade700]
                : [Colors.lightGreen.shade400, Colors.lime.shade600],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  completed ? Icons.emoji_events : Icons.flag,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sfida della Settimana',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              challengeTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 12,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentValue.toStringAsFixed(0)} / ${targetValue.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
