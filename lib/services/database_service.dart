import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';
import '../models/bicycle.dart';
import '../models/planned_ride.dart';
import '../models/health_snapshot.dart';
import '../models/alert_rule.dart';

/// Singleton service for managing Isar database operations
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;

  /// Get the Isar instance
  Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call init() first.');
    }
    return _isar!;
  }

  /// Initialize the Isar database
  Future<void> init() async {
    if (_isar != null) return; // Already initialized

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        UserProfileSchema,
        BicycleSchema,
        PlannedRideSchema,
        HealthSnapshotSchema,
        AlertRuleSchema,
      ],
      directory: dir.path,
    );
  }

  /// Close the database
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  // ==================== UserProfile CRUD ====================

  /// Create or update user profile
  Future<int> saveUserProfile(UserProfile profile) async {
    profile.updatedAt = DateTime.now();
    return await isar.writeTxn(() async {
      return await isar.userProfiles.put(profile);
    });
  }

  /// Get the user profile (assumes single user)
  Future<UserProfile?> getUserProfile() async {
    return await isar.userProfiles.where().findFirst();
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    profile.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.userProfiles.put(profile);
    });
  }

  // ==================== Bicycle CRUD ====================

  /// Create a new bicycle
  Future<int> createBicycle(Bicycle bicycle) async {
    return await isar.writeTxn(() async {
      return await isar.bicycles.put(bicycle);
    });
  }

  /// Get all bicycles
  Future<List<Bicycle>> getAllBicycles() async {
    return await isar.bicycles.where().findAll();
  }

  /// Get a bicycle by ID
  Future<Bicycle?> getBicycleById(int id) async {
    return await isar.bicycles.get(id);
  }

  /// Update a bicycle
  Future<void> updateBicycle(Bicycle bicycle) async {
    await isar.writeTxn(() async {
      await isar.bicycles.put(bicycle);
    });
  }

  /// Delete a bicycle
  Future<bool> deleteBicycle(int id) async {
    return await isar.writeTxn(() async {
      return await isar.bicycles.delete(id);
    });
  }

  // ==================== PlannedRide CRUD ====================

  /// Create a new planned ride
  Future<int> createPlannedRide(PlannedRide ride) async {
    return await isar.writeTxn(() async {
      return await isar.plannedRides.put(ride);
    });
  }

  /// Get all planned rides
  Future<List<PlannedRide>> getAllPlannedRides() async {
    return await isar.plannedRides.where().sortByRideDate().findAll();
  }

  /// Get upcoming rides (future dates only)
  Future<List<PlannedRide>> getUpcomingRides() async {
    final now = DateTime.now();
    return await isar.plannedRides
        .where()
        .filter()
        .rideDateGreaterThan(now)
        .sortByRideDate()
        .findAll();
  }

  /// Get a planned ride by ID
  Future<PlannedRide?> getPlannedRideById(int id) async {
    return await isar.plannedRides.get(id);
  }

  /// Update a planned ride
  Future<void> updatePlannedRide(PlannedRide ride) async {
    await isar.writeTxn(() async {
      await isar.plannedRides.put(ride);
    });
  }

  /// Delete a planned ride
  Future<bool> deletePlannedRide(int id) async {
    return await isar.writeTxn(() async {
      return await isar.plannedRides.delete(id);
    });
  }

  /// Watch for changes in planned rides
  Stream<void> watchPlannedRides() {
    return isar.plannedRides.watchLazy();
  }

  /// Watch for changes in bicycles
  Stream<void> watchBicycles() {
    return isar.bicycles.watchLazy();
  }

  /// Get all completed rides
  Future<List<PlannedRide>> getCompletedRides() async {
    return await isar.plannedRides
        .filter()
        .isCompletedEqualTo(true)
        .sortByRideDateDesc()
        .findAll();
  }

  /// Get total km from all completed rides
  Future<double> getTotalCompletedKm() async {
    final completed = await getCompletedRides();
    return completed.fold<double>(0.0, (sum, ride) => sum + ride.distance);
  }

  /// Get km completed this week
  Future<double> getWeeklyCompletedKm() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    final completed = await isar.plannedRides
        .filter()
        .isCompletedEqualTo(true)
        .rideDateGreaterThan(startDate)
        .findAll();
    
    return completed.fold<double>(0.0, (sum, ride) => sum + ride.distance);
  }

  /// Get total number of completed rides
  Future<int> getTotalCompletedRidesCount() async {
    return await isar.plannedRides
        .filter()
        .isCompletedEqualTo(true)
        .count();
  }

  // ==================== HealthSnapshot CRUD ====================

  /// Create a new health snapshot
  Future<int> createHealthSnapshot(HealthSnapshot snapshot) async {
    return await isar.writeTxn(() async {
      return await isar.healthSnapshots.put(snapshot);
    });
  }

  /// Get recent health snapshots (last N days)
  Future<List<HealthSnapshot>> getRecentHealthSnapshots(int days) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    return await isar.healthSnapshots
        .where()
        .filter()
        .dateGreaterThan(startDate)
        .sortByDateDesc()
        .findAll();
  }

  /// Get health snapshots within a date range
  Future<List<HealthSnapshot>> getHealthSnapshotsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await isar.healthSnapshots
        .where()
        .filter()
        .dateBetween(startDate, endDate)
        .sortByDate()
        .findAll();
  }

  /// Get health snapshot for a specific date
  Future<HealthSnapshot?> getHealthSnapshotByDate(DateTime date) async {
    // Normalize to start of day for comparison
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final snapshots = await isar.healthSnapshots
        .where()
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .findAll();
    
    return snapshots.isNotEmpty ? snapshots.first : null;
  }

  /// Create or update a health snapshot
  Future<int> createOrUpdateHealthSnapshot(HealthSnapshot snapshot) async {
    return await isar.writeTxn(() async {
      return await isar.healthSnapshots.put(snapshot);
    });
  }

  /// Delete a health snapshot
  Future<bool> deleteHealthSnapshot(int id) async {
    return await isar.writeTxn(() async {
      return await isar.healthSnapshots.delete(id);
    });
  }

  // ==================== AlertRule CRUD ====================

  /// Get all alert rules, ordered by displayOrder
  Future<List<AlertRule>> getAlertRules() async {
    return await isar.alertRules.where().sortByDisplayOrder().findAll();
  }

  /// Get enabled alert rules only
  Future<List<AlertRule>> getEnabledAlertRules() async {
    return await isar.alertRules
        .filter()
        .isEnabledEqualTo(true)
        .sortByDisplayOrder()
        .findAll();
  }

  /// Save an alert rule
  Future<int> saveAlertRule(AlertRule rule) async {
    return await isar.writeTxn(() async {
      return await isar.alertRules.put(rule);
    });
  }

  /// Save multiple alert rules
  Future<void> saveAlertRules(List<AlertRule> rules) async {
    await isar.writeTxn(() async {
      await isar.alertRules.putAll(rules);
    });
  }

  /// Delete an alert rule
  Future<bool> deleteAlertRule(int id) async {
    return await isar.writeTxn(() async {
      return await isar.alertRules.delete(id);
    });
  }

  /// Initialize default alert rules if none exist
  Future<void> initDefaultAlertRulesIfNeeded() async {
    final existing = await getAlertRules();
    if (existing.isEmpty) {
      final defaults = AlertRule.createDefaultRules();
      await saveAlertRules(defaults);
    }
  }
}
