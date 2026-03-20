import 'dart:convert';
/// Represents a single component replacement event.
class ReplacementRecord {
  final DateTime date;
  final double kmAtReplacement;

  ReplacementRecord({required this.date, required this.kmAtReplacement});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'km': kmAtReplacement,
  };

  factory ReplacementRecord.fromJson(Map<String, dynamic> json) =>
      ReplacementRecord(
        date: DateTime.parse(json['date'] as String),
        kmAtReplacement: (json['km'] as num?)?.toDouble() ?? 0.0,
      );
}

class BicycleComponent {
  String? name;
  double currentKm = 0.0;
  double limitKm = 3000.0;
  DateTime? lastMaintenance;

  // Stored as JSON string to avoid Isar schema regeneration
  String? replacementHistoryJson;

  List<ReplacementRecord> get replacementHistory {
    if (replacementHistoryJson == null || replacementHistoryJson!.isEmpty) return [];
    try {
      final list = json.decode(replacementHistoryJson!) as List;
      return list.map((e) => ReplacementRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  void addReplacement(ReplacementRecord record) {
    final history = replacementHistory;
    history.insert(0, record); // newest first
    replacementHistoryJson = json.encode(history.map((e) => e.toJson()).toList());
  }
}

class Bicycle {
  // Supabase uses UUID Strings
  String? id;
  
  String? userId; // Supabase user id

  /// Dynamic list of components for maintenance
  List<BicycleComponent> components = [];

  /// Name of the bicycle (e.g., "My Road Bike")
  late String name;

  /// Type of bicycle (e.g., "Road", "MTB", "Gravel", "City")
  late String type;

  /// Gearing system type (e.g., "Mechanical", "Electronic", "Single Speed")
  late String gearingSystem;

  /// Total distance traveled by this bicycle in km (manual + auto)
  double totalKilometers = 0.0;

  /// Kilometers ridden with current chain
  double chainKms = 0.0;

  /// Kilometers ridden with current tyres
  double tyreKms = 0.0;
  
  /// Customizable Thresholds
  double chainLimitKm = 3500.0; // Default Road
  double tyreLimitKm = 5000.0;  // Default Road
  double brakeLimitKm = 2500.0; // Default Road

  /// Service interval threshold in km (e.g., 5000km for full checkup)
  double serviceIntervalKms = 5000.0;

  /// Local path to bicycle image
  String? bikeImagePath;
  
  /// E-Bike battery capacity in Watt-hours (Wh)
  /// null for non-electric bikes
  double? batteryCapacityWh;
  
  /// E-Bike assistance level (1-5)
  int assistanceLevel = 3;
  
  /// Bike weight in kg (used for energy calculations)
  double bikeWeightKg = 12.0;

  /// Date of the last maintenance
  late DateTime lastMaintenance;

  /// Timestamp when the bicycle was added
  late DateTime createdAt;

  Bicycle() {
    createdAt = DateTime.now();
  }

  void applyDefaults() {
    bool isMtbOrEbike = type.toLowerCase().contains('mtb') || 
                        type.toLowerCase().contains('e-bike') || 
                        type.toLowerCase().contains('ebike');
    
    // Set legacy defaults for backward compatibility (optional)
    if (isMtbOrEbike) {
      chainLimitKm = 2000.0;
      tyreLimitKm = 3000.0;
      brakeLimitKm = 1500.0;
    } else {
      chainLimitKm = 3500.0;
      tyreLimitKm = 5000.0;
      brakeLimitKm = 2500.0;
    }

    // Initialize components if empty
    if (components.isEmpty) {
      // Migrate legacy fields if they have value
      if (chainKms > 0 || tyreKms > 0) {
        components.add(BicycleComponent()
          ..name = 'Catena'
          ..currentKm = chainKms
          ..limitKm = chainLimitKm
          ..lastMaintenance = lastMaintenance
        );
        components.add(BicycleComponent()
          ..name = 'Copertoni'
          ..currentKm = tyreKms
          ..limitKm = tyreLimitKm
          ..lastMaintenance = lastMaintenance
        );
      } else {
        // Fresh start
        components.add(BicycleComponent()..name = 'Catena'..limitKm = chainLimitKm);
        components.add(BicycleComponent()..name = 'Copertoni'..limitKm = tyreLimitKm);
        components.add(BicycleComponent()..name = 'Freni'..limitKm = brakeLimitKm);
      }
    }
  }
}
