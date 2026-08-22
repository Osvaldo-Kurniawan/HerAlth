import '../../domain/models/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_local_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource _localDataSource;

  UserProfileRepositoryImpl(this._localDataSource);

  @override
  Future<UserProfile?> getUserProfile() {
    return _localDataSource.getUserProfile();
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) {
    return _localDataSource.saveUserProfile(profile);
  }

  @override
  Future<CycleSettings?> getCycleSettings() {
    return _localDataSource.getCycleSettings();
  }

  @override
  Future<void> saveCycleSettings(CycleSettings settings) {
    return _localDataSource.saveCycleSettings(settings);
  }

  @override
  Future<ReminderSettings?> getReminderSettings() {
    return _localDataSource.getReminderSettings();
  }

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) {
    return _localDataSource.saveReminderSettings(settings);
  }

  @override
  Future<AiSettings?> getAiSettings() {
    return _localDataSource.getAiSettings();
  }

  @override
  Future<void> saveAiSettings(AiSettings settings) {
    return _localDataSource.saveAiSettings(settings);
  }

  @override
  Future<void> clearAllData() {
    return _localDataSource.clearAllData();
  }
}
