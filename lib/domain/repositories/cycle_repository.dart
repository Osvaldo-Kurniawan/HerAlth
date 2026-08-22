import '../models/cycle.dart';

abstract class CycleRepository {
  Future<List<Cycle>> getCycles();
  Future<void> saveCycle(Cycle cycle);
  Future<void> deleteCycle(String id);

  Future<List<CycleEntry>> getCycleEntries();
  Future<void> saveCycleEntry(CycleEntry entry);
  Future<void> deleteCycleEntry(String id);
}
