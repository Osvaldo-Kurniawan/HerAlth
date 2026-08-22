import 'user_profile.dart';
import 'cycle.dart';
import 'check_up.dart';
import 'report.dart';

class BackupData {
  final UserProfile? userProfile;
  final CycleSettings? cycleSettings;
  final ReminderSettings? reminderSettings;
  final AiSettings? aiSettings;
  final List<Cycle> cycles;
  final List<CycleEntry> cycleEntries;
  final List<CheckUp> checkUps;
  final List<AnalysisResult> analysisResults;
  final List<Report> reports;
  final DateTime exportedAt;

  const BackupData({
    this.userProfile,
    this.cycleSettings,
    this.reminderSettings,
    this.aiSettings,
    required this.cycles,
    required this.cycleEntries,
    required this.checkUps,
    required this.analysisResults,
    required this.reports,
    required this.exportedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userProfile': userProfile?.toJson(),
      'cycleSettings': cycleSettings?.toJson(),
      'reminderSettings': reminderSettings?.toJson(),
      'aiSettings': aiSettings?.toJson(),
      'cycles': cycles.map((e) => e.toJson()).toList(),
      'cycleEntries': cycleEntries.map((e) => e.toJson()).toList(),
      'checkUps': checkUps.map((e) => e.toJson()).toList(),
      'analysisResults': analysisResults.map((e) => e.toJson()).toList(),
      'reports': reports.map((e) => e.toJson()).toList(),
      'exportedAt': exportedAt.toIso8601String(),
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      userProfile: json['userProfile'] != null
          ? UserProfile.fromJson(json['userProfile'])
          : null,
      cycleSettings: json['cycleSettings'] != null
          ? CycleSettings.fromJson(json['cycleSettings'])
          : null,
      reminderSettings: json['reminderSettings'] != null
          ? ReminderSettings.fromJson(json['reminderSettings'])
          : null,
      aiSettings: json['aiSettings'] != null
          ? AiSettings.fromJson(json['aiSettings'])
          : null,
      cycles:
          (json['cycles'] as List?)?.map((e) => Cycle.fromJson(e)).toList() ??
          [],
      cycleEntries:
          (json['cycleEntries'] as List?)
              ?.map((e) => CycleEntry.fromJson(e))
              .toList() ??
          [],
      checkUps:
          (json['checkUps'] as List?)
              ?.map((e) => CheckUp.fromJson(e))
              .toList() ??
          [],
      analysisResults:
          (json['analysisResults'] as List?)
              ?.map((e) => AnalysisResult.fromJson(e))
              .toList() ??
          [],
      reports:
          (json['reports'] as List?)?.map((e) => Report.fromJson(e)).toList() ??
          [],
      exportedAt: DateTime.parse(
        json['exportedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
