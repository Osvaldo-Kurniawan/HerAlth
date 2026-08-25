import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/data/services/check_up_pdf_service.dart';
import 'package:heralth/data/services/gemini_analysis_service.dart';
import 'package:heralth/domain/models/check_up.dart';
import 'package:heralth/domain/models/check_up_analysis.dart';
import 'package:heralth/domain/models/ultrasound_attachment.dart';
import 'package:heralth/domain/repositories/check_up_repository.dart';
import 'package:heralth/domain/services/analysis_notification_service.dart';
import 'package:heralth/domain/services/check_up_analysis_service.dart';
import 'package:heralth/ui/features/check_up/view_models/check_up_view_model.dart';
import 'package:heralth/ui/features/check_up/views/check_up_flow_screen.dart';

class _FakeCheckUpRepository implements CheckUpRepository {
  @override
  Future<List<CheckUp>> getCheckUps() async => [];

  @override
  Future<void> saveCheckUp(CheckUp checkUp) async {}

  @override
  Future<void> deleteCheckUp(String id) async {}

  @override
  Future<List<AnalysisResult>> getAnalysisResults() async => [];

  @override
  Future<void> saveAnalysisResult(AnalysisResult result) async {}
}

class _FakeReportExporter implements CheckUpReportExporter {
  CheckUpReportData? sharedReport;
  CheckUpReportData? downloadedReport;

  @override
  Future<String?> download(CheckUpReportData report) async {
    downloadedReport = report;
    return '/downloads/${report.fileName}';
  }

  @override
  Future<void> share(CheckUpReportData report) async {
    sharedReport = report;
  }
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
    );
  }
}

class _FakeNotificationService implements AnalysisNotificationService {
  int failedNotifications = 0;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> showAnalysisCompleted() async {}

  @override
  Future<void> showAnalysisFailed() async {
    failedNotifications++;
  }
}

void main() {
  testWidgets('symptom selection advances only after a symptom is selected', (
    WidgetTester tester,
  ) async {
    final viewModel = CheckUpViewModel(_FakeCheckUpRepository());
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: SymptomSelectionScreen(viewModel: viewModel)),
    );

    expect(find.text('What are you noticing?'), findsOneWidget);
    expect(viewModel.selectedSymptoms, isEmpty);

    await tester.tap(find.text('Fatigue'));
    await tester.pump();
    expect(viewModel.selectedSymptoms, contains('Fatigue'));

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Have an ultrasound?'), findsOneWidget);
  });

  testWidgets('check-up uses the shared HerAlth visual language', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: HerAlthColors.background,
          body: HerAlthPrimaryButton(label: 'Continue', onPressed: () {}),
        ),
      ),
    );

    final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final ElevatedButton button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );

    expect(scaffold.backgroundColor, const Color(0xFFFCF5F5));
    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{}),
      const Color(0xFF9E385A),
    );
    expect(HerAlthTextStyles.brand.fontFamily, 'serif');
    expect(HerAlthTextStyles.brand.color, const Color(0xFF9E385A));
  });

  testWidgets('result actions share and download the generated PDF', (
    WidgetTester tester,
  ) async {
    final exporter = _FakeReportExporter();
    const analysis = CheckUpAnalysis(
      isValidUltrasound: true,
      attention: 'ATTENTION SUGGESTED',
      headline: 'Patterns worth discussing',
      summary: 'A cautious summary.',
      signalStrength: 'Moderate',
      signalPercent: 55,
      observedSignals: [],
      possibleExplanations: [],
      rawText: '',
    );
    const cycle = CycleContextSnapshot(
      cycleDay: 12,
      phase: 'Follicular',
      averageCycleLength: 28,
      lastPeriod: null,
      regularity: 'Regular',
      cycleLengths: [28, 29],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AnalysisResultsScreen(
          analysis: analysis,
          cycleContext: cycle,
          closeToRoot: false,
          reportExporter: exporter,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Share'));
    await tester.pumpAndSettle();
    expect(exporter.sharedReport?.cycleContext.cycleDay, 12);
    expect(exporter.sharedReport?.analysis.headline, analysis.headline);

    await tester.tap(find.byTooltip('Download'));
    await tester.pumpAndSettle();
    expect(exporter.downloadedReport?.cycleContext.phase, 'Follicular');
    expect(find.textContaining('PDF saved to'), findsOneWidget);
  });

  testWidgets('processing failure shows retry and sends one notification', (
    WidgetTester tester,
  ) async {
    final notifications = _FakeNotificationService();
    final viewModel = CheckUpViewModel(
      _FakeCheckUpRepository(),
      analysisService: _FailingAnalysisService(),
      notificationService: notifications,
    )..toggleSymptom('Fatigue');

    await tester.pumpWidget(
      MaterialApp(home: AnalysisProcessingScreen(viewModel: viewModel)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text(
        'The AI service is temporarily unavailable. Please try again shortly.',
      ),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    expect(notifications.failedNotifications, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
