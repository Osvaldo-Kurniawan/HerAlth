import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/data/services/gemini_analysis_service.dart';
import 'package:heralth/domain/models/check_up.dart';
import 'package:heralth/domain/models/check_up_analysis.dart';
import 'package:heralth/domain/models/cycle.dart';
import 'package:heralth/domain/models/ultrasound_attachment.dart';
import 'package:heralth/domain/models/user_profile.dart';
import 'package:heralth/domain/repositories/check_up_repository.dart';
import 'package:heralth/domain/repositories/cycle_repository.dart';
import 'package:heralth/domain/repositories/user_profile_repository.dart';
import 'package:heralth/domain/services/check_up_analysis_service.dart';
import 'package:heralth/domain/services/analysis_notification_service.dart';
import 'package:heralth/ui/features/check_up/view_models/check_up_view_model.dart';

class _FakeCheckUpRepository implements CheckUpRepository {
  final Exception? saveAnalysisError;
  AnalysisResult? savedAnalysisResult;
  CheckUp? savedCheckUp;
  final List<String> deletedCheckUpIds = [];

  _FakeCheckUpRepository({this.saveAnalysisError});

  @override
  Future<void> deleteCheckUp(String id) async {
    deletedCheckUpIds.add(id);
    if (savedCheckUp?.id == id) savedCheckUp = null;
  }

  @override
  Future<List<AnalysisResult>> getAnalysisResults() async => <AnalysisResult>[];

  @override
  Future<List<CheckUp>> getCheckUps() async => <CheckUp>[];

  @override
  Future<void> saveAnalysisResult(AnalysisResult result) async {
    if (saveAnalysisError case final error?) throw error;
    savedAnalysisResult = result;
  }

  @override
  Future<void> saveCheckUp(CheckUp checkUp) async {
    savedCheckUp = checkUp;
  }
}

class _FakeCycleRepository implements CycleRepository {
  final List<Cycle> cycles;

  _FakeCycleRepository(this.cycles);

  @override
  Future<void> deleteCycle(String id) async {}

  @override
  Future<void> deleteCycleEntry(String id) async {}

  @override
  Future<List<CycleEntry>> getCycleEntries() async => const [];

  @override
  Future<List<Cycle>> getCycles() async => cycles;

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
  Future<UserProfile?> getUserProfile() async => null;

  @override
  Future<void> saveCycleSettings(CycleSettings settings) async {}

  @override
  Future<void> saveReminderSettings(ReminderSettings settings) async {}

  @override
  Future<void> saveUserProfile(UserProfile profile) async {}
}

class _FailingAnalysisService implements CheckUpAnalysisService {
  @override
  Future<CheckUpAnalysis> analyze({
    required List<String> symptoms,
    required String notes,
    required CycleContextSnapshot cycleContext,
    UltrasoundAttachment? ultrasound,
  }) {
    throw const GeminiAnalysisException(
      'The AI service is temporarily unavailable. Please try again shortly.',
      statusCode: 503,
      apiMessage: 'The model is overloaded.',
      apiStatus: 'UNAVAILABLE',
      model: 'gemini-primary',
    );
  }
}

class _SuccessfulAnalysisService implements CheckUpAnalysisService {
  CycleContextSnapshot? receivedCycleContext;

  @override
  Future<CheckUpAnalysis> analyze({
    required List<String> symptoms,
    required String notes,
    required CycleContextSnapshot cycleContext,
    UltrasoundAttachment? ultrasound,
  }) async {
    receivedCycleContext = cycleContext;
    return const CheckUpAnalysis(
      isValidUltrasound: true,
      attention: 'NORMAL',
      headline: 'Patterns worth reviewing',
      summary: 'Informational summary.',
      signalStrength: 'Low',
      signalPercent: 20,
      observedSignals: [],
      possibleExplanations: [],
      rawText: '',
    );
  }
}

class _BlockingAnalysisService implements CheckUpAnalysisService {
  final Completer<CheckUpAnalysis> completer = Completer<CheckUpAnalysis>();

  @override
  Future<CheckUpAnalysis> analyze({
    required List<String> symptoms,
    required String notes,
    required CycleContextSnapshot cycleContext,
    UltrasoundAttachment? ultrasound,
  }) => completer.future;
}

class _SuccessThenFailureAnalysisService implements CheckUpAnalysisService {
  int calls = 0;

  @override
  Future<CheckUpAnalysis> analyze({
    required List<String> symptoms,
    required String notes,
    required CycleContextSnapshot cycleContext,
    UltrasoundAttachment? ultrasound,
  }) async {
    calls++;
    if (calls > 1) {
      throw const GeminiAnalysisException(
        'The AI service is temporarily unavailable. Please try again shortly.',
        statusCode: 503,
      );
    }
    return const CheckUpAnalysis(
      isValidUltrasound: true,
      attention: 'NORMAL',
      headline: 'Patterns worth reviewing',
      summary: 'Informational summary.',
      signalStrength: 'Low',
      signalPercent: 20,
      observedSignals: [],
      possibleExplanations: [],
      rawText: '',
    );
  }
}

class _FakeNotificationService implements AnalysisNotificationService {
  final bool permissionGranted;
  final bool throwOnPermissionRequest;
  final bool throwOnCompleted;
  final bool throwOnFailed;

  int permissionRequests = 0;
  int completedNotifications = 0;
  int failedNotifications = 0;

  _FakeNotificationService({
    this.permissionGranted = true,
    this.throwOnPermissionRequest = false,
    this.throwOnCompleted = false,
    this.throwOnFailed = false,
  });

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    if (throwOnPermissionRequest) throw Exception('Permission plugin failed');
    return permissionGranted;
  }

  @override
  Future<void> showAnalysisCompleted() async {
    completedNotifications++;
    if (throwOnCompleted) throw Exception('Notification plugin failed');
  }

  @override
  Future<void> showAnalysisFailed() async {
    failedNotifications++;
    if (throwOnFailed) throw Exception('Notification plugin failed');
  }
}

void main() {
  test('stores user-safe and diagnostic Gemini errors separately', () async {
    final notifications = _FakeNotificationService();
    final viewModel = CheckUpViewModel(
      _FakeCheckUpRepository(),
      analysisService: _FailingAnalysisService(),
      notificationService: notifications,
    )..toggleSymptom('Fatigue');

    await expectLater(
      viewModel.analyzeCurrentCheckUp(),
      throwsA(isA<GeminiAnalysisException>()),
    );

    expect(
      viewModel.errorMessage,
      'The AI service is temporarily unavailable. Please try again shortly.',
    );
    expect(
      viewModel.diagnosticErrorMessage,
      allOf(
        contains('HTTP 503'),
        contains('model=gemini-primary'),
        contains('status=UNAVAILABLE'),
        contains('api_message=The model is overloaded.'),
      ),
    );

    viewModel.clearError();
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.diagnosticErrorMessage, isNull);
    expect(notifications.permissionRequests, 1);
    expect(notifications.completedNotifications, 0);
    expect(notifications.failedNotifications, 1);
  });

  test('sends and persists the cycle snapshot used by AI', () async {
    final now = DateTime.now();
    final cycleStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    final repository = _FakeCheckUpRepository();
    final analysisService = _SuccessfulAnalysisService();
    final notifications = _FakeNotificationService();
    final viewModel = CheckUpViewModel(
      repository,
      cycleRepository: _FakeCycleRepository([
        Cycle(id: 'cycle-1', startDate: cycleStart, flowIntensity: 'Medium'),
      ]),
      userProfileRepository: _FakeUserProfileRepository(),
      analysisService: analysisService,
      notificationService: notifications,
    )..toggleSymptom('Fatigue');

    await viewModel.analyzeCurrentCheckUp();

    expect(analysisService.receivedCycleContext?.cycleDay, 2);
    expect(viewModel.lastAnalyzedCheckUp, same(repository.savedCheckUp));
    final payload = jsonDecode(repository.savedAnalysisResult!.resultText);
    expect(payload['cycle_context']['cycle_day'], 2);
    expect(payload['cycle_context']['phase'], 'Menstruation');
    expect(notifications.completedNotifications, 1);
    expect(notifications.failedNotifications, 0);
  });

  test('does not request or show a notification before validation', () async {
    final notifications = _FakeNotificationService();
    final viewModel = CheckUpViewModel(
      _FakeCheckUpRepository(),
      analysisService: _SuccessfulAnalysisService(),
      notificationService: notifications,
    );

    await expectLater(
      viewModel.analyzeCurrentCheckUp(),
      throwsA(isA<CheckUpValidationException>()),
    );

    expect(notifications.permissionRequests, 0);
    expect(notifications.completedNotifications, 0);
    expect(notifications.failedNotifications, 0);
  });

  test('permission denial does not block a successful analysis', () async {
    final repository = _FakeCheckUpRepository();
    final notifications = _FakeNotificationService(permissionGranted: false);
    final viewModel = CheckUpViewModel(
      repository,
      analysisService: _SuccessfulAnalysisService(),
      notificationService: notifications,
    )..toggleSymptom('Fatigue');

    final result = await viewModel.analyzeCurrentCheckUp();

    expect(result.headline, 'Patterns worth reviewing');
    expect(repository.savedAnalysisResult, isNotNull);
    expect(notifications.permissionRequests, 1);
    expect(notifications.completedNotifications, 0);
    expect(notifications.failedNotifications, 0);
  });

  test('notification plugin failures never mask analysis success', () async {
    final repository = _FakeCheckUpRepository();
    final notifications = _FakeNotificationService(throwOnCompleted: true);
    final viewModel = CheckUpViewModel(
      repository,
      analysisService: _SuccessfulAnalysisService(),
      notificationService: notifications,
    )..toggleSymptom('Fatigue');

    await expectLater(viewModel.analyzeCurrentCheckUp(), completes);

    expect(repository.savedAnalysisResult, isNotNull);
    expect(viewModel.errorMessage, isNull);
    expect(notifications.completedNotifications, 1);
  });

  test(
    'permission plugin failures never start a terminal notification',
    () async {
      final repository = _FakeCheckUpRepository();
      final notifications = _FakeNotificationService(
        throwOnPermissionRequest: true,
      );
      final viewModel = CheckUpViewModel(
        repository,
        analysisService: _SuccessfulAnalysisService(),
        notificationService: notifications,
      )..toggleSymptom('Fatigue');

      await expectLater(viewModel.analyzeCurrentCheckUp(), completes);

      expect(repository.savedAnalysisResult, isNotNull);
      expect(notifications.completedNotifications, 0);
      expect(notifications.failedNotifications, 0);
    },
  );

  test(
    'save failure notifies failure and rolls back partial history',
    () async {
      final repository = _FakeCheckUpRepository(
        saveAnalysisError: Exception('Database is full'),
      );
      final notifications = _FakeNotificationService(throwOnFailed: true);
      final viewModel = CheckUpViewModel(
        repository,
        analysisService: _SuccessfulAnalysisService(),
        notificationService: notifications,
      )..toggleSymptom('Fatigue');

      await expectLater(
        viewModel.analyzeCurrentCheckUp(),
        throwsA(isA<Exception>()),
      );

      expect(repository.savedCheckUp, isNull);
      expect(repository.deletedCheckUpIds, hasLength(1));
      expect(viewModel.analysis, isNull);
      expect(viewModel.lastAnalyzedCheckUp, isNull);
      expect(
        viewModel.errorMessage,
        'Something went wrong while saving or analyzing. Please try again.',
      );
      expect(viewModel.diagnosticErrorMessage, contains('Database is full'));
      expect(notifications.completedNotifications, 0);
      expect(notifications.failedNotifications, 1);
    },
  );

  test('rejects concurrent analysis without duplicate notifications', () async {
    final analysisService = _BlockingAnalysisService();
    final notifications = _FakeNotificationService();
    final viewModel = CheckUpViewModel(
      _FakeCheckUpRepository(),
      analysisService: analysisService,
      notificationService: notifications,
    )..toggleSymptom('Fatigue');

    final firstAnalysis = viewModel.analyzeCurrentCheckUp();
    await Future<void>.delayed(Duration.zero);

    await expectLater(
      viewModel.analyzeCurrentCheckUp(),
      throwsA(isA<CheckUpValidationException>()),
    );
    analysisService.completer.complete(
      const CheckUpAnalysis(
        isValidUltrasound: true,
        attention: 'NORMAL',
        headline: 'Patterns worth reviewing',
        summary: 'Informational summary.',
        signalStrength: 'Low',
        signalPercent: 20,
        observedSignals: [],
        possibleExplanations: [],
        rawText: '',
      ),
    );
    await firstAnalysis;

    expect(notifications.permissionRequests, 1);
    expect(notifications.completedNotifications, 1);
    expect(notifications.failedNotifications, 0);
  });

  test('failed repeat attempt does not expose a stale prior result', () async {
    final analysisService = _SuccessThenFailureAnalysisService();
    final notifications = _FakeNotificationService();
    final viewModel = CheckUpViewModel(
      _FakeCheckUpRepository(),
      analysisService: analysisService,
      notificationService: notifications,
    )..toggleSymptom('Fatigue');

    await viewModel.analyzeCurrentCheckUp();
    expect(viewModel.analysis, isNotNull);
    expect(viewModel.lastAnalyzedCheckUp, isNotNull);

    await expectLater(
      viewModel.analyzeCurrentCheckUp(),
      throwsA(isA<GeminiAnalysisException>()),
    );

    expect(viewModel.analysis, isNull);
    expect(viewModel.lastAnalyzedCheckUp, isNull);
    expect(notifications.completedNotifications, 1);
    expect(notifications.failedNotifications, 1);
  });
}
