import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/domain/models/check_up.dart';
import 'package:heralth/domain/models/cycle.dart';
import 'package:heralth/domain/models/user_profile.dart';
import 'package:heralth/domain/repositories/backup_repository.dart';
import 'package:heralth/domain/repositories/check_up_repository.dart';
import 'package:heralth/domain/repositories/cycle_repository.dart';
import 'package:heralth/domain/repositories/user_profile_repository.dart';
import 'package:heralth/ui/features/profile/view_models/profile_view_model.dart';
import 'package:heralth/ui/features/profile/views/profile_screen.dart';

class _FakeBackupRepository implements BackupRepository {
  String? lastRestoredPath;
  Object? restoreError;

  @override
  Future<void> createBackup(String targetFilePath) async {}

  @override
  Future<void> restoreBackup(String sourceFilePath) async {
    if (restoreError != null) throw restoreError!;
    lastRestoredPath = sourceFilePath;
  }
}

class _FakeCheckUpRepository implements CheckUpRepository {
  @override
  Future<void> deleteCheckUp(String id) async {}

  @override
  Future<List<AnalysisResult>> getAnalysisResults() async => <AnalysisResult>[];

  @override
  Future<List<CheckUp>> getCheckUps() async => [
    CheckUp(
      id: 'check-up-1',
      date: DateTime(2026, 4, 12),
      notes: '',
      symptoms: const [],
    ),
  ];

  @override
  Future<void> saveAnalysisResult(AnalysisResult result) async {}

  @override
  Future<void> saveCheckUp(CheckUp checkUp) async {}
}

class _FakeCycleRepository implements CycleRepository {
  @override
  Future<void> deleteCycle(String id) async {}

  @override
  Future<void> deleteCycleEntry(String id) async {}

  @override
  Future<List<CycleEntry>> getCycleEntries() async => <CycleEntry>[];

  @override
  Future<List<Cycle>> getCycles() async => <Cycle>[];

  @override
  Future<void> saveCycle(Cycle cycle) async {}

  @override
  Future<void> saveCycleEntry(CycleEntry entry) async {}
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
      const UserProfile(name: 'Jane Doe', age: 28, height: 165, weight: 60);

  @override
  Future<void> saveCycleSettings(CycleSettings settings) async {}

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {}

  @override
  Future<void> saveUserProfile(UserProfile profile) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getTemporaryDirectory') {
            return Directory.systemTemp.path;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  testWidgets('shows locally stored profile and check-up activity', (
    WidgetTester tester,
  ) async {
    var storageLoadCount = 0;
    final viewModel = ProfileViewModel(
      _FakeUserProfileRepository(),
      _FakeBackupRepository(),
      _FakeCycleRepository(),
      checkUpRepository: _FakeCheckUpRepository(),
      storageSizeLoader: () async {
        storageLoadCount++;
        return 4.2;
      },
    );
    await viewModel.loadProfileData();

    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(viewModel: viewModel)),
    );
    await tester.pump();

    expect(storageLoadCount, 1);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('CHECK-UP ACTIVITY'), findsOneWidget);
    expect(find.text('CHECK-UPS SAVED'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    await tester.scrollUntilVisible(find.text('LOCAL DATA'), 500);
    expect(find.text('LOCAL DATA'), findsOneWidget);
  });

  test('restoreBackup writes pasted JSON to a temp file, restores via the repository, and reloads profile data', () async {
    final backupRepository = _FakeBackupRepository();
    final viewModel = ProfileViewModel(
      _FakeUserProfileRepository(),
      backupRepository,
      _FakeCycleRepository(),
    );

    final success = await viewModel.restoreBackup('{"exportedAt": "now"}');

    expect(success, isTrue);
    expect(viewModel.errorMessage, isNull);
    expect(backupRepository.lastRestoredPath, isNotNull);
    expect(viewModel.hasLoaded, isTrue);
  });

  test(
    'restoreBackup surfaces an error message and returns false on failure',
    () async {
      final backupRepository = _FakeBackupRepository()
        ..restoreError = const FormatException('bad json');
      final viewModel = ProfileViewModel(
        _FakeUserProfileRepository(),
        backupRepository,
        _FakeCycleRepository(),
      );

      final success = await viewModel.restoreBackup('not json');

      expect(success, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    },
  );
}
