import '../database/database_service.dart';
import '../database/sqlite_database_service.dart';
import '../../data/datasources/user_profile_local_data_source.dart';
import '../../data/datasources/cycle_local_data_source.dart';
import '../../data/datasources/check_up_local_data_source.dart';
import '../../data/datasources/report_local_data_source.dart';
import '../../data/datasources/article_local_data_source.dart';
import '../../data/services/backup_service.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../../data/repositories/cycle_repository_impl.dart';
import '../../domain/repositories/check_up_repository.dart';
import '../../data/repositories/check_up_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/article_repository.dart';
import '../../data/repositories/article_repository_impl.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../domain/services/cycle_engine.dart';
import '../../domain/services/check_up_analysis_service.dart';
import '../../domain/services/analysis_notification_service.dart';
import '../../data/services/gemini_analysis_service.dart';
import '../../data/services/local_analysis_notification_service.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();

  ServiceLocator._internal();

  late final DatabaseService databaseService;
  late final UserProfileRepository userProfileRepository;
  late final CycleRepository cycleRepository;
  late final CheckUpRepository checkUpRepository;
  late final ReportRepository reportRepository;
  late final ArticleRepository articleRepository;
  late final BackupRepository backupRepository;
  late final CycleEngine cycleEngine;
  late final CheckUpAnalysisService checkUpAnalysisService;
  late final AnalysisNotificationService analysisNotificationService;

  Future<void> setup() async {
    // 1. Database
    databaseService = SqliteDatabaseService();
    await databaseService.initDatabase();

    // 2. Data Sources
    final userProfileLocal = UserProfileLocalDataSourceImpl(databaseService);
    final cycleLocal = CycleLocalDataSourceImpl(databaseService);
    final checkUpLocal = CheckUpLocalDataSourceImpl(databaseService);
    final reportLocal = ReportLocalDataSourceImpl(databaseService);
    final articleLocal = ArticleLocalDataSourceImpl();
    final backupService = BackupServiceImpl();

    // 3. Repositories
    userProfileRepository = UserProfileRepositoryImpl(userProfileLocal);
    cycleRepository = CycleRepositoryImpl(cycleLocal);
    checkUpRepository = CheckUpRepositoryImpl(checkUpLocal);
    reportRepository = ReportRepositoryImpl(reportLocal);
    articleRepository = ArticleRepositoryImpl(articleLocal);

    backupRepository = BackupRepositoryImpl(
      userProfileRepository,
      cycleRepository,
      checkUpRepository,
      reportRepository,
      backupService,
    );

    // 4. Domain Services
    cycleEngine = CycleEngine();
    checkUpAnalysisService = GeminiAnalysisService();
    final localAnalysisNotifications = LocalAnalysisNotificationService();
    await localAnalysisNotifications.initialize();
    analysisNotificationService = localAnalysisNotifications;
  }
}
