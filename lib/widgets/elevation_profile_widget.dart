import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Elevation profile chart widget with color-coded slopes
/// Green: 0-3%, Yellow: 4-7%, Red: >8%
class ElevationProfileWidget extends StatelessWidget {
  final List<double> elevationProfile;
  final double distanceKm;

  const ElevationProfileWidget({
    super.key,
    required this.elevationProfile,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    if (elevationProfile.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
    final colors = <Color>[];
    
    // Calculate distance per point
    final distPerPoint = distanceKm / (elevationProfile.length - 1);
    
    for (int i = 0; i < elevationProfile.length; i++) {
      final distance = i * distPerPoint;
      final elevation = elevationProfile[i];
      spots.add(FlSpot(distance, elevation));
      
      // Calculate slope and assign color
      if (i > 0) {
        final elevDiff = elevation - elevationProfile[i - 1];
        final distM = distPerPoint * 1000; // km to meters
        final slope = (elevDiff / distM) * 100; // percentage
        
        if (slope.abs() <= 3) {
          colors.add(Colors.green);
        } else if (slope.abs() <= 7) {
          colors.add(Colors.orange);
        } else {
          colors.add(Colors.red);
        }
      } else {
        colors.add(Colors.green); // First point
      }
    }
    
    final minEle = elevationProfile.reduce((a, b) => a < b ? a : b);
    final maxEle = elevationProfile.reduce((a, b) => a > b ? a : b);
    final range = maxEle - minEle;
    
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terrain, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                'Profilo Altimetrico',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Spacer(),
              _buildLegendDot(Colors.green, '0-3%'),
              const SizedBox(width: 8),
              _buildLegendDot(Colors.orange, '4-7%'),
              const SizedBox(width: 8),
              _buildLegendDot(Colors.red, '>8%'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minEle - (range * 0.1),
                maxY: maxEle + (range * 0.1),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}m',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toStringAsFixed(1)}km',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: range > 0 ? range / 4 : 1.0,
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: colors,
                      stops: List.generate(colors.length, (i) => i / (colors.length - 1)),
                    ),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: colors.map((c) => c.withOpacity(0.3)).toList(),
                        stops: List.generate(colors.length, (i) => i / (colors.length - 1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }
}
