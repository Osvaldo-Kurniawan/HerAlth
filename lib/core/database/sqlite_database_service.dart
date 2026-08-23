import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class SqliteDatabaseService implements DatabaseService {
  Database? _db;

  @override
  Future<Database> get database async {
    if (_db != null) return _db!;
    await initDatabase();
    return _db!;
  }

  @override
  Future<void> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DatabaseConstants.databaseName);

    _db = await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // User Profile
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableUserProfile} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        height REAL,
        weight REAL
      )
    ''');

    // Cycle Settings
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCycleSettings} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        averageCycleLength INTEGER,
        averagePeriodDuration INTEGER
      )
    ''');

    // Reminder Settings
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableReminderSettings} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        periodReminderEnabled INTEGER,
        fertilityReminderEnabled INTEGER,
        checkUpReminderEnabled INTEGER,
        cycleRemindersEnabled INTEGER
      )
    ''');

    // AI Settings
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableAiSettings} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        analysisModel TEXT,
        autoAnalyzeUltrasounds INTEGER
      )
    ''');

    // Cycles
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCycle} (
        id TEXT PRIMARY KEY,
        startDate TEXT,
        endDate TEXT,
        cycleLength INTEGER,
        flowIntensity TEXT
      )
    ''');

    // Cycle Entries
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCycleEntry} (
        id TEXT PRIMARY KEY,
        date TEXT,
        notes TEXT
      )
    ''');

    // Check Ups
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCheckUp} (
        id TEXT PRIMARY KEY,
        date TEXT,
        notes TEXT,
        ultrasoundPath TEXT
      )
    ''');

    // Symptoms
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSymptom} (
        id TEXT PRIMARY KEY,
        checkUpId TEXT,
        name TEXT,
        category TEXT,
        FOREIGN KEY (checkUpId) REFERENCES ${DatabaseConstants.tableCheckUp} (id) ON DELETE CASCADE
      )
    ''');

    // Analysis Results
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableAnalysisResult} (
        id TEXT PRIMARY KEY,
        checkUpId TEXT,
        resultText TEXT,
        date TEXT,
        FOREIGN KEY (checkUpId) REFERENCES ${DatabaseConstants.tableCheckUp} (id) ON DELETE CASCADE
      )
    ''');

    // Reports
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableReport} (
        id TEXT PRIMARY KEY,
        date TEXT,
        status TEXT,
        statisticsJson TEXT,
        timelineJson TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${DatabaseConstants.tableReminderSettings} ADD COLUMN cycleRemindersEnabled INTEGER DEFAULT 1',
      );
    }
  }

  @override
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
