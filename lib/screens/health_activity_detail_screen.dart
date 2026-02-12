import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

/// Detail screen showing all available information for a Health Connect activity
class HealthActivityDetailScreen extends StatefulWidget {
  final DateTime activityDate;
  final String activityType;
  final double distance;

  const HealthActivityDetailScreen({
    super.key,
    required this.activityDate,
    required this.activityType,
    required this.distance,
  });

  @override
  State<HealthActivityDetailScreen> createState() => _HealthActivityDetailScreenState();
}

class _HealthActivityDetailScreenState extends State<HealthActivityDetailScreen> {
  final Health _health = Health();
  bool _isLoading = true;
  
  // Workout details
  Duration? _duration;
  double? _avgHeartRate;
  double? _maxHeartRate;
  double? _avgSpeed;
  int? _calories;
  int? _steps;
  
  @override
  void initState() {
    super.initState();
    _loadActivityDetails();
  }

  Future<void> _loadActivityDetails() async {
    setState(() => _isLoading = true);
    
    try {
      // Query workout data for this specific time range (±5 minutes to catch the exact workout)
      final start = widget.activityDate.subtract(const Duration(minutes: 5));
      final end = widget.activityDate.add(const Duration(hours: 3)); // Most workouts < 3h
      
      // Get workout data
      final workouts = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.WORKOUT],
      );
      
      if (workouts.isNotEmpty) {
        final workout = workouts.first;
        
        // Calculate duration
        _duration = workout.dateTo.difference(workout.dateFrom);
        
        // Calculate avg speed (km/h)
        if (_duration != null && _duration!.inSeconds > 0) {
          _avgSpeed = (widget.distance / _duration!.inHours);
        }
      }
      
      // Try to get heart rate data in the same time range
      try {
        final hrData = await _health.getHealthDataFromTypes(
          startTime: widget.activityDate,
          endTime: widget.activityDate.add(_duration ?? const Duration(hours: 1)),
          types: [HealthDataType.HEART_RATE],
        );
        
        if (hrData.isNotEmpty) {
          final hrValues = hrData.map((e) => (e.value as NumericHealthValue).numericValue.toDouble()).toList();
          _avgHeartRate = hrValues.reduce((a, b) => a + b) / hrValues.length;
          _maxHeartRate = hrValues.reduce((a, b) => a > b ? a : b).toDouble();
        }
      } catch (e) {
        debugPrint('Could not fetch heart rate: $e');
      }
      
      // Try to get steps
      try {
        final stepsData = await _health.getHealthDataFromTypes(
          startTime: widget.activityDate,
          endTime: widget.activityDate.add(_duration ?? const Duration(hours: 1)),
          types: [HealthDataType.STEPS],
        );
        
        if (stepsData.isNotEmpty) {
          _steps = stepsData.map((e) => (e.value as NumericHealthValue).numericValue.toInt()).reduce((a, b) => a + b);
        }
      } catch (e) {
        debugPrint('Could not fetch steps: $e');
      }
      
    } catch (e) {
      debugPrint('Error loading activity details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activityType.replaceAll('(Health)', '').trim()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getActivityIcon(),
                                size: 48,
                                color: _getActivityColor(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.activityType.replaceAll('(Health)', '').trim(),
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    Text(
                                      dateFormat.format(widget.activityDate),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Main Metrics
                  Text(
                    'Metriche Principali',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.route,
                          label: 'Distanza',
                          value: '${widget.distance.toStringAsFixed(3)} km',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.timer,
                          label: 'Durata',
                          value: _duration != null 
                              ? _formatDuration(_duration!)
                              : 'N/A',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  if (_avgSpeed != null)
                    _buildMetricCard(
                      icon: Icons.speed,
                      label: 'Velocità Media',
                      value: '${_avgSpeed!.toStringAsFixed(1)} km/h',
                      color: Colors.green,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Health Metrics
                  if (_avgHeartRate != null || _maxHeartRate != null || _steps != null) ...[
                    Text(
                      'Metriche Salute',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (_avgHeartRate != null || _maxHeartRate != null)
                    Row(
                      children: [
                        if (_avgHeartRate != null)
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.favorite,
                              label: 'FC Media',
                              value: '${_avgHeartRate!.toStringAsFixed(0)} bpm',
                              color: Colors.red,
                            ),
                          ),
                        if (_avgHeartRate != null && _maxHeartRate != null)
                          const SizedBox(width: 12),
                        if (_maxHeartRate != null)
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.favorite_border,
                              label: 'FC Max',
                              value: '${_maxHeartRate!.toStringAsFixed(0)} bpm',
                              color: Colors.red.shade700,
                            ),
                          ),
                      ],
                    ),
                  
                  if (_steps != null) ...[
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      icon: Icons.directions_walk,
                      label: 'Passi',
                      value: _steps.toString(),
                      color: Colors.purple,
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Source Info
                  Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dati sincronizzati da Health Connect',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon() {
    final type = widget.activityType.toUpperCase();
    if (type.contains('CYCLING') || type.contains('BIKING')) {
      return Icons.directions_bike;
    } else if (type.contains('RUNNING')) {
      return Icons.directions_run;
    } else if (type.contains('WALKING')) {
      return Icons.directions_walk;
    } else if (type.contains('SWIMMING')) {
      return Icons.pool;
    } else {
      return Icons.fitness_center;
    }
  }

  Color _getActivityColor() {
    final type = widget.activityType.toUpperCase();
    if (type.contains('CYCLING') || type.contains('BIKING')) {
      return Colors.blue;
    } else if (type.contains('RUNNING')) {
      return Colors.orange;
    } else if (type.contains('WALKING')) {
      return Colors.green;
    } else if (type.contains('SWIMMING')) {
      return Colors.cyan;
    } else {
      return Colors.purple;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
