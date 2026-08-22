import '../../domain/models/check_up.dart';
import '../../domain/repositories/check_up_repository.dart';
import '../datasources/check_up_local_data_source.dart';

class CheckUpRepositoryImpl implements CheckUpRepository {
  final CheckUpLocalDataSource _localDataSource;

  CheckUpRepositoryImpl(this._localDataSource);

  @override
  Future<List<CheckUp>> getCheckUps() {
    return _localDataSource.getCheckUps();
  }

  @override
  Future<void> saveCheckUp(CheckUp checkUp) {
    return _localDataSource.saveCheckUp(checkUp);
  }

  @override
  Future<void> deleteCheckUp(String id) {
    return _localDataSource.deleteCheckUp(id);
  }

  @override
  Future<List<AnalysisResult>> getAnalysisResults() {
    return _localDataSource.getAnalysisResults();
  }

  @override
  Future<void> saveAnalysisResult(AnalysisResult result) {
    return _localDataSource.saveAnalysisResult(result);
  }
}
