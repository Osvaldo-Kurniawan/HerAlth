import '../../core/database/database_service.dart';
import '../../domain/models/user_profile.dart';

abstract class UserProfileLocalDataSource {
  Future<UserProfile?> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);

  Future<CycleSettings?> getCycleSettings();
  Future<void> saveCycleSettings(CycleSettings settings);

  Future<ReminderSettings?> getReminderSettings();
  Future<void> saveReminderSettings(ReminderSettings settings);

  Future<AiSettings?> getAiSettings();
  Future<void> saveAiSettings(AiSettings settings);

  Future<void> clearAllData();
}

class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  final DatabaseService _databaseService;

  UserProfileLocalDataSourceImpl(this._databaseService);

  @override
  Future<UserProfile?> getUserProfile() async {
    final db = await _databaseService.database;
    final maps = await db.query(DatabaseConstants.tableUserProfile, limit: 1);
    if (maps.isEmpty) return null;
    return UserProfile.fromJson(maps.first);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseConstants.tableUserProfile);
      await txn.insert(DatabaseConstants.tableUserProfile, profile.toJson());
    });
  }

  @override
  Future<CycleSettings?> getCycleSettings() async {
    final db = await _databaseService.database;
    final maps = await db.query(DatabaseConstants.tableCycleSettings, limit: 1);
    if (maps.isEmpty) return null;
    return CycleSettings.fromJson(maps.first);
  }

  @override
  Future<void> saveCycleSettings(CycleSettings settings) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseConstants.tableCycleSettings);
      await txn.insert(DatabaseConstants.tableCycleSettings, settings.toJson());
    });
  }

  @override
  Future<ReminderSettings?> getReminderSettings() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      DatabaseConstants.tableReminderSettings,
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ReminderSettings.fromJson(maps.first);
  }

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseConstants.tableReminderSettings);
      await txn.insert(
        DatabaseConstants.tableReminderSettings,
        settings.toJson(),
      );
    });
  }

  @override
  Future<AiSettings?> getAiSettings() async {
    final db = await _databaseService.database;
    final maps = await db.query(DatabaseConstants.tableAiSettings, limit: 1);
    if (maps.isEmpty) return null;
    return AiSettings.fromJson(maps.first);
  }

  @override
  Future<void> saveAiSettings(AiSettings settings) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseConstants.tableAiSettings);
      await txn.insert(DatabaseConstants.tableAiSettings, settings.toJson());
    });
  }

  @override
  Future<void> clearAllData() async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseConstants.tableUserProfile);
      await txn.delete(DatabaseConstants.tableCycleSettings);
      await txn.delete(DatabaseConstants.tableReminderSettings);
      await txn.delete(DatabaseConstants.tableAiSettings);
      await txn.delete(DatabaseConstants.tableCycle);
      await txn.delete(DatabaseConstants.tableCycleEntry);
      await txn.delete(DatabaseConstants.tableCheckUp);
      await txn.delete(DatabaseConstants.tableSymptom);
      await txn.delete(DatabaseConstants.tableAnalysisResult);
      await txn.delete(DatabaseConstants.tableReport);
    });
  }
}
