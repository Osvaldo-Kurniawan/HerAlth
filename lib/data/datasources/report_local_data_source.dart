import 'package:sqflite/sqflite.dart';

import '../../core/database/database_service.dart';
import '../../domain/models/report.dart';

abstract class ReportLocalDataSource {
  Future<List<Report>> getReports();
  Future<void> saveReport(Report report);
  Future<void> deleteReport(String id);
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final DatabaseService _databaseService;

  ReportLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<Report>> getReports() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      DatabaseConstants.tableReport,
      orderBy: 'date DESC',
    );
    return maps.map((e) => Report.fromJson(e)).toList();
  }

  @override
  Future<void> saveReport(Report report) async {
    final db = await _databaseService.database;
    await db.insert(
      DatabaseConstants.tableReport,
      report.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteReport(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      DatabaseConstants.tableReport,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
