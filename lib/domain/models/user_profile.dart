class UserProfile {
  final String name;
  final int age;
  final double height;
  final double weight;

  const UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    double? height,
    double? weight,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age, 'height': height, 'weight': weight};
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CycleSettings {
  final int averageCycleLength;
  final int averagePeriodDuration;

  const CycleSettings({
    required this.averageCycleLength,
    required this.averagePeriodDuration,
  });

  CycleSettings copyWith({
    int? averageCycleLength,
    int? averagePeriodDuration,
  }) {
    return CycleSettings(
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodDuration:
          averagePeriodDuration ?? this.averagePeriodDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageCycleLength': averageCycleLength,
      'averagePeriodDuration': averagePeriodDuration,
    };
  }

  factory CycleSettings.fromJson(Map<String, dynamic> json) {
    return CycleSettings(
      averageCycleLength: json['averageCycleLength'] as int? ?? 28,
      averagePeriodDuration: json['averagePeriodDuration'] as int? ?? 5,
    );
  }
}

class ReminderSettings {
  final bool periodReminderEnabled;
  final bool fertilityReminderEnabled;
  final bool checkUpReminderEnabled;
  final bool cycleRemindersEnabled;

  const ReminderSettings({
    required this.periodReminderEnabled,
    required this.fertilityReminderEnabled,
    required this.checkUpReminderEnabled,
    required this.cycleRemindersEnabled,
  });

  ReminderSettings copyWith({
    bool? periodReminderEnabled,
    bool? fertilityReminderEnabled,
    bool? checkUpReminderEnabled,
    bool? cycleRemindersEnabled,
  }) {
    return ReminderSettings(
      periodReminderEnabled:
          periodReminderEnabled ?? this.periodReminderEnabled,
      fertilityReminderEnabled:
          fertilityReminderEnabled ?? this.fertilityReminderEnabled,
      checkUpReminderEnabled:
          checkUpReminderEnabled ?? this.checkUpReminderEnabled,
      cycleRemindersEnabled:
          cycleRemindersEnabled ?? this.cycleRemindersEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodReminderEnabled': periodReminderEnabled ? 1 : 0,
      'fertilityReminderEnabled': fertilityReminderEnabled ? 1 : 0,
      'checkUpReminderEnabled': checkUpReminderEnabled ? 1 : 0,
      'cycleRemindersEnabled': cycleRemindersEnabled ? 1 : 0,
    };
  }

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      periodReminderEnabled:
          json['periodReminderEnabled'] == 1 ||
          json['periodReminderEnabled'] == true,
      fertilityReminderEnabled:
          json['fertilityReminderEnabled'] == 1 ||
          json['fertilityReminderEnabled'] == true,
      checkUpReminderEnabled:
          json['checkUpReminderEnabled'] == 1 ||
          json['checkUpReminderEnabled'] == true,
      cycleRemindersEnabled:
          json['cycleRemindersEnabled'] == 1 ||
          json['cycleRemindersEnabled'] == true ||
          json['cycleRemindersEnabled'] == null, // Fallback if old DB version had no column
    );
  }
}

class AiSettings {
  final String analysisModel;
  final bool autoAnalyzeUltrasounds;

  const AiSettings({
    required this.analysisModel,
    required this.autoAnalyzeUltrasounds,
  });

  AiSettings copyWith({String? analysisModel, bool? autoAnalyzeUltrasounds}) {
    return AiSettings(
      analysisModel: analysisModel ?? this.analysisModel,
      autoAnalyzeUltrasounds:
          autoAnalyzeUltrasounds ?? this.autoAnalyzeUltrasounds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysisModel': analysisModel,
      'autoAnalyzeUltrasounds': autoAnalyzeUltrasounds ? 1 : 0,
    };
  }

  factory AiSettings.fromJson(Map<String, dynamic> json) {
    return AiSettings(
      analysisModel: json['analysisModel'] as String? ?? 'General Health GPT',
      autoAnalyzeUltrasounds:
          json['autoAnalyzeUltrasounds'] == 1 ||
          json['autoAnalyzeUltrasounds'] == true,
    );
  }
}
