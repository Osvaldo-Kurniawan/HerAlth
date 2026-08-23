import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/data/services/gemini_analysis_service.dart';
import 'package:heralth/domain/models/check_up.dart';
import 'package:heralth/domain/models/check_up_analysis.dart';
import 'package:heralth/domain/models/ultrasound_attachment.dart';
import 'package:heralth/domain/repositories/check_up_repository.dart';
import 'package:heralth/domain/services/check_up_analysis_service.dart';
import 'package:heralth/ui/features/check_up/view_models/check_up_view_model.dart';

class _FakeCheckUpRepository implements CheckUpRepository {
  @override
  Future<void> deleteCheckUp(String id) async {}

  @override
  Future<List<AnalysisResult>> getAnalysisResults() async => <AnalysisResult>[];

  @override
  Future<List<CheckUp>> getCheckUps() async => <CheckUp>[];

  @override
  Future<void> saveAnalysisResult(AnalysisResult result) async {}

  @override
  Future<void> saveCheckUp(CheckUp checkUp) async {}
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

void main() {
  test('stores user-safe and diagnostic Gemini errors separately', () async {
    final viewModel = CheckUpViewModel(
      _FakeCheckUpRepository(),
      analysisService: _FailingAnalysisService(),
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
  });
}
