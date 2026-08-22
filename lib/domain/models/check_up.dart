import 'user_profile.dart';

enum SymptomCategory { physical, emotional }

class Symptom {
  final String id;
  final String checkUpId;
  final String name;
  final SymptomCategory category;

  const Symptom({
    required this.id,
    required this.checkUpId,
    required this.name,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkUpId': checkUpId,
      'name': name,
      'category': category.name,
    };
  }

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'] as String,
      checkUpId: json['checkUpId'] as String? ?? '',
      name: json['name'] as String,
      category: SymptomCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SymptomCategory.physical,
      ),
    );
  }
}

class UltrasoundFile {
  final String path;
  final String fileType; // JPG, PNG, PDF
  final int sizeBytes;

  const UltrasoundFile({
    required this.path,
    required this.fileType,
    required this.sizeBytes,
  });
}

class CheckUp {
  final String id;
  final DateTime date;
  final String notes;
  final String? ultrasoundPath;
  final List<Symptom> symptoms;

  const CheckUp({
    required this.id,
    required this.date,
    required this.notes,
    this.ultrasoundPath,
    required this.symptoms,
  });

  CheckUp copyWith({
    String? id,
    DateTime? date,
    String? notes,
    String? ultrasoundPath,
    List<Symptom>? symptoms,
  }) {
    return CheckUp(
      id: id ?? this.id,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      ultrasoundPath: ultrasoundPath ?? this.ultrasoundPath,
      symptoms: symptoms ?? this.symptoms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'notes': notes,
      'ultrasoundPath': ultrasoundPath,
    };
  }

  factory CheckUp.fromJson(
    Map<String, dynamic> json, {
    List<Symptom> symptoms = const [],
  }) {
    return CheckUp(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String? ?? '',
      ultrasoundPath: json['ultrasoundPath'] as String?,
      symptoms: symptoms,
    );
  }
}

class AnalysisRequest {
  final CheckUp checkUp;
  final String requestPrompt;

  const AnalysisRequest({required this.checkUp, required this.requestPrompt});
}

class AnalysisResult {
  final String id;
  final String checkUpId;
  final String resultText;
  final DateTime date;

  const AnalysisResult({
    required this.id,
    required this.checkUpId,
    required this.resultText,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkUpId': checkUpId,
      'resultText': resultText,
      'date': date.toIso8601String(),
    };
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String,
      checkUpId: json['checkUpId'] as String,
      resultText: json['resultText'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class AnalysisContext {
  final List<CheckUp> historicCheckUps;
  final UserProfile profile;

  const AnalysisContext({
    required this.historicCheckUps,
    required this.profile,
  });
}

class AnalysisChartData {
  final Map<String, int> symptomFrequencies;
  final List<DateTime> entryTimeline;

  const AnalysisChartData({
    required this.symptomFrequencies,
    required this.entryTimeline,
  });
}
