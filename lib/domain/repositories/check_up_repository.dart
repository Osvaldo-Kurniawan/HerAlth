import '../models/check_up.dart';

abstract class CheckUpRepository {
  Future<List<CheckUp>> getCheckUps();
  Future<void> saveCheckUp(CheckUp checkUp);
  Future<void> deleteCheckUp(String id);

  Future<List<AnalysisResult>> getAnalysisResults();
  Future<void> saveAnalysisResult(AnalysisResult result);
}
