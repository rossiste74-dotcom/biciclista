import 'package:flutter/foundation.dart';
import 'database_service.dart';

/// Legacy Backup Service - Now using Cloud
class BackupService {
  final _db = DatabaseService();

  Future<void> exportBackup() async {
    // Legacy functionality removed for Cloud-Only architecture
    debugPrint('Export not supported in Cloud-Only mode yet');
  }

  Future<void> importBackup(String jsonContent) async {
    // Legacy functionality removed
    debugPrint('Import not supported in Cloud-Only mode yet');
  }
}
