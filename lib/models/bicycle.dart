import 'package:isar/isar.dart';

part 'bicycle.g.dart';

@embedded
class BicycleComponent {
  String? name;
  double currentKm = 0.0;
  double limitKm = 3000.0;
  DateTime? lastMaintenance;
}

@collection
class Bicycle {
  Id id = Isar.autoIncrement;
  
  /// Dynamic list of components for maintenance
  List<BicycleComponent> components = [];

  /// Name of the bicycle (e.g., "My Road Bike")
  late String name;

  /// Type of bicycle (e.g., "Road", "MTB", "Gravel", "City")
  @Index()
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
