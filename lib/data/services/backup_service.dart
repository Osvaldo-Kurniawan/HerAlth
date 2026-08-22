import '../../domain/models/backup.dart';

abstract class BackupService {
  Future<String> exportBackup(BackupData data);
  Future<BackupData> importBackup(String backupJson);
}

class BackupServiceImpl implements BackupService {
  @override
  Future<String> exportBackup(BackupData data) async {
    // Serialization skeleton: Converts BackupData to JSON string
    // In future, this can write to a file or encrypt the string.
    return '';
  }

  @override
  Future<BackupData> importBackup(String backupJson) async {
    // Deserialization skeleton: Converts JSON string back to BackupData
    return BackupData(
      cycles: [],
      cycleEntries: [],
      checkUps: [],
      analysisResults: [],
      reports: [],
      exportedAt: DateTime.now(),
    );
  }
}
