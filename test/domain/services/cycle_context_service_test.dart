import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/domain/models/cycle.dart';
import 'package:heralth/domain/models/user_profile.dart';
import 'package:heralth/domain/services/cycle_context_service.dart';

void main() {
  const settings = CycleSettings(
    averageCycleLength: 28,
    averagePeriodDuration: 5,
  );
  final service = CycleContextService();

  test('uses one-based cycle days and configured period duration', () {
    final cycle = Cycle(
      id: 'cycle-1',
      startDate: DateTime(2026, 8, 10, 18),
      flowIntensity: 'Medium',
    );

    final firstDay = service.build(
      cycles: [cycle],
      settings: settings,
      at: DateTime(2026, 8, 10, 8),
    );
    final secondDay = service.build(
      cycles: [cycle],
      settings: settings,
      at: DateTime(2026, 8, 11, 8),
    );

    expect(firstDay.cycleDay, 1);
    expect(secondDay.cycleDay, 2);
    expect(secondDay.phase, 'Menstruation');
  });

  test('selects the latest cycle that existed at the check-up date', () {
    final context = service.build(
      cycles: [
        Cycle(
          id: 'future-cycle',
          startDate: DateTime(2026, 5, 1),
          flowIntensity: 'Medium',
        ),
        Cycle(
          id: 'matched-cycle',
          startDate: DateTime(2026, 4, 1),
          flowIntensity: 'Medium',
        ),
      ],
      settings: settings,
      at: DateTime(2026, 4, 12),
    );

    expect(context.cycleDay, 12);
    expect(context.phase, 'Follicular');
    expect(context.lastPeriod, DateTime(2026, 4, 1));
  });

  test('does not invent cycle data when no period is recorded', () {
    final context = service.build(
      cycles: const [],
      settings: settings,
      at: DateTime(2026, 8, 25),
    );

    expect(context.cycleDay, 0);
    expect(context.phase, 'Unknown');
    expect(context.lastPeriod, isNull);
    expect(context.cycleLengths, isEmpty);
  });
}
