import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/data/services/check_up_pdf_service.dart';
import 'package:heralth/domain/models/check_up.dart';
import 'package:heralth/domain/models/check_up_analysis.dart';

void main() {
  test('generates a valid PDF containing check-up report data', () async {
    final report = CheckUpReportData(
      generatedAt: DateTime(2026, 8, 25),
      checkUp: CheckUp(
        id: 'check-up-1',
        date: DateTime(2026, 8, 24),
        notes: 'Symptoms became stronger in the afternoon.',
        symptoms: const [
          Symptom(
            id: 'symptom-1',
            checkUpId: 'check-up-1',
            name: 'Fatigue',
            category: SymptomCategory.physical,
          ),
        ],
      ),
      cycleContext: CycleContextSnapshot(
        cycleDay: 12,
        phase: 'Follicular',
        averageCycleLength: 28,
        lastPeriod: DateTime(2026, 8, 13),
        regularity: 'Regular',
        cycleLengths: const [28, 29, 28],
      ),
      analysis: const CheckUpAnalysis(
        isValidUltrasound: true,
        attention: 'ATTENTION SUGGESTED',
        headline: 'Patterns worth discussing',
        summary: 'A cautious, informational summary.',
        signalStrength: 'Moderate',
        signalPercent: 55,
        observedSignals: [
          ObservedSignal(
            title: 'Fatigue pattern',
            detail: 'Fatigue was included in this check-up.',
            icon: 'insight',
          ),
        ],
        possibleExplanations: [
          PossibleExplanation(
            name: 'Cycle-related change',
            tag: 'DISCUSS',
            description: 'Discuss persistent changes with a clinician.',
          ),
        ],
        rawText: '',
      ),
    );

    final bytes = await CheckUpPdfService().generate(report);

    expect(utf8.decode(bytes.take(5).toList()), '%PDF-');
    expect(bytes.length, greaterThan(1000));
    expect(report.fileName, 'heralth-check-up-2026-08-24.pdf');
  });
}
