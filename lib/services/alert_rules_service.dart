import 'package:flutter/material.dart';
import '../models/alert_rule.dart';

/// State passed to the rules engine for evaluation
class NavigationState {
  final double distanceFromRoute;      // meters
  final double distanceToFinish;       // km
  final double distanceCovered;        // km
  final double totalDistance;          // km
  final bool isOnClimb;
  final bool wasOnClimb;
  final int? currentClimbIndex;
  final int? previousClimbIndex;
  
  NavigationState({
    required this.distanceFromRoute,
    required this.distanceToFinish,
    required this.distanceCovered,
    required this.totalDistance,
    this.isOnClimb = false,
    this.wasOnClimb = false,
    this.currentClimbIndex,
    this.previousClimbIndex,
  });
  
  double get progressPercent => totalDistance > 0 ? (distanceCovered / totalDistance) * 100 : 0;
  bool get isHalfway => progressPercent >= 49 && progressPercent <= 51;
}

/// Result of rule evaluation
class AlertTrigger {
  final AlertRule rule;
  final String message;
  final bool shouldVibrate;
  final bool shouldSpeak;

  AlertTrigger({
    required this.rule,
    required this.message,
    required this.shouldVibrate,
    required this.shouldSpeak,
  });
}

/// Service for evaluating alert rules against navigation state
class AlertRulesService {
  // Track which events have been triggered to avoid repeating
  final Map<String, DateTime> _triggeredEvents = {};
  
  // Cooldown period for each event type (in seconds)
  static const Map<AlertEventType, int> _cooldowns = {
    AlertEventType.offCourse: 30,
    AlertEventType.distanceToFinish: 60,
    AlertEventType.climbStart: 120,
    AlertEventType.climbEnd: 120,
    AlertEventType.halfway: 600, // Only once ideally
    AlertEventType.approachingTurn: 30,
  };

  /// Evaluate all enabled rules against the current navigation state
  List<AlertTrigger> evaluate(List<AlertRule> rules, NavigationState state) {
    final triggers = <AlertTrigger>[];
    
    for (final rule in rules.where((r) => r.isEnabled)) {
      final trigger = _evaluateRule(rule, state);
      if (trigger != null) {
        triggers.add(trigger);
      }
    }
    
    return triggers;
  }

  AlertTrigger? _evaluateRule(AlertRule rule, NavigationState state) {
    // Check cooldown
    final eventKey = _getEventKey(rule);
    if (_isOnCooldown(eventKey, rule.eventType)) {
      return null;
    }

    bool shouldTrigger = false;
    
    switch (rule.eventType) {
      case AlertEventType.offCourse:
        final threshold = rule.triggerValue ?? 30.0;
        shouldTrigger = state.distanceFromRoute > threshold;
        break;
        
      case AlertEventType.distanceToFinish:
        final targetKm = rule.triggerValue ?? 5.0;
        // Trigger when crossing the threshold (within 0.1km margin)
        shouldTrigger = state.distanceToFinish <= targetKm && 
                        state.distanceToFinish > (targetKm - 0.2);
        break;
        
      case AlertEventType.climbStart:
        shouldTrigger = state.isOnClimb && !state.wasOnClimb;
        break;
        
      case AlertEventType.climbEnd:
        shouldTrigger = !state.isOnClimb && state.wasOnClimb;
        break;
        
      case AlertEventType.halfway:
        shouldTrigger = state.isHalfway;
        break;
        
      case AlertEventType.approachingTurn:
        // This would require turn-by-turn data which we don't have yet
        shouldTrigger = false;
        break;
    }

    if (shouldTrigger) {
      _triggeredEvents[eventKey] = DateTime.now();
      
      return AlertTrigger(
        rule: rule,
        message: rule.effectiveVoiceMessage,
        shouldVibrate: rule.action == AlertActionType.vibration || 
                       rule.action == AlertActionType.both,
        shouldSpeak: rule.action == AlertActionType.voice || 
                     rule.action == AlertActionType.both,
      );
    }
    
    return null;
  }

  String _getEventKey(AlertRule rule) {
    // Create a unique key for this specific rule
    return '${rule.eventType.name}_${rule.triggerValue ?? 0}';
  }

  bool _isOnCooldown(String eventKey, AlertEventType eventType) {
    final lastTrigger = _triggeredEvents[eventKey];
    if (lastTrigger == null) return false;
    
    final cooldownSeconds = _cooldowns[eventType] ?? 30;
    return DateTime.now().difference(lastTrigger).inSeconds < cooldownSeconds;
  }

  /// Reset all triggered events (e.g., when starting a new navigation session)
  void reset() {
    _triggeredEvents.clear();
    debugPrint('AlertRulesService: Reset all triggered events');
  }

  /// Mark a specific event as no longer triggered (e.g., when back on course)
  void resetEvent(AlertEventType eventType, {double? triggerValue}) {
    final eventKey = '${eventType.name}_${triggerValue ?? 0}';
    _triggeredEvents.remove(eventKey);
  }
}
