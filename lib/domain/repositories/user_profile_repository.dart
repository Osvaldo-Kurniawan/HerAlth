import '../models/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);

  Future<CycleSettings?> getCycleSettings();
  Future<void> saveCycleSettings(CycleSettings settings);

  Future<ReminderSettings?> getReminderSettings();
  Future<void> saveReminderSettings(ReminderSettings settings);

  Future<void> clearAllData();
}
