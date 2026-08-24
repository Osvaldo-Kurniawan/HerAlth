class CycleContextSnapshot {
  final int cycleDay;
  final String phase;
  final int averageCycleLength;
  final DateTime? lastPeriod;
  final String regularity;
  final List<int> cycleLengths;

  const CycleContextSnapshot({
    required this.cycleDay,
    required this.phase,
    required this.averageCycleLength,
    required this.lastPeriod,
    required this.regularity,
    required this.cycleLengths,
  });

  const CycleContextSnapshot.defaults()
    : cycleDay = 13,
      phase = 'Ovulation',
      averageCycleLength = 28,
      lastPeriod = null,
      regularity = 'Slightly irregular',
      cycleLengths = const [27, 29, 28, 31, 26, 30];

  Map<String, dynamic> toJson() {
    return {
      'cycle_day': cycleDay,
      'phase': phase,
      'average_cycle_length': averageCycleLength,
      'last_period': lastPeriod?.toIso8601String(),
      'regularity': regularity,
      'cycle_lengths': cycleLengths,
    };
  }
}

class ObservedSignal {
  final String title;
  final String detail;
  final String icon;

  const ObservedSignal({
    required this.title,
    required this.detail,
    required this.icon,
  });

  factory ObservedSignal.fromJson(Map<String, dynamic> json) {
    return ObservedSignal(
      title: _stringValue(json['title'], fallback: 'Logged symptom'),
      detail: _stringValue(
        json['detail'],
        fallback: 'Reported in this check-up.',
      ),
      icon: _stringValue(json['icon'], fallback: 'insight'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'detail': detail, 'icon': icon};
  }
}

class PossibleExplanation {
  final String name;
  final String tag;
  final String description;

  const PossibleExplanation({
    required this.name,
    required this.tag,
    required this.description,
  });

  factory PossibleExplanation.fromJson(Map<String, dynamic> json) {
    return PossibleExplanation(
      name: _stringValue(json['name'], fallback: 'Possible explanation'),
      tag: _stringValue(json['tag'], fallback: 'DISCUSS'),
      description: _stringValue(
        json['description'],
        fallback: 'Discuss this pattern with a healthcare professional.',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'tag': tag, 'description': description};
  }
}

class CheckUpAnalysis {
  final bool isValidUltrasound;
  final String attention;
  final String headline;
  final String summary;
  final String signalStrength;
  final int signalPercent;
  final List<ObservedSignal> observedSignals;
  final List<PossibleExplanation> possibleExplanations;
  final String rawText;

  const CheckUpAnalysis({
    required this.isValidUltrasound,
    required this.attention,
    required this.headline,
    required this.summary,
    required this.signalStrength,
    required this.signalPercent,
    required this.observedSignals,
    required this.possibleExplanations,
    required this.rawText,
  });

  factory CheckUpAnalysis.fromJson(
    Map<String, dynamic> json, {
    String rawText = '',
  }) {
    final observed = json['observed_signals'];
    final explanations = json['possible_explanations'];
    return CheckUpAnalysis(
      isValidUltrasound: json['is_valid_ultrasound'] != false,
      attention: _stringValue(
        json['attention'],
        fallback: 'ATTENTION SUGGESTED',
      ),
      headline: _stringValue(
        json['headline'],
        fallback: 'Patterns worth discussing',
      ),
      summary: _stringValue(
        json['summary'],
        fallback: 'Your entries show patterns that may be useful to review with your doctor.',
      ),
      signalStrength: _stringValue(
        json['signal_strength'],
        fallback: 'Moderate',
      ),
      signalPercent: _clampPercent(json['signal_percent']),
      observedSignals: observed is List
          ? observed
                .whereType<Map>()
                .map(
                  (item) =>
                      ObservedSignal.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
      possibleExplanations: explanations is List
          ? explanations
                .whereType<Map>()
                .map(
                  (item) => PossibleExplanation.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      rawText: rawText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid_ultrasound': isValidUltrasound,
      'attention': attention,
      'headline': headline,
      'summary': summary,
      'signal_strength': signalStrength,
      'signal_percent': signalPercent,
      'observed_signals': observedSignals.map((item) => item.toJson()).toList(),
      'possible_explanations': possibleExplanations
          .map((item) => item.toJson())
          .toList(),
      'raw_text': rawText,
    };
  }
}

String _stringValue(Object? value, {required String fallback}) {
  final string = value?.toString().trim() ?? '';
  return string.isEmpty ? fallback : string;
}

int _clampPercent(Object? value) {
  final parsed = value is num ? value.round() : int.tryParse('$value') ?? 55;
  return parsed.clamp(0, 100).toInt();
}
