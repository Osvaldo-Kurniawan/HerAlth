enum ReportStatus { pending, ready, failed }

class Report {
  final String id;
  final DateTime date;
  final ReportStatus status;
  final Map<String, dynamic> statistics;
  final List<String> timelineEvents;

  const Report({
    required this.id,
    required this.date,
    required this.status,
    required this.statistics,
    required this.timelineEvents,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status.name,
      'statisticsJson': _statisticsToJson(),
      'timelineJson': _timelineToJson(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      statistics: _statisticsFromJson(json['statisticsJson'] as String?),
      timelineEvents: _timelineFromJson(json['timelineJson'] as String?),
    );
  }

  String _statisticsToJson() {
    // Basic JSON string builder or mapping can be completed in JSON encode.
    // For skeleton, we represent placeholder logic.
    return '';
  }

  String _timelineToJson() {
    return '';
  }

  static Map<String, dynamic> _statisticsFromJson(String? jsonString) {
    return {};
  }

  static List<String> _timelineFromJson(String? jsonString) {
    return [];
  }
}

class ReportStatistics {
  final int totalCyclesLogged;
  final double averageCycleLength;
  final int totalSymptomsLogged;

  const ReportStatistics({
    required this.totalCyclesLogged,
    required this.averageCycleLength,
    required this.totalSymptomsLogged,
  });
}

class ReportTimeline {
  final List<DateTime> eventDates;
  final List<String> eventDescriptions;

  const ReportTimeline({
    required this.eventDates,
    required this.eventDescriptions,
  });
}
