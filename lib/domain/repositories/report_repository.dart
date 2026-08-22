import '../models/report.dart';

abstract class ReportRepository {
  Future<List<Report>> getReports();
  Future<void> saveReport(Report report);
  Future<void> deleteReport(String id);
}
