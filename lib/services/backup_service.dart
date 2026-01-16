import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_service.dart';
import '../models/user_profile.dart';
import '../models/bicycle.dart';
import '../models/planned_ride.dart';
import '../models/health_snapshot.dart';
import 'package:flutter/foundation.dart';

/// Service for exporting and importing the application database as JSON
class BackupService {
  final _db = DatabaseService();

  /// Export all database collections to a JSON file and share it
  Future<void> exportBackup() async {
    final isar = _db.isar;
    
    final data = {
      'user_profiles': await isar.userProfiles.where().exportJson(),
      'bicycles': await isar.bicycles.where().exportJson(),
      'planned_rides': await isar.plannedRides.where().exportJson(),
      'health_snapshots': await isar.healthSnapshots.where().exportJson(),
      'exported_at': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };

    final jsonString = jsonEncode(data);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/biciclistico_backup.json');
    
    await file.writeAsString(jsonString);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Biciclistico Database Backup',
      ),
    );
  }

  /// Import database from a JSON file string
  Future<void> importBackup(String jsonContent) async {
    final isar = _db.isar;
    final Map<String, dynamic> data = jsonDecode(jsonContent);

    await isar.writeTxn(() async {
      // 1. Clear existing data
      await isar.userProfiles.clear();
      await isar.bicycles.clear();
      await isar.plannedRides.clear();
      await isar.healthSnapshots.clear();

      // 2. Import new data
      if (data.containsKey('user_profiles')) {
        await isar.userProfiles.importJson(List<Map<String, dynamic>>.from(data['user_profiles']));
      }
      if (data.containsKey('bicycles')) {
        await isar.bicycles.importJson(List<Map<String, dynamic>>.from(data['bicycles']));
      }
      if (data.containsKey('planned_rides')) {
        await isar.plannedRides.importJson(List<Map<String, dynamic>>.from(data['planned_rides']));
      }
      if (data.containsKey('health_snapshots')) {
        await isar.healthSnapshots.importJson(List<Map<String, dynamic>>.from(data['health_snapshots']));
      }
    });
    
    debugPrint('Database import successful');
  }
}
