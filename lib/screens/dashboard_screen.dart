import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
import '../services/crew_service.dart';
import '../widgets/readiness_score_card.dart';
import '../widgets/next_ride_preview_card.dart';
import '../widgets/metric_sparkline_chart.dart';
import '../widgets/ai_coach_card.dart';
import '../widgets/biciclista_wisdom.dart';
import '../widgets/biciclista_stats.dart';
import '../widgets/biciclista_maintenance.dart';
import '../widgets/biciclista_weather.dart';
import '../widgets/biciclista_weather.dart';
import '../widgets/biciclista_challenge.dart';
import '../widgets/biciclista_leaderboard.dart';
import 'gpx_import_screen.dart';
import 'leaderboard_screen.dart';
import 'route_detail_screen.dart';
import 'route_planner_screen.dart';

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
  final _crewService = CrewService();

  StreamSubscription? _profileSubscription;
  StreamSubscription? _ridesSubscription;
  
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
  
  // Messages Maps
  Map<String, String> _weatherMessages = {};
  Map<String, String> _statsMessages = {};
  Map<String, String> _maintenanceMessages = {};
  Map<String, String> _challengeMessages = {};
  
  // Leaderboard
  Map<String, dynamic> _leaderboardData = {};

  @override
  void initState() {
    super.initState();
    _loadAllData();
    
    // Auto-refresh when profile or rides change
    _profileSubscription = _db.watchUserProfile().listen((_) => _loadAllData());
    _ridesSubscription = _db.watchPlannedRides().listen((_) => _loadAllData());
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _ridesSubscription?.cancel();
    super.dispose();
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

      // 4. Load Next Ride (prioritize group rides)
      // We now fetch ALL incomplete rides (including past ones) to allow closing them
      final incompletePersonal = await _db.getIncompleteRides();
      List<dynamic> allUpcoming = [...incompletePersonal];
      
      // Fetch group rides from Crew
      try {
        final groupRides = await _crewService.getMyGroupRides();
        // Show group rides from last 12 hours (so you can join slightly late) + future
        final cutoff = DateTime.now().subtract(const Duration(hours: 12));
        final relevantGroupRides = groupRides.where((gr) => gr.meetingTime.isAfter(cutoff)).toList();
        allUpcoming.addAll(relevantGroupRides);
      } catch (e) {
        debugPrint('Error fetching group rides: $e');
      }
      
      // Sort by date. 
      // For past rides, users likely want to deal with the oldest incomplete first?
      // Or the most recent?
      // "Next Ride" usually implies the one closest to now (or closest future).
      // But if I have a list of [Past1, Past2, Future1], and I want to clear Past1...
      // Let's sort simply by date ascending. Past rides will show up first.
      if (allUpcoming.isNotEmpty) {
        allUpcoming.sort((a, b) {
          final dateA = a is PlannedRide ? a.rideDate : (a as dynamic).meetingTime;
          final dateB = b is PlannedRide ? b.rideDate : (b as dynamic).meetingTime;
          return dateA.compareTo(dateB);
        });
        
        final nextActivity = allUpcoming.first;
        
        // Convert GroupRide to PlannedRide for display compatibility
        if (nextActivity is! PlannedRide) {
          final gr = nextActivity as dynamic; // GroupRide
          _nextRide = PlannedRide()
            ..rideDate = gr.meetingTime
            ..rideName = gr.rideName
            ..distance = gr.distance ?? 0.0
            ..elevation = gr.elevation ?? 0.0
            ..latitude = gr.meetingLatitude
            ..longitude = gr.meetingLongitude
            ..isGroupRide = true;
        } else {
          _nextRide = nextActivity;
        }
        
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

        // 6. Load Dashboard Messages
        _weatherMessages = await _db.getWeatherMessages();
        _statsMessages = await _db.getStatsMessages();
        _maintenanceMessages = await _db.getMaintenanceMessages();
        _challengeMessages = await _db.getChallengeMessages();
        
        // 7. Load Leaderboard
        _leaderboardData = await _db.getLeaderboard();
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
                        // Show BiciclistaWisdom first if no ride is planned
                        if (_nextRide == null) ...[
                          const BiciclistaWisdom(),
                          const SizedBox(height: 24),
                        ],
                        _buildStatsSection(),
                        const SizedBox(height: 24),
                        _buildBiometricStatsSection(),
                        const SizedBox(height: 24),
                        _buildReadinessSection(),
                        const SizedBox(height: 24),
                        const AICoachCard(),
                        const SizedBox(height: 24),
                        _buildNextRideSection(),
                        const SizedBox(height: 24),
                        _buildTotalReadinessTrend(),
                        const SizedBox(height: 24),
                        _buildTrendsSection(),
                        const SizedBox(height: 24),
                        // Il Biciclista widgets at the bottom
                        BiciclistaStats(
                          weeklyKm: _weeklyKm,
                          weeklyRides: _totalRides, // Using total for now, could filter weekly
                          statsMessages: _statsMessages,
                        ),
                        const SizedBox(height: 24),
                        _buildWeatherWidget(),
                        const SizedBox(height: 24),
                        _buildMaintenanceWidget(),
                        const SizedBox(height: 24),
                        BiciclistaChallenge(
                          challengeTitle: 'dashboard.challenge_title'.tr(),
                          targetValue: 100,
                          currentValue: _weeklyKm,
                          challengeMessages: _challengeMessages,
                        ),
                        const SizedBox(height: 24),
                        if (_leaderboardData.isNotEmpty && _leaderboardData['most_active'] != null)
                          BiciclistaLeaderboard(
                            leaderboardData: _leaderboardData,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                            ),
                          ),
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
            label: 'dashboard.total_rides'.tr(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.route,
            value: '${_totalKm.toStringAsFixed(0)} km',
            label: 'dashboard.total_km'.tr(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            value: '${_weeklyKm.toStringAsFixed(0)} km',
            label: 'dashboard.weekly_km'.tr(),
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
            label: 'dashboard.weight'.tr(),
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_border,
            value: '${_profile!.hrv} ms',
            label: 'dashboard.hrv'.tr(),
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.bed_outlined,
            value: '${_profile!.sleepHours.toStringAsFixed(1)} h',
            label: 'dashboard.sleep'.tr(),
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
          'dashboard.readiness_trend'.tr(),
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
              'dashboard.last_update'.tr(args: [DateFormat('dd/MM HH:mm').format(_profile!.lastHealthSync!)]),
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
      onTap: () => _openRouteDetail(),
      onNavigate: () => _openRouteDetail(),
      onTerminate: () async {
        if (_nextRide == null) return;
        
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hai finito?'),
            content: const Text('Vuoi segnare questa pedalata come completata?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sì, Termina'),
              ),
            ],
          ),
        );

        if (confirm == true) {
           // Mark as completed
           // Clone to modify
           final updated = _nextRide!;
           updated.isCompleted = true;
           await _db.updatePlannedRide(updated);
           
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Pedalata completata! Grandissimo! 🚴‍♂️')),
             );
           }
           _loadAllData();
        }
      },
    );
  }

  Future<void> _openRouteDetail() async {
        if (_nextRide != null) {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RouteDetailScreen(plannedRide: _nextRide!),
            ),
          );
          if (result == true) _loadAllData();
        }
  }

  Widget _buildTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dashboard.trend_7_days'.tr(),
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
                      _hrvTrend.isNotEmpty ? '${_hrvTrend.last.toInt()} ms' : 'dashboard.sync_placeholder'.tr(),
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
                      _weightTrend.isNotEmpty ? '${_weightTrend.last.toStringAsFixed(1)} kg' : 'dashboard.sync_placeholder'.tr(),
                      isPlaceholder: _weightTrend.isEmpty,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoDataCard(String label, String value, {bool isPlaceholder = true}) {
    // ... existing code ...
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
                      'dashboard.sync_hint'.tr(),
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

  Widget _buildWeatherWidget() {
    // Use outfit suggestion weather data if available, otherwise defaults
    final temp = _outfitSuggestion?.temperature ?? 15.0;
    final windSpeed = _outfitSuggestion?.windSpeed ?? 0.0;
    
    return BiciclistaWeather(
      temperature: temp,
      isRaining: false, // Could be enhanced with weather service
      windSpeed: windSpeed,
      weatherMessages: _weatherMessages,
    );
  }

  Widget _buildMaintenanceWidget() {
    // Check if there are any bikes with components near limit
    // For now, show "all OK" - this could be enhanced to check actual bike data
    return BiciclistaMaintenance(
      allOk: true,
      maintenanceMessages: _maintenanceMessages,
    );
  }
}
