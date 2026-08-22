import '../../domain/models/cycle.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../datasources/cycle_local_data_source.dart';

class CycleRepositoryImpl implements CycleRepository {
  final CycleLocalDataSource _localDataSource;

  CycleRepositoryImpl(this._localDataSource);

  @override
  Future<List<Cycle>> getCycles() {
    return _localDataSource.getCycles();
  }

  @override
  Future<void> saveCycle(Cycle cycle) {
    return _localDataSource.saveCycle(cycle);
  }

  @override
  Future<void> deleteCycle(String id) {
    return _localDataSource.deleteCycle(id);
  }

  @override
  Future<List<CycleEntry>> getCycleEntries() {
    return _localDataSource.getCycleEntries();
  }

  @override
  Future<void> saveCycleEntry(CycleEntry entry) {
    return _localDataSource.saveCycleEntry(entry);
  }

  @override
  Future<void> deleteCycleEntry(String id) {
    return _localDataSource.deleteCycleEntry(id);
  }
}
