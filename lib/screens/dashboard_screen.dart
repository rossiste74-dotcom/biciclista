import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/clothing_item.dart';
import '../models/planned_ride.dart';
import '../models/outfit_suggestion.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/biometric_service.dart';
import '../services/outfit_service.dart';
import '../services/weather_service.dart';
import '../services/health_sync_service.dart';
import '../widgets/readiness_score_card.dart';
import '../widgets/next_ride_preview_card.dart';
import '../widgets/metric_sparkline_chart.dart';
import 'gpx_import_screen.dart';
import 'route_detail_screen.dart';

/// The main application dashboard centralizing health and ride data
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseService();
  final _biometricService = BiometricService();
  final _outfitService = OutfitService();
  final _weatherService = WeatherService();
  final _healthSyncService = HealthSyncService();

  bool _isLoading = true;
  UserProfile? _profile;
  PlannedRide? _nextRide;
  OutfitSuggestion? _outfitSuggestion;
  
  List<double> _hrvTrend = [];
  List<double> _weightTrend = [];
  List<double> _sleepTrend = [];
  List<double> _readinessTrend = [];
  
  // Stats
  double _totalKm = 0.0;
  double _weeklyKm = 0.0;
  int _totalRides = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Load Profile (Primary source for health data)
      _profile = await _db.getUserProfile();
      
      if (_profile != null) {
        // 2. Derive Trends from Profile History
        _hrvTrend = _biometricService.getHrvTrendFromProfile(_profile!);
        _weightTrend = _biometricService.getWeightTrendFromProfile(_profile!);
        _sleepTrend = _biometricService.getSleepTrendFromProfile(_profile!);
        _readinessTrend = _biometricService.getReadinessTrendFromProfile(_profile!);
      }

      // 3. Load Ride Stats
      _totalKm = await _db.getTotalCompletedKm();
      _weeklyKm = await _db.getWeeklyCompletedKm();
      _totalRides = await _db.getTotalCompletedRidesCount();

      // 4. Load Next Ride
      final upcoming = await _db.getUpcomingRides();
      if (upcoming.isNotEmpty) {
        _nextRide = upcoming.first;
        
        // 5. Fetch Weather & Suggestions
        if (_profile != null) {
          try {
            final lat = _nextRide!.latitude ?? 45.4642;
            final lng = _nextRide!.longitude ?? 9.1900;
            
            final weather = await _weatherService.getForecast(
              lat: lat,
              lng: lng,
              date: _nextRide!.rideDate,
            );
            
            _outfitSuggestion = _outfitService.suggestOutfit(
              weather: weather,
              thermalSensitivity: _profile!.thermalSensitivity,
              elevationGain: _nextRide!.elevation,
              hotThreshold: _profile!.hotThreshold,
              warmThreshold: _profile!.warmThreshold,
              coolThreshold: _profile!.coolThreshold,
              coldThreshold: _profile!.coldThreshold,
              sensitivityAdjustment: _profile!.sensitivityAdjustment,
              hotKit: ClothingItem.fromIndexes(_profile!.hotKit),
              warmKit: ClothingItem.fromIndexes(_profile!.warmKit),
              coolKit: ClothingItem.fromIndexes(_profile!.coolKit),
              coldKit: ClothingItem.fromIndexes(_profile!.coldKit),
              veryColdKit: ClothingItem.fromIndexes(_profile!.veryColdKit),
            );
          } catch (e) {
            debugPrint('Weather fetch failed: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAllData,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildStatsSection(),
                        const SizedBox(height: 24),
                        _buildBiometricStatsSection(),
                        const SizedBox(height: 24),
                        _buildReadinessSection(),
                        const SizedBox(height: 24),
                        _buildNextRideSection(),
                        const SizedBox(height: 24),
                        _buildTotalReadinessTrend(),
                        const SizedBox(height: 24),
                        _buildTrendsSection(),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.directions_bike,
            value: _totalRides.toString(),
            label: 'Uscite Totali',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.route,
            value: '${_totalKm.toStringAsFixed(0)} km',
            label: 'Km Totali',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            value: '${_weeklyKm.toStringAsFixed(0)} km',
            label: 'Km Settimana',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricStatsSection() {
    if (_profile == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.monitor_weight_outlined,
            value: '${_profile!.weight.toStringAsFixed(1)} kg',
            label: 'Peso',
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_border,
            value: '${_profile!.hrv} ms',
            label: 'HRV',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.bed_outlined,
            value: '${_profile!.sleepHours.toStringAsFixed(1)} h',
            label: 'Sonno',
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalReadinessTrend() {
    if (_readinessTrend.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trend Totale Readiness',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        MetricSparklineChart(
          label: 'Readiness Score',
          values: _readinessTrend,
          color: Colors.orange,
          unit: '',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessSection() {
    final score = _profile != null 
        ? _biometricService.calculateReadinessFromProfile(_profile!)
        : 0;

    return Column(
      children: [
        ReadinessScoreCard(
          score: score,
          status: _biometricService.getReadinessStatus(score),
          recommendation: _biometricService.getReadinessRecommendation(score),
          weight: _profile?.weight,
          hrv: _profile?.hrv,
        ),
        if (_profile?.lastHealthSync != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Ultimo aggiornamento: ${DateFormat('dd/MM HH:mm').format(_profile!.lastHealthSync!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNextRideSection() {
    return NextRidePreviewCard(
      ride: _nextRide,
      outfit: _outfitSuggestion,
      onImportPressed: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const GpxImportScreen()),
        );
        if (result != null) _loadAllData();
      },
      onTap: () async {
        if (_nextRide != null) {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RouteDetailScreen(plannedRide: _nextRide!),
            ),
          );
          if (result == true) _loadAllData();
        }
      },
    );
  }

  Widget _buildTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trend Ultimi 7 Giorni',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _hrvTrend.length >= 2
                  ? MetricSparklineChart(
                      label: 'HRV',
                      values: _hrvTrend,
                      color: Colors.blue,
                      unit: 'ms',
                    )
                  : _buildNoDataCard(
                      'HRV', 
                      _hrvTrend.isNotEmpty ? '${_hrvTrend.last.toInt()} ms' : 'Sincronizza dati salute',
                      isPlaceholder: _hrvTrend.isEmpty,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _weightTrend.length >= 2
                  ? MetricSparklineChart(
                      label: 'Peso',
                      values: _weightTrend,
                      color: Colors.purple,
                      unit: 'kg',
                    )
                  : _buildNoDataCard(
                      'Peso', 
                      _weightTrend.isNotEmpty ? '${_weightTrend.last.toStringAsFixed(1)} kg' : 'Sincronizza dati salute',
                      isPlaceholder: _weightTrend.isEmpty,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoDataCard(String label, String value, {bool isPlaceholder = true}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    isPlaceholder ? Icons.show_chart : Icons.insights,
                    color: isPlaceholder 
                        ? Theme.of(context).colorScheme.outline 
                        : Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: isPlaceholder 
                      ? Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        )
                      : Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isPlaceholder)
                    Text(
                      'Sincronizza più dati per il trend',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
