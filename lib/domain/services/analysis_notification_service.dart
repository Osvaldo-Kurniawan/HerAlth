abstract interface class AnalysisNotificationService {
  Future<bool> requestPermission();

  Future<void> showAnalysisCompleted();

  Future<void> showAnalysisFailed();
}

class NoopAnalysisNotificationService implements AnalysisNotificationService {
  const NoopAnalysisNotificationService();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> showAnalysisCompleted() async {}

  @override
  Future<void> showAnalysisFailed() async {}
}
