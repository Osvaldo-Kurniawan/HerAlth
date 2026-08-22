import 'package:sqflite/sqflite.dart';

import '../../core/database/database_service.dart';
import '../../domain/models/cycle.dart';

abstract class CycleLocalDataSource {
  Future<List<Cycle>> getCycles();
  Future<void> saveCycle(Cycle cycle);
  Future<void> deleteCycle(String id);

  Future<List<CycleEntry>> getCycleEntries();
  Future<void> saveCycleEntry(CycleEntry entry);
  Future<void> deleteCycleEntry(String id);
}

class CycleLocalDataSourceImpl implements CycleLocalDataSource {
  final DatabaseService _databaseService;

  CycleLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<Cycle>> getCycles() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      DatabaseConstants.tableCycle,
      orderBy: 'startDate DESC',
    );
    return maps.map((e) => Cycle.fromJson(e)).toList();
  }

  @override
  Future<void> saveCycle(Cycle cycle) async {
    final db = await _databaseService.database;
    await db.insert(
      DatabaseConstants.tableCycle,
      cycle.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCycle(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      DatabaseConstants.tableCycle,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<CycleEntry>> getCycleEntries() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      DatabaseConstants.tableCycleEntry,
      orderBy: 'date DESC',
    );
    return maps.map((e) => CycleEntry.fromJson(e)).toList();
  }

  @override
  Future<void> saveCycleEntry(CycleEntry entry) async {
    final db = await _databaseService.database;
    await db.insert(
      DatabaseConstants.tableCycleEntry,
      entry.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCycleEntry(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      DatabaseConstants.tableCycleEntry,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
