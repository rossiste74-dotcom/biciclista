import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Un punto mensile con km e dislivello
class MonthlyStats {
  final DateTime month;
  final double km;
  final double elevation;
  MonthlyStats({
    required this.month,
    required this.km,
    required this.elevation,
  });
}

/// Grafico a linee: km (blu) e dislivello (arancione) sui 12 mesi
class YearlyStatsChart extends StatefulWidget {
  final List<MonthlyStats> data;

  const YearlyStatsChart({super.key, required this.data});

  @override
  State<YearlyStatsChart> createState() => _YearlyStatsChartState();
}

class _YearlyStatsChartState extends State<YearlyStatsChart> {
  bool _showKm = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final months = _buildFullYear();
    final maxKm = months.map((e) => e.km).fold(0.0, (a, b) => a > b ? a : b);
    final maxElev = months
        .map((e) => e.elevation)
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxY = _showKm
        ? (maxKm == 0 ? 100.0 : (maxKm * 1.2).ceilToDouble())
        : (maxElev == 0 ? 1000.0 : (maxElev * 1.2).ceilToDouble());

    final spots = months.asMap().entries.map((e) {
      final val = _showKm ? e.value.km : e.value.elevation;
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Andamento Annuale',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Toggle: KM / Dislivello
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Km'),
                      icon: Icon(Icons.directions_bike, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('↑ m'),
                      icon: Icon(Icons.landscape, size: 16),
                    ),
                  ],
                  selected: {_showKm},
                  onSelectionChanged: (s) => setState(() => _showKm = s.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: scheme.outlineVariant.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= months.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat('MMM').format(months[idx].month),
                              style: TextStyle(
                                fontSize: 9,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxY / 4,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            _showKm
                                ? value.toStringAsFixed(0)
                                : '${(value / 1000).toStringAsFixed(1)}k',
                            style: TextStyle(
                              fontSize: 9,
                              color: scheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: _showKm ? scheme.primary : Colors.deepOrange,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                          radius: spot.y > 0 ? 3.5 : 0,
                          color: _showKm ? scheme.primary : Colors.deepOrange,
                          strokeWidth: 1.5,
                          strokeColor: scheme.surface,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (_showKm ? scheme.primary : Colors.deepOrange)
                                .withOpacity(0.25),
                            (_showKm ? scheme.primary : Colors.deepOrange)
                                .withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) =>
                          touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            final m = months[idx];
                            final label = _showKm
                                ? '${m.km.toStringAsFixed(0)} km'
                                : '${m.elevation.toStringAsFixed(0)} m';
                            return LineTooltipItem(
                              '${DateFormat('MMM yy').format(m.month)}\n$label',
                              TextStyle(
                                color: scheme.onInverseSurface,
                                fontSize: 11,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a fixed list of 12 months (oldest → newest), filling gaps with 0
  List<MonthlyStats> _buildFullYear() {
    final now = DateTime.now();
    final result = <MonthlyStats>[];
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final found = widget.data.where(
        (d) => d.month.year == month.year && d.month.month == month.month,
      );
      if (found.isNotEmpty) {
        result.add(found.first);
      } else {
        result.add(MonthlyStats(month: month, km: 0, elevation: 0));
      }
    }
    return result;
  }
}
