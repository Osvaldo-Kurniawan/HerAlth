import 'package:flutter/material.dart';

import '../../../../domain/models/user_profile.dart';
import '../../../../domain/repositories/backup_repository.dart';
import '../../../../domain/repositories/user_profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserProfileRepository _userProfileRepository;
  final BackupRepository _backupRepository;

  ProfileViewModel(this._userProfileRepository, this._backupRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  CycleSettings? _cycleSettings;
  CycleSettings? get cycleSettings => _cycleSettings;

  ReminderSettings? _reminderSettings;
  ReminderSettings? get reminderSettings => _reminderSettings;

  AiSettings? _aiSettings;
  AiSettings? get aiSettings => _aiSettings;

  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _userProfileRepository.getUserProfile();
      _cycleSettings = await _userProfileRepository.getCycleSettings();
      _reminderSettings = await _userProfileRepository.getReminderSettings();
      _aiSettings = await _userProfileRepository.getAiSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _userProfileRepository.saveUserProfile(profile);
    await loadProfileData();
  }

  Future<void> updateCycleSettings(CycleSettings settings) async {
    await _userProfileRepository.saveCycleSettings(settings);
    await loadProfileData();
  }

  Future<void> updateReminderSettings(ReminderSettings settings) async {
    await _userProfileRepository.saveReminderSettings(settings);
    await loadProfileData();
  }

  Future<void> updateAiSettings(AiSettings settings) async {
    await _userProfileRepository.saveAiSettings(settings);
    await loadProfileData();
  }

  Future<void> exportBackup(String path) async {
    await _backupRepository.createBackup(path);
  }

  Future<void> importBackup(String path) async {
    await _backupRepository.restoreBackup(path);
    await loadProfileData();
  }

  Future<void> clearAllData() async {
    await _userProfileRepository.clearAllData();
    await loadProfileData();
  }
}
