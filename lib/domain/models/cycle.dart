enum CyclePhase { menstruation, follicular, ovulatory, luteal }

enum CycleRegularity { regular, irregular, insufficientData }

class Cycle {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final String flowIntensity; // e.g. Light, Medium, Heavy

  const Cycle({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    required this.flowIntensity,
  });

  Cycle copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    String? flowIntensity,
  }) {
    return Cycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      flowIntensity: flowIntensity ?? this.flowIntensity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'flowIntensity': flowIntensity,
    };
  }

  factory Cycle.fromJson(Map<String, dynamic> json) {
    return Cycle(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      cycleLength: json['cycleLength'] as int?,
      flowIntensity: json['flowIntensity'] as String? ?? 'Medium',
    );
  }
}

class CycleEntry {
  final String id;
  final DateTime date;
  final String notes;

  const CycleEntry({required this.id, required this.date, required this.notes});

  CycleEntry copyWith({String? id, DateTime? date, String? notes}) {
    return CycleEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'date': date.toIso8601String(), 'notes': notes};
  }

  factory CycleEntry.fromJson(Map<String, dynamic> json) {
    return CycleEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String? ?? '',
    );
  }
}

class CyclePrediction {
  final DateTime predictedStartDate;
  final DateTime predictedOvulationDate;
  final CyclePhase predictedPhase;

  const CyclePrediction({
    required this.predictedStartDate,
    required this.predictedOvulationDate,
    required this.predictedPhase,
  });
}

class CycleInsight {
  final String title;
  final String description;
  final String recommendation;

  const CycleInsight({
    required this.title,
    required this.description,
    required this.recommendation,
  });
}
