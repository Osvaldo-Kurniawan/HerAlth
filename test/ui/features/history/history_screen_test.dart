import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/domain/models/check_up.dart';
import 'package:heralth/domain/models/cycle.dart';
import 'package:heralth/domain/models/report.dart';
import 'package:heralth/domain/models/user_profile.dart';
import 'package:heralth/domain/repositories/check_up_repository.dart';
import 'package:heralth/domain/repositories/cycle_repository.dart';
import 'package:heralth/domain/repositories/report_repository.dart';
import 'package:heralth/domain/repositories/user_profile_repository.dart';
import 'package:heralth/ui/features/history/view_models/history_view_model.dart';
import 'package:heralth/ui/features/history/views/history_screen.dart';

class _FakeCheckUpRepository implements CheckUpRepository {
  final List<CheckUp> checkUps;
  final List<AnalysisResult> analysisResults;

  _FakeCheckUpRepository(this.checkUps, this.analysisResults);

  @override
  Future<void> deleteCheckUp(String id) async {}

  @override
  Future<List<AnalysisResult>> getAnalysisResults() async => analysisResults;

  @override
  Future<List<CheckUp>> getCheckUps() async => checkUps;

  @override
  Future<void> saveAnalysisResult(AnalysisResult result) async {}

  @override
  Future<void> saveCheckUp(CheckUp checkUp) async {}
}

class _FakeCycleRepository implements CycleRepository {
  final List<Cycle> cycles;

  _FakeCycleRepository(this.cycles);

  @override
  Future<void> deleteCycle(String id) async {}

  @override
  Future<void> deleteCycleEntry(String id) async {}

  @override
  Future<List<Cycle>> getCycles() async => cycles;

  @override
  Future<List<CycleEntry>> getCycleEntries() async => <CycleEntry>[];

  @override
  Future<void> saveCycle(Cycle cycle) async {}

  @override
  Future<void> saveCycleEntry(CycleEntry entry) async {}
}

class _FakeReportRepository implements ReportRepository {
  @override
  Future<void> deleteReport(String id) async {}

  @override
  Future<List<Report>> getReports() async => <Report>[];

  @override
  Future<void> saveReport(Report report) async {}
}

class _FakeUserProfileRepository implements UserProfileRepository {
  @override
  Future<void> clearAllData() async {}

  @override
  Future<CycleSettings?> getCycleSettings() async =>
      const CycleSettings(averageCycleLength: 28, averagePeriodDuration: 5);

  @override
  Future<ReminderSettings?> getReminderSettings() async => null;

  @override
  Future<UserProfile?> getUserProfile() async =>
      const UserProfile(name: 'Jane', age: 28, height: 165, weight: 60);

  @override
  Future<void> saveCycleSettings(CycleSettings settings) async {}

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {}

  @override
  Future<void> saveUserProfile(UserProfile profile) async {}
}

void main() {
  final checkUp = CheckUp(
    id: 'check-up-1',
    date: DateTime(2026, 4, 12),
    notes: 'Cycle notes',
    symptoms: const [
      Symptom(
        id: 'symptom-1',
        checkUpId: 'check-up-1',
        name: 'Fatigue',
        category: SymptomCategory.physical,
      ),
    ],
  );
  final analysisResult = AnalysisResult(
    id: 'analysis-1',
    checkUpId: 'check-up-1',
    date: DateTime(2026, 4, 12),
    resultText: jsonEncode({
      'is_valid_ultrasound': true,
      'attention': 'ATTENTION SUGGESTED',
      'headline': 'Patterns worth discussing',
      'summary': 'A cautious summary.',
      'signal_strength': 'Moderate',
      'signal_percent': 55,
      'observed_signals': <Object>[],
      'possible_explanations': <Object>[],
    }),
  );

  HistoryViewModel createViewModel() {
    return HistoryViewModel(
      _FakeCycleRepository([
        Cycle(
          id: 'cycle-1',
          startDate: DateTime(2026, 4, 1),
          flowIntensity: 'Medium',
        ),
      ]),
      _FakeCheckUpRepository([checkUp], [analysisResult]),
      _FakeReportRepository(),
      userProfileRepository: _FakeUserProfileRepository(),
    );
  }

  test('loads locally saved AI results and filters flagged entries', () async {
    final viewModel = createViewModel();

    await viewModel.loadHistory();

    expect(viewModel.checkUps, hasLength(1));
    expect(
      viewModel.analysisFor('check-up-1')?.headline,
      'Patterns worth discussing',
    );
    expect(viewModel.flaggedCount, 1);
    expect(viewModel.monthsTracked, 1);

    viewModel.setFilter(HistoryFilter.flagged);
    expect(viewModel.filteredCheckUps, contains(checkUp));
    viewModel.setFilter(HistoryFilter.normal);
    expect(viewModel.filteredCheckUps, isEmpty);
  });

  testWidgets('renders the local history entry and overview', (
    WidgetTester tester,
  ) async {
    final viewModel = createViewModel();
    await tester.pumpWidget(
      MaterialApp(home: HistoryScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('OVERVIEW'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('Apr 12'), findsOneWidget);
    expect(find.text('Fatigue'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('View report'), findsOneWidget);
  });
}
