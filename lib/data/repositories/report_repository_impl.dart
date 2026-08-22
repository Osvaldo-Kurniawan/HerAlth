import '../../domain/models/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource _localDataSource;

  ReportRepositoryImpl(this._localDataSource);

  @override
  Future<List<Report>> getReports() {
    return _localDataSource.getReports();
  }

  @override
  Future<void> saveReport(Report report) {
    return _localDataSource.saveReport(report);
  }

  @override
  Future<void> deleteReport(String id) {
    return _localDataSource.deleteReport(id);
  }
}
