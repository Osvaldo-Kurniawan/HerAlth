abstract class BackupRepository {
  Future<void> createBackup(String targetFilePath);
  Future<void> restoreBackup(String sourceFilePath);
}
