import 'dart:convert';
import '../../domain/models/backup.dart';

abstract class BackupService {
  Future<String> exportBackup(BackupData data);
  Future<BackupData> importBackup(String backupJson);
}

class BackupServiceImpl implements BackupService {
  @override
  Future<String> exportBackup(BackupData data) async {
    return json.encode(data.toJson());
  }

  @override
  Future<BackupData> importBackup(String backupJson) async {
    final Map<String, dynamic> data = json.decode(backupJson) as Map<String, dynamic>;
    return BackupData.fromJson(data);
  }
}
