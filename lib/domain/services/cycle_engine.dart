import '../models/cycle.dart';
import '../models/user_profile.dart';

class CycleEngine {
  // Calculates the current phase based on the day of cycle and settings
  CyclePhase getPhaseForDay(int day, CycleSettings settings) {
    final periodDuration = settings.averagePeriodDuration;
    final cycleLength = settings.averageCycleLength;
    final ovulationDay = cycleLength - 14;

    if (day <= periodDuration) {
      return CyclePhase.menstruation;
    } else if (day < ovulationDay - 1) {
      return CyclePhase.follicular;
    } else if (day <= ovulationDay + 1) {
      return CyclePhase.ovulatory;
    } else {
      return CyclePhase.luteal;
    }
  }

  // Cycle Engine computes prediction details based on cycle history and settings
  CyclePrediction predictNextCycle({
    required List<Cycle> cycleHistory,
    required CycleSettings settings,
  }) {
    if (cycleHistory.isEmpty) {
      final today = DateTime.now();
      return CyclePrediction(
        predictedStartDate: today.add(
          Duration(days: settings.averageCycleLength),
        ),
        predictedOvulationDate: today.add(
          Duration(days: settings.averageCycleLength - 14),
        ),
        predictedPhase: CyclePhase.menstruation,
      );
    }

    // Use the most recent cycle start date as baseline
    final lastCycle = cycleHistory.first;
    final predictedStart = lastCycle.startDate.add(
      Duration(days: settings.averageCycleLength),
    );
    final predictedOvulation = lastCycle.startDate.add(
      Duration(days: settings.averageCycleLength - 14),
    );

    final today = DateTime.now();
    final currentDay = today.difference(lastCycle.startDate).inDays + 1;
    final currentPhase = getPhaseForDay(currentDay, settings);

    return CyclePrediction(
      predictedStartDate: predictedStart,
      predictedOvulationDate: predictedOvulation,
      predictedPhase: currentPhase,
    );
  }

  CycleRegularity calculateRegularity(List<Cycle> cycleHistory) {
    if (cycleHistory.length < 3) {
      return CycleRegularity.insufficientData;
    }
    return CycleRegularity.regular;
  }

  List<CycleInsight> generateInsights({
    required List<Cycle> cycleHistory,
    required CycleSettings settings,
  }) {
    if (cycleHistory.isEmpty) {
      return const [
        CycleInsight(
          title: 'Welcome to HerAlth',
          description:
              'Log your first period to receive personalized cycle insights.',
          recommendation: 'Tap the "Today is the day" button below when your period starts.',
        ),
      ];
    }

    final lastCycle = cycleHistory.first;
    final today = DateTime.now();
    final currentDay = today.difference(lastCycle.startDate).inDays + 1;
    final phase = getPhaseForDay(currentDay, settings);

    String title;
    String description;
    String recommendation;

    switch (phase) {
      case CyclePhase.menstruation:
        title = 'Menstrual Phase';
        description = 'Your body is shedding the uterine lining. Energy levels are typically lower.';
        recommendation =
            'Prioritize rest, stay hydrated, and practice gentle stretching.';
        break;
      case CyclePhase.follicular:
        title = 'Follicular Phase';
        description = 'Estrogen levels are rising, boosting your mood, focus, and physical energy.';
        recommendation = 'Great time to start new projects, schedule meetings, and increase workout intensity.';
        break;
      case CyclePhase.ovulatory:
        title = 'Ovulatory Phase';
        description = 'Your estrogen levels are peaking today, which often brings a boost in mental clarity and social energy.';
        recommendation = 'Perfect window for social connections, creative tasks, and high-impact workouts.';
        break;
      case CyclePhase.luteal:
        title = 'Luteal Phase';
        description = 'Progesterone is rising, preparing your body for rest. You might experience the onset of PMS.';
        recommendation = 'Focus on restorative sleep, nourishing meals, and calming activities like yoga.';
        break;
    }

    return [
      CycleInsight(
        title: title,
        description: description,
        recommendation: recommendation,
      ),
    ];
  }
}
