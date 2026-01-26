import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget showing weekly challenge with Il Biciclista's motivational sarcasm
class BiciclistaChallenge extends StatelessWidget {
  final String challengeTitle;
  final double targetValue;
  final double currentValue;
  final Map<String, String>? challengeMessages;

  const BiciclistaChallenge({
    super.key,
    required this.challengeTitle,
    required this.targetValue,
    required this.currentValue,
    this.challengeMessages,
  });

  double get progress => (currentValue / targetValue * 100).clamp(0, 100);

  String _getProgressComment() {
    if (progress == 0) {
      return challengeMessages?['start'] ?? "challenge.start".tr();
    } else if (progress < 25) {
      return challengeMessages?['quarter'] ?? "challenge.quarter".tr();
    } else if (progress < 50) {
      return challengeMessages?['half'] ?? "challenge.half".tr();
    } else if (progress < 75) {
      return challengeMessages?['quarter_left'] ?? "challenge.quarter_left".tr();
    } else if (progress < 100) {
      return challengeMessages?['almost_there'] ?? "challenge.almost_there".tr();
    } else {
      return challengeMessages?['completed'] ?? "challenge.completed".tr();
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
                    'challenge.title'.tr(),
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
