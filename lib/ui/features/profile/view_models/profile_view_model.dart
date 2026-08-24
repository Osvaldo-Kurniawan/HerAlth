import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/database_service.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/models/cycle.dart';
import '../../../../domain/repositories/backup_repository.dart';
import '../../../../domain/repositories/check_up_repository.dart';
import '../../../../domain/repositories/user_profile_repository.dart';
import '../../../../domain/repositories/cycle_repository.dart';
import '../../../../domain/repositories/check_up_repository.dart';
import '../../../../domain/repositories/report_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserProfileRepository _userProfileRepository;
  final BackupRepository _backupRepository;
  final CheckUpRepository? _checkUpRepository;

  ProfileViewModel(
    this._userProfileRepository,
    this._backupRepository, {
    CheckUpRepository? checkUpRepository,
  }) : _checkUpRepository = checkUpRepository;
  final CycleRepository _cycleRepository;

  ProfileViewModel(
    this._userProfileRepository,
    this._backupRepository,
    this._cycleRepository,
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  CycleSettings? _cycleSettings;
  CycleSettings? get cycleSettings => _cycleSettings;

  ReminderSettings? _reminderSettings;
  ReminderSettings? get reminderSettings => _reminderSettings;

  AiSettings? _aiSettings;
  AiSettings? get aiSettings => _aiSettings;

  int _checkUpCount = 0;
  int get checkUpCount => _checkUpCount;

  DateTime? _latestCheckUpDate;
  DateTime? get latestCheckUpDate => _latestCheckUpDate;
  DateTime? _lastPeriodDate;
  DateTime? get lastPeriodDate => _lastPeriodDate;

  double _storageSizeMb = 0.0;
  double get storageSizeMb => _storageSizeMb;

  Future<void> loadProfileData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _userProfileRepository.getUserProfile();
      _cycleSettings = await _userProfileRepository.getCycleSettings();
      _reminderSettings = await _userProfileRepository.getReminderSettings();
      _aiSettings = await _userProfileRepository.getAiSettings();
      final checkUps = await _checkUpRepository?.getCheckUps() ?? [];
      _checkUpCount = checkUps.length;
      _latestCheckUpDate = checkUps.isEmpty ? null : checkUps.first.date;

      final cycles = await _cycleRepository.getCycles();
      if (cycles.isNotEmpty) {
        _lastPeriodDate = cycles.first.startDate;
      } else {
        _lastPeriodDate = null;
      }

      _storageSizeMb = await _calculateDbSize();
    } catch (e) {
      _errorMessage = 'Failed to load profile data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<double> _calculateDbSize() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, DatabaseConstants.databaseName);
      final file = File(path);
      if (await file.exists()) {
        final length = await file.length();
        return length / (1024 * 1024);
      }
    } catch (_) {}
    return 4.2; // Fallback value
  }

  Future<void> updateNickname(String nickname) async {
    try {
      if (_profile != null) {
        final updated = _profile!.copyWith(name: nickname);
        await _userProfileRepository.saveUserProfile(updated);
      } else {
        final updated = UserProfile(
          name: nickname,
          age: 28,
          height: 165.0,
          weight: 60.0,
        );
        await _userProfileRepository.saveUserProfile(updated);
      }
      await loadProfileData();
    } catch (e) {
      _errorMessage = 'Failed to update nickname.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCycleLength(int length) async {
    try {
      if (_cycleSettings != null) {
        final updated = _cycleSettings!.copyWith(averageCycleLength: length);
        await _userProfileRepository.saveCycleSettings(updated);
      } else {
        final updated = CycleSettings(
          averageCycleLength: length,
          averagePeriodDuration: 5,
        );
        await _userProfileRepository.saveCycleSettings(updated);
      }
      await loadProfileData();
    } catch (e) {
      _errorMessage = 'Failed to update cycle length.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePeriodDuration(int duration) async {
    try {
      if (_cycleSettings != null) {
        final updated = _cycleSettings!.copyWith(averagePeriodDuration: duration);
        await _userProfileRepository.saveCycleSettings(updated);
      } else {
        final updated = CycleSettings(
          averageCycleLength: 28,
          averagePeriodDuration: duration,
        );
        await _userProfileRepository.saveCycleSettings(updated);
      }
      await loadProfileData();
    } catch (e) {
      _errorMessage = 'Failed to update period duration.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateLastPeriodDate(DateTime date) async {
    try {
      final cycles = await _cycleRepository.getCycles();
      if (cycles.isNotEmpty) {
        final updatedCycle = cycles.first.copyWith(startDate: date);
        await _cycleRepository.saveCycle(updatedCycle);
      } else {
        final newCycle = Cycle(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          startDate: date,
          flowIntensity: 'Medium',
        );
        await _cycleRepository.saveCycle(newCycle);
      }
      await loadProfileData();
    } catch (e) {
      _errorMessage = 'Failed to update last period date.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateReminderSettings(ReminderSettings settings) async {
    try {
      await _userProfileRepository.saveReminderSettings(settings);
      await loadProfileData();
    } catch (e) {
      _errorMessage = 'Failed to update reminder settings.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAiSettings(AiSettings settings) async {
    try {
      await _userProfileRepository.saveAiSettings(settings);
      await loadProfileData();
    } catch (e) {
      _errorMessage = 'Failed to update AI settings.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> exportBackup(String path) async {
    try {
      await _backupRepository.createBackup(path);
    } catch (e) {
      _errorMessage = 'Failed to export backup.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearCheckUpHistory(
    CheckUpRepository checkUpRepository,
    ReportRepository reportRepository,
  ) async {
    try {
      final checkUps = await checkUpRepository.getCheckUps();
      for (var checkUp in checkUps) {
        await checkUpRepository.deleteCheckUp(checkUp.id);
      }
      final reports = await reportRepository.getReports();
      for (var report in reports) {
        await reportRepository.deleteReport(report.id);
      }
      await loadProfileData();
    } catch (e) {
      _errorMessage = 'Failed to clear check-up history.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _userProfileRepository.clearAllData();
      await loadProfileData();
    } catch (e) {
      _errorMessage = 'Failed to clear all data.';
      notifyListeners();
      rethrow;
    }
  }
}
