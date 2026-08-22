import 'package:sqflite/sqflite.dart';

abstract class DatabaseService {
  Future<Database> get database;
  Future<void> initDatabase();
  Future<void> close();
}

class DatabaseConstants {
  static const String databaseName = 'heralth.db';
  static const int databaseVersion = 1;

  // Tables
  static const String tableUserProfile = 'user_profile';
  static const String tableCycleSettings = 'cycle_settings';
  static const String tableReminderSettings = 'reminder_settings';
  static const String tableAiSettings = 'ai_settings';
  static const String tableCycle = 'cycles';
  static const String tableCycleEntry = 'cycle_entries';
  static const String tableCheckUp = 'check_ups';
  static const String tableSymptom = 'symptoms';
  static const String tableAnalysisResult = 'analysis_results';
  static const String tableReport = 'reports';
}
