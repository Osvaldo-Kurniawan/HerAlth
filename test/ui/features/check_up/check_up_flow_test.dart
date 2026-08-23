import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/domain/models/check_up.dart';
import 'package:heralth/domain/repositories/check_up_repository.dart';
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
}
