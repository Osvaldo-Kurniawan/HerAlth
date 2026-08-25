import '../models/check_up_analysis.dart';
import '../models/cycle.dart';
import '../models/user_profile.dart';
import 'cycle_engine.dart';

class CycleContextService {
  final CycleEngine _cycleEngine;

  CycleContextService({CycleEngine? cycleEngine})
    : _cycleEngine = cycleEngine ?? CycleEngine();

  CycleContextSnapshot build({
    required List<Cycle> cycles,
    required CycleSettings settings,
    required DateTime at,
  }) {
    final date = _dateOnly(at);
    final sorted =
        cycles
            .where((cycle) => !_dateOnly(cycle.startDate).isAfter(date))
            .toList()
          ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final lengths = _cycleLengths(sorted);
    final latest = sorted.isEmpty ? null : sorted.first;

    if (latest == null) {
      return CycleContextSnapshot(
        cycleDay: 0,
        phase: 'Unknown',
        averageCycleLength: settings.averageCycleLength,
        lastPeriod: null,
        regularity: _regularity(lengths),
        cycleLengths: lengths,
      );
    }

    final cycleDay = date.difference(_dateOnly(latest.startDate)).inDays + 1;
    final safeCycleDay = cycleDay.clamp(1, 90);
    final phase = _cycleEngine.getPhaseForDay(safeCycleDay, settings);
    return CycleContextSnapshot(
      cycleDay: safeCycleDay,
      phase: _phaseLabel(phase),
      averageCycleLength: settings.averageCycleLength,
      lastPeriod: latest.startDate,
      regularity: _regularity(lengths),
      cycleLengths: lengths,
    );
  }

  List<int> _cycleLengths(List<Cycle> cycles) {
    final lengths = <int>[];
    for (final cycle in cycles) {
      final length = cycle.cycleLength;
      if (length != null && length >= 15 && length <= 90) {
        lengths.add(length);
      }
    }
    for (var index = 0; index + 1 < cycles.length; index++) {
      final difference = _dateOnly(cycles[index].startDate)
          .difference(_dateOnly(cycles[index + 1].startDate))
          .inDays;
      if (difference >= 15 &&
          difference <= 90 &&
          !lengths.contains(difference)) {
        lengths.add(difference);
      }
    }
    return lengths.take(6).toList();
  }

  String _regularity(List<int> lengths) {
    if (lengths.length < 2) return 'Not enough data';
    final minimum = lengths.reduce((a, b) => a < b ? a : b);
    final maximum = lengths.reduce((a, b) => a > b ? a : b);
    return maximum - minimum <= 3 ? 'Regular' : 'Slightly irregular';
  }

  String _phaseLabel(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstruation => 'Menstruation',
      CyclePhase.follicular => 'Follicular',
      CyclePhase.ovulatory => 'Ovulation',
      CyclePhase.luteal => 'Luteal',
    };
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
