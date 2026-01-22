import 'package:flutter/material.dart';
import '../models/terrain_analysis.dart';

/// Badge widget to display route difficulty rating
/// Shows emoji, label, and level (1-5) with color coding
class DifficultyBadge extends StatelessWidget {
  final DifficultyRating difficulty;
  final bool showLabel;
  final bool showLevel;
  final double size;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.showLabel = true,
    this.showLevel = true,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        border: Border.all(color: _getColor(), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            difficulty.emoji,
            style: TextStyle(fontSize: size),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              difficulty.label,
              style: TextStyle(
                fontSize: size * 0.75,
                fontWeight: FontWeight.bold,
                color: _getColor(),
              ),
            ),
          ],
          if (showLevel) ...[
            const SizedBox(width: 4),
            _buildStars(),
          ],
        ],
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < difficulty.level ? Icons.star : Icons.star_border,
          color: _getColor(),
          size: size * 0.75,
        );
      }),
    );
  }

  Color _getColor() {
    return Color(int.parse(difficulty.colorHex.substring(1), radix: 16) + 0xFF000000);
  }
}

/// Compact difficulty indicator - just emoji + level
class DifficultyIndicator extends StatelessWidget {
  final DifficultyRating difficulty;

  const DifficultyIndicator({
    super.key,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          difficulty.emoji,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 4),
        Text(
          '${difficulty.level}/5',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _getColor(),
          ),
        ),
      ],
    );
  }

  Color _getColor() {
    return Color(int.parse(difficulty.colorHex.substring(1), radix: 16) + 0xFF000000);
  }
}
