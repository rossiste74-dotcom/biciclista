import 'package:flutter/material.dart';
import '../models/terrain_analysis.dart';

/// Widget to display terrain breakdown with colored progress bars
/// Shows percentage distribution of asphalt, gravel, and path surfaces
class TerrainBreakdownWidget extends StatelessWidget {
  final TerrainBreakdown terrain;
  final bool compact;

  const TerrainBreakdownWidget({
    super.key,
    required this.terrain,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactView();
    }
    return _buildFullView();
  }

  Widget _buildCompactView() {
    return Row(
      children: [
        _buildBar(terrain.asphaltPercent, Colors.grey.shade700, flex: terrain.asphaltPercent.toInt()),
        _buildBar(terrain.gravelPercent, Colors.brown, flex: terrain.gravelPercent.toInt()),
        _buildBar(terrain.pathPercent, Colors.blue.shade700, flex: terrain.pathPercent.toInt()),
      ],
    );
  }

  Widget _buildFullView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Composizione Terreno',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _buildTerrainRow(
          '🛣️ Asfalto',
          terrain.asphaltPercent,
          Colors.grey.shade700,
        ),
        const SizedBox(height: 4),
        _buildTerrainRow(
          '🏔️ Sterrato',
          terrain.gravelPercent,
          Colors.brown,
        ),
        const SizedBox(height: 4),
        _buildTerrainRow(
          '🌲 Sentiero',
          terrain.pathPercent,
          Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildTerrainRow(String label, double percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent / 100,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 45,
          child: Text(
            '${percent.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double percent, Color color, {required int flex}) {
    if (flex == 0) return const SizedBox.shrink();
    
    return Expanded(
      flex: flex,
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
