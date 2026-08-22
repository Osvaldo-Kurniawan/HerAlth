import 'package:sqflite/sqflite.dart';

import '../../core/database/database_service.dart';
import '../../domain/models/check_up.dart';

abstract class CheckUpLocalDataSource {
  Future<List<CheckUp>> getCheckUps();
  Future<void> saveCheckUp(CheckUp checkUp);
  Future<void> deleteCheckUp(String id);

  Future<List<AnalysisResult>> getAnalysisResults();
  Future<void> saveAnalysisResult(AnalysisResult result);
}

class CheckUpLocalDataSourceImpl implements CheckUpLocalDataSource {
  final DatabaseService _databaseService;

  CheckUpLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<CheckUp>> getCheckUps() async {
    final db = await _databaseService.database;
    final checkUpMaps = await db.query(
      DatabaseConstants.tableCheckUp,
      orderBy: 'date DESC',
    );

    final List<CheckUp> checkUps = [];
    for (var map in checkUpMaps) {
      final checkUpId = map['id'] as String;
      final symptomMaps = await db.query(
        DatabaseConstants.tableSymptom,
        where: 'checkUpId = ?',
        whereArgs: [checkUpId],
      );
      final symptoms = symptomMaps.map((e) => Symptom.fromJson(e)).toList();
      checkUps.add(CheckUp.fromJson(map, symptoms: symptoms));
    }
    return checkUps;
  }

  @override
  Future<void> saveCheckUp(CheckUp checkUp) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.insert(
        DatabaseConstants.tableCheckUp,
        checkUp.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Clear current symptoms for this checkup
      await txn.delete(
        DatabaseConstants.tableSymptom,
        where: 'checkUpId = ?',
        whereArgs: [checkUp.id],
      );

      // Write new symptoms
      for (var symptom in checkUp.symptoms) {
        await txn.insert(
          DatabaseConstants.tableSymptom,
          symptom.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> deleteCheckUp(String id) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseConstants.tableSymptom,
        where: 'checkUpId = ?',
        whereArgs: [id],
      );
      await txn.delete(
        DatabaseConstants.tableAnalysisResult,
        where: 'checkUpId = ?',
        whereArgs: [id],
      );
      await txn.delete(
        DatabaseConstants.tableCheckUp,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<List<AnalysisResult>> getAnalysisResults() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      DatabaseConstants.tableAnalysisResult,
      orderBy: 'date DESC',
    );
    return maps.map((e) => AnalysisResult.fromJson(e)).toList();
  }

  @override
  Future<void> saveAnalysisResult(AnalysisResult result) async {
    final db = await _databaseService.database;
    await db.insert(
      DatabaseConstants.tableAnalysisResult,
      result.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
