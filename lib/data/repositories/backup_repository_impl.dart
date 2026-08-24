import 'dart:io';
import '../../domain/models/backup.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/repositories/check_up_repository.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../services/backup_service.dart';

class BackupRepositoryImpl implements BackupRepository {
  final UserProfileRepository _userProfileRepository;
  final CycleRepository _cycleRepository;
  final CheckUpRepository _checkUpRepository;
  final ReportRepository _reportRepository;
  final BackupService _backupService;

  BackupRepositoryImpl(
    this._userProfileRepository,
    this._cycleRepository,
    this._checkUpRepository,
    this._reportRepository,
    this._backupService,
  );

  @override
  Future<void> createBackup(String targetFilePath) async {
    final profile = await _userProfileRepository.getUserProfile();
    final settings = await _userProfileRepository.getCycleSettings();
    final reminders = await _userProfileRepository.getReminderSettings();
    final ai = await _userProfileRepository.getAiSettings();
    final cycles = await _cycleRepository.getCycles();
    final entries = await _cycleRepository.getCycleEntries();
    final checkUps = await _checkUpRepository.getCheckUps();
    final analysis = await _checkUpRepository.getAnalysisResults();
    final reports = await _reportRepository.getReports();

    final backupData = BackupData(
      userProfile: profile,
      cycleSettings: settings,
      reminderSettings: reminders,
      aiSettings: ai,
      cycles: cycles,
      cycleEntries: entries,
      checkUps: checkUps,
      analysisResults: analysis,
      reports: reports,
      exportedAt: DateTime.now(),
    );

    final backupString = await _backupService.exportBackup(backupData);
    final file = File(targetFilePath);
    await file.writeAsString(backupString);
  }

  @override
  Future<void> restoreBackup(String sourceFilePath) async {
    final file = File(sourceFilePath);
    if (!await file.exists()) {
      throw FileSystemException('Backup file not found', sourceFilePath);
    }
    final jsonStr = await file.readAsString();
    final backupData = await _backupService.importBackup(jsonStr);

    if (backupData.userProfile != null) {
      await _userProfileRepository.saveUserProfile(backupData.userProfile!);
    }
    if (backupData.cycleSettings != null) {
      await _userProfileRepository.saveCycleSettings(backupData.cycleSettings!);
    }
    if (backupData.reminderSettings != null) {
      await _userProfileRepository.saveReminderSettings(
        backupData.reminderSettings!,
      );
    }
    if (backupData.aiSettings != null) {
      await _userProfileRepository.saveAiSettings(backupData.aiSettings!);
    }

    for (var cycle in backupData.cycles) {
      await _cycleRepository.saveCycle(cycle);
    }
    for (var entry in backupData.cycleEntries) {
      await _cycleRepository.saveCycleEntry(entry);
    }
    for (var checkUp in backupData.checkUps) {
      await _checkUpRepository.saveCheckUp(checkUp);
    }
    for (var result in backupData.analysisResults) {
      await _checkUpRepository.saveAnalysisResult(result);
    }
    for (var report in backupData.reports) {
      await _reportRepository.saveReport(report);
    }
  }
}
