
/// Types of navigation events that can trigger alerts
enum AlertEventType {
  offCourse,           // Fuori percorso
  distanceToFinish,    // Distanza dall'arrivo (es. 5km, 1km)
  climbStart,          // Inizio salita
  climbEnd,            // Fine salita
  halfway,             // Metà percorso
  approachingTurn,     // Prossima svolta significativa
}

/// Types of alert actions
enum AlertActionType {
  none,       // Nessun alert
  vibration,  // Solo vibrazione
  voice,      // Solo voce
  both,       // Vibrazione + voce
}

class AlertRule {
  int? id;

  /// Event type that triggers this rule (stored as index of AlertEventType)
  late int eventTypeIndex;

  /// Action to perform (stored as index of AlertActionType)
  late int actionIndex;

  /// Custom voice message (Italian)
  String? voiceMessage;

  /// Trigger value (e.g., 5.0 for "5km to finish", 30.0 for "30m off course")
  double? triggerValue;

  /// Whether this rule is enabled
  bool isEnabled = true;

  /// Order for display
  int displayOrder = 0;

  // ==================== Computed Properties ====================

  AlertEventType get eventType => AlertEventType.values[eventTypeIndex];
  set eventType(AlertEventType type) => eventTypeIndex = type.index;

  AlertActionType get action => AlertActionType.values[actionIndex];
  set action(AlertActionType type) => actionIndex = type.index;

  // ==================== Helper Methods ====================

  /// Get a human-readable name for this event type (Italian)
  String get eventName {
    switch (eventType) {
      case AlertEventType.offCourse:
        return 'Fuori percorso';
      case AlertEventType.distanceToFinish:
        return 'Distanza dall\'arrivo';
      case AlertEventType.climbStart:
        return 'Inizio salita';
      case AlertEventType.climbEnd:
        return 'Fine salita';
      case AlertEventType.halfway:
        return 'Metà percorso';
      case AlertEventType.approachingTurn:
        return 'Prossima svolta';
    }
  }

  /// Get a human-readable description for this rule
  String get description {
    String actionDesc;
    switch (action) {
      case AlertActionType.none:
        actionDesc = 'Nessun alert';
        break;
      case AlertActionType.vibration:
        actionDesc = 'Vibrazione';
        break;
      case AlertActionType.voice:
        actionDesc = 'Messaggio vocale';
        break;
      case AlertActionType.both:
        actionDesc = 'Vibrazione + Voce';
        break;
    }

    if (triggerValue != null) {
      if (eventType == AlertEventType.offCourse) {
        return '$actionDesc a ${triggerValue!.toInt()}m dal percorso';
      } else if (eventType == AlertEventType.distanceToFinish) {
        return '$actionDesc a ${triggerValue!.toInt()}km dall\'arrivo';
      }
    }
    return actionDesc;
  }

  /// Get the default voice message for this event type
  String get defaultVoiceMessage {
    switch (eventType) {
      case AlertEventType.offCourse:
        return 'Ehi, dove vai? La strada è dall\'altra parte, torna sulla traccia!';
      case AlertEventType.distanceToFinish:
        if (triggerValue != null) {
          final km = triggerValue!.toInt();
          return km == 1 
              ? 'Manca 1 chilometro all\'arrivo' 
              : 'Mancano $km chilometri all\'arrivo';
        }
        return 'Ti stai avvicinando all\'arrivo';
      case AlertEventType.climbStart:
        return 'Inizia una salita';
      case AlertEventType.climbEnd:
        return 'Fine della salita';
      case AlertEventType.halfway:
        return 'Hai raggiunto metà percorso';
      case AlertEventType.approachingTurn:
        return 'Svolta tra poco';
    }
  }

  /// Get the effective voice message (custom or default)
  String get effectiveVoiceMessage => voiceMessage ?? defaultVoiceMessage;

  // ==================== Factory Methods ====================

  /// Create default rules for a new user
  static List<AlertRule> createDefaultRules() {
    return [
      // Off course - both vibration and voice at 30m
      AlertRule()
        ..eventType = AlertEventType.offCourse
        ..action = AlertActionType.both
        ..triggerValue = 30.0
        ..displayOrder = 0,

      // 5km to finish - voice only
      AlertRule()
        ..eventType = AlertEventType.distanceToFinish
        ..action = AlertActionType.voice
        ..triggerValue = 5.0
        ..displayOrder = 1,

      // 1km to finish - voice only
      AlertRule()
        ..eventType = AlertEventType.distanceToFinish
        ..action = AlertActionType.voice
        ..triggerValue = 1.0
        ..displayOrder = 2,

      // Climb start - voice only
      AlertRule()
        ..eventType = AlertEventType.climbStart
        ..action = AlertActionType.voice
        ..displayOrder = 3,

      // Halfway - voice only
      AlertRule()
        ..eventType = AlertEventType.halfway
        ..action = AlertActionType.voice
        ..displayOrder = 4,
    ];
  }
}
