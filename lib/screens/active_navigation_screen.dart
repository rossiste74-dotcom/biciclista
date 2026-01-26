import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/user_profile.dart';
import '../models/alert_rule.dart';
import '../services/database_service.dart';
import '../services/alert_rules_service.dart';

/// Active navigation module with GPS tracking, compass rotation, and rules-based alerts
class ActiveNavigationScreen extends StatefulWidget {
  final List<LatLng> routePoints;
  final UserProfile profile;
  final String? rideName;
  final double totalDistanceKm;

  const ActiveNavigationScreen({
    super.key,
    required this.routePoints,
    required this.profile,
    this.rideName,
    this.totalDistanceKm = 0,
  });

  @override
  State<ActiveNavigationScreen> createState() => _ActiveNavigationScreenState();
}

class _ActiveNavigationScreenState extends State<ActiveNavigationScreen> {
  final MapController _mapController = MapController();
  final FlutterTts _tts = FlutterTts();
  final AlertRulesService _rulesService = AlertRulesService();
  final DatabaseService _db = DatabaseService();
  
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;
  
  LatLng? _currentPosition;
  double _currentHeading = 0.0;
  bool _isFollowing = true;
  bool _isOffCourse = false;
  double _distanceToRoute = 0.0;
  double _distanceCoveredKm = 0.0;
  double _distanceToFinishKm = 0.0;
  
  List<AlertRule> _alertRules = [];
  LatLng? _lastPosition;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _initTts();
    await _loadAlertRules();
    await _startTracking();
    _setupWakelock();
  }

  Future<void> _loadAlertRules() async {
    await _db.initDefaultAlertRulesIfNeeded();
    _alertRules = await _db.getEnabledAlertRules();
  }

  void _setupWakelock() {
    if (widget.profile.energySavingMode) {
      WakelockPlus.disable();
    } else {
      WakelockPlus.enable();
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("it-IT");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  Future<void> _startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('map.enable_location_msg'.tr())),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('map.location_denied'.tr())),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('map.location_forever_denied'.tr())),
        );
      }
      return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_handlePositionUpdate);

    _compassStream = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted && event.heading != null) {
        setState(() {
          _currentHeading = event.heading!;
          if (_isFollowing && _currentPosition != null) {
            _mapController.rotate(-_currentHeading);
          }
        });
      }
    });
  }

  void _handlePositionUpdate(Position position) {
    if (!mounted) return;

    final newPos = LatLng(position.latitude, position.longitude);
    
    // Update distance covered
    if (_lastPosition != null) {
      final dist = const Distance().as(LengthUnit.Kilometer, _lastPosition!, newPos);
      _distanceCoveredKm += dist;
    }
    _lastPosition = newPos;
    
    // Calculate distance to finish
    if (widget.totalDistanceKm > 0) {
      _distanceToFinishKm = widget.totalDistanceKm - _distanceCoveredKm;
      if (_distanceToFinishKm < 0) _distanceToFinishKm = 0;
    }

    setState(() {
      _currentPosition = newPos;
      if (_isFollowing) {
        _mapController.move(newPos, _mapController.camera.zoom);
      }
    });

    _evaluateAlerts(newPos);
  }

  void _evaluateAlerts(LatLng pos) {
    if (widget.routePoints.isEmpty) return;

    // Calculate distance from route
    double minDistance = double.infinity;
    for (int i = 0; i < widget.routePoints.length - 1; i++) {
      final d = _crossTrackDistance(pos, widget.routePoints[i], widget.routePoints[i + 1]);
      if (d < minDistance) minDistance = d;
    }
    setState(() => _distanceToRoute = minDistance);

    // Build navigation state for rules engine
    final state = NavigationState(
      distanceFromRoute: minDistance,
      distanceToFinish: _distanceToFinishKm,
      distanceCovered: _distanceCoveredKm,
      totalDistance: widget.totalDistanceKm,
      isOnClimb: false, // TODO: integrate with climb data
      wasOnClimb: false,
    );

    // Evaluate rules
    final triggers = _rulesService.evaluate(_alertRules, state);
    
    for (final trigger in triggers) {
      _executeAlert(trigger);
    }

    // Update off-course state for UI
    final offCourseRule = _alertRules.firstWhere(
      (r) => r.eventType == AlertEventType.offCourse,
      orElse: () => AlertRule()..triggerValue = 30.0,
    );
    final offCourse = minDistance > (offCourseRule.triggerValue ?? 30.0);
    
    if (offCourse && !_isOffCourse && widget.profile.energySavingMode) {
      WakelockPlus.enable();
    } else if (!offCourse && _isOffCourse && widget.profile.energySavingMode) {
      WakelockPlus.disable();
      _rulesService.resetEvent(AlertEventType.offCourse);
    }
    
    setState(() => _isOffCourse = offCourse);
  }

  void _executeAlert(AlertTrigger trigger) {
    // Voice alert
    if (trigger.shouldSpeak) {
      _tts.speak(trigger.message);
    }
    
    // Vibration alert
    if (trigger.shouldVibrate) {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator == true) {
          Vibration.vibrate(pattern: [0, 500, 200, 500]);
        }
      });
    }
  }

  double _crossTrackDistance(LatLng p, LatLng s1, LatLng s2) {
    const double R = 6371000;
    
    double lat1 = s1.latitude * math.pi / 180;
    double lon1 = s1.longitude * math.pi / 180;
    double lat2 = s2.latitude * math.pi / 180;
    double lon2 = s2.longitude * math.pi / 180;
    double lat3 = p.latitude * math.pi / 180;
    double lon3 = p.longitude * math.pi / 180;

    double d13 = 2 * math.asin(math.sqrt(
      math.pow(math.sin((lat1 - lat3) / 2), 2) +
      math.cos(lat1) * math.cos(lat3) * math.pow(math.sin((lon1 - lon3) / 2), 2)
    )) * R;
    
    double bearing13 = math.atan2(
      math.sin(lon3 - lon1) * math.cos(lat3),
      math.cos(lat1) * math.sin(lat3) - math.sin(lat1) * math.cos(lat3) * math.cos(lon3 - lon1)
    );
    double bearing12 = math.atan2(
      math.sin(lon2 - lon1) * math.cos(lat2),
      math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1)
    );

    double dxt = math.asin(math.sin(d13 / R) * math.sin(bearing13 - bearing12)) * R;
    return dxt.abs();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _compassStream?.cancel();
    _tts.stop();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.routePoints.isNotEmpty 
                  ? widget.routePoints.first 
                  : const LatLng(45.4642, 9.1900),
              initialZoom: 16,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture && _isFollowing) {
                  setState(() => _isFollowing = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.biciclistico.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    strokeWidth: 5.0,
                    color: _isOffCourse 
                        ? Colors.red.withValues(alpha: 0.6) 
                        : Colors.blue.withValues(alpha: 0.8),
                  ),
                ],
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 50,
                      height: 50,
                      child: Transform.rotate(
                        angle: _currentHeading * (math.pi / 180),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.rideName ?? 'map.navigation_default_title'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.totalDistanceKm > 0)
                            Text(
                              'map.km_remaining'.tr(args: [_distanceToFinishKm.toStringAsFixed(1)]),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_currentPosition != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isOffCourse ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_distanceToRoute.toInt()}m',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Off-course warning
          if (_isOffCourse)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'map.off_course'.tr(),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 32,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'recenter',
                  onPressed: () {
                    setState(() => _isFollowing = true);
                    if (_currentPosition != null) {
                      _mapController.move(_currentPosition!, 16);
                      _mapController.rotate(-_currentHeading);
                    }
                  },
                  backgroundColor: _isFollowing 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.surface,
                  child: Icon(
                    Icons.my_location,
                    color: _isFollowing 
                        ? Theme.of(context).colorScheme.onPrimary 
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'exit',
                  onPressed: _confirmExit,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('map.stop_nav_title'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('map.stop_btn'.tr()),
          ),
        ],
      ),
    );
  }
}
