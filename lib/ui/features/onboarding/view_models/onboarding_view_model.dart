import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../domain/models/backup.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/models/cycle.dart';
import '../../../../domain/repositories/cycle_repository.dart';
import '../../../../domain/repositories/user_profile_repository.dart';

class OnboardingViewModel extends ChangeNotifier {
  final UserProfileRepository _userProfileRepository;
  final CycleRepository _cycleRepository;

  OnboardingViewModel(this._userProfileRepository, this._cycleRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _currentStep = 0; // 0: Welcome, 1: Privacy, 2: Last Period, 3: Cycle Length, 4: Period Duration, 5: Goal, 6: Review, 7: Restore
  int get currentStep => _currentStep;

  // Onboarding parameters
  DateTime? _lastPeriodDate;
  DateTime? get lastPeriodDate => _lastPeriodDate;

  int _cycleLength = 28;
  int get cycleLength => _cycleLength;

  int _periodDuration = 5;
  int get periodDuration => _periodDuration;

  String _goal = '';
  String get goal => _goal;

  String? _restoreStatusMessage;
  String? get restoreStatusMessage => _restoreStatusMessage;

  void nextStep() {
    _currentStep++;
    notifyListeners();
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setLastPeriod(DateTime date) {
    _lastPeriodDate = date;
    notifyListeners();
  }

  void setCycleLength(int length) {
    _cycleLength = length;
    notifyListeners();
  }

  void setPeriodDuration(int duration) {
    _periodDuration = duration;
    notifyListeners();
  }

  void setGoal(String goal) {
    _goal = goal;
    notifyListeners();
  }

  Future<bool> restoreFromBackupString(String jsonStr) async {
    _isLoading = true;
    _restoreStatusMessage = 'Validating and restoring backup...';
    notifyListeners();

    try {
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      // Validate schema minimally by checking exportedAt
      if (!data.containsKey('exportedAt')) {
        _restoreStatusMessage = 'Invalid backup file format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // We can use the backup repository implementation to restore
      // Let's write a method in BackupRepository or perform direct restore
      // Since our BackupRepositoryImpl.restoreBackup takes sourceFilePath,
      // and we have a JSON string here, let's restore it locally
      final backupData = BackupData.fromJson(data);

      if (backupData.userProfile != null) {
        await _userProfileRepository.saveUserProfile(backupData.userProfile!);
      }
      if (backupData.cycleSettings != null) {
        await _userProfileRepository.saveCycleSettings(
          backupData.cycleSettings!,
        );
      }
      if (backupData.reminderSettings != null) {
        await _userProfileRepository.saveReminderSettings(
          backupData.reminderSettings!,
        );
      }

      _restoreStatusMessage = 'Restore successful!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _restoreStatusMessage = 'Error restoring backup: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    _isLoading = true;
    notifyListeners();

    try {
      const profile = UserProfile(
        name: 'Jane Doe',
        age: 28,
        height: 165.0,
        weight: 60.0,
      );
      final settings = CycleSettings(
        averageCycleLength: _cycleLength,
        averagePeriodDuration: _periodDuration,
      );
      const reminders = ReminderSettings(
        periodReminderEnabled: true,
        fertilityReminderEnabled: true,
        checkUpReminderEnabled: true,
        cycleRemindersEnabled: true,
      );

      await _userProfileRepository.saveUserProfile(profile);
      await _userProfileRepository.saveCycleSettings(settings);
      await _userProfileRepository.saveReminderSettings(reminders);

      if (_lastPeriodDate != null) {
        final newCycle = Cycle(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          startDate: _lastPeriodDate!,
          flowIntensity: 'Medium',
        );
        await _cycleRepository.saveCycle(newCycle);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
