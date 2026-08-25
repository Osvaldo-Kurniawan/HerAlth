import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/domain/models/cycle.dart';
import 'package:heralth/domain/models/user_profile.dart';
import 'package:heralth/domain/repositories/cycle_repository.dart';
import 'package:heralth/domain/repositories/user_profile_repository.dart';
import 'package:heralth/domain/services/cycle_engine.dart';
import 'package:heralth/ui/features/home/view_models/home_view_model.dart';

class _FakeUserProfileRepository implements UserProfileRepository {
  UserProfile? profile;
  CycleSettings? settings;
  ReminderSettings? reminders;

  @override
  Future<UserProfile?> getUserProfile() async => profile;

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    this.profile = profile;
  }

  @override
  Future<CycleSettings?> getCycleSettings() async => settings;

  @override
  Future<void> saveCycleSettings(CycleSettings cycleSettings) async {
    settings = cycleSettings;
  }

  @override
  Future<ReminderSettings?> getReminderSettings() async => reminders;

  @override
  Future<void> saveReminderSettings(ReminderSettings reminderSettings) async {
    reminders = reminderSettings;
  }

  @override
  Future<void> clearAllData() async {
    profile = null;
    settings = null;
    reminders = null;
  }
}

class _FakeCycleRepository implements CycleRepository {
  final List<Cycle> cycles = [];
  final List<CycleEntry> entries = [];

  @override
  Future<List<Cycle>> getCycles() async =>
      [...cycles]..sort((a, b) => b.startDate.compareTo(a.startDate));

  @override
  Future<void> saveCycle(Cycle cycle) async {
    cycles.removeWhere((c) => c.id == cycle.id);
    cycles.add(cycle);
  }

  @override
  Future<void> deleteCycle(String id) async {
    cycles.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<CycleEntry>> getCycleEntries() async => entries;

  @override
  Future<void> saveCycleEntry(CycleEntry entry) async {
    entries.removeWhere((e) => e.id == entry.id);
    entries.add(entry);
  }

  @override
  Future<void> deleteCycleEntry(String id) async {
    entries.removeWhere((e) => e.id == id);
  }
}

void main() {
  late _FakeUserProfileRepository userProfileRepository;
  late _FakeCycleRepository cycleRepository;
  late HomeViewModel viewModel;

  setUp(() {
    userProfileRepository = _FakeUserProfileRepository();
    cycleRepository = _FakeCycleRepository();
    viewModel = HomeViewModel(
      userProfileRepository,
      cycleRepository,
      CycleEngine(),
    );
  });

  test('end-of-cycle check-in is not due with no cycle data', () async {
    await viewModel.loadDashboard();
    expect(viewModel.isEndOfCycleCheckInDue, isFalse);
  });

  test(
    'end-of-cycle check-in is not due with incomplete setup (no settings)',
    () async {
      cycleRepository.cycles.add(
        Cycle(
          id: '1',
          startDate: DateTime.now().subtract(const Duration(days: 40)),
          flowIntensity: 'Medium',
        ),
      );
      await viewModel.loadDashboard();
      expect(viewModel.isEndOfCycleCheckInDue, isFalse);
    },
  );

  test('end-of-cycle check-in is not due mid-cycle', () async {
    userProfileRepository.settings = const CycleSettings(
      averageCycleLength: 28,
      averagePeriodDuration: 5,
    );
    cycleRepository.cycles.add(
      Cycle(
        id: '1',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        flowIntensity: 'Medium',
      ),
    );
    await viewModel.loadDashboard();
    expect(viewModel.isEndOfCycleCheckInDue, isFalse);
  });

  test('end-of-cycle check-in becomes due once the cycle reaches its predicted length', () async {
    userProfileRepository.settings = const CycleSettings(
      averageCycleLength: 28,
      averagePeriodDuration: 5,
    );
    cycleRepository.cycles.add(
      Cycle(
        id: '1',
        startDate: DateTime.now().subtract(const Duration(days: 28)),
        flowIntensity: 'Medium',
      ),
    );
    await viewModel.loadDashboard();
    expect(viewModel.isEndOfCycleCheckInDue, isTrue);
  });

  test('completing the check-in persists endDate/cycleLength and clears the due state', () async {
    userProfileRepository.settings = const CycleSettings(
      averageCycleLength: 28,
      averagePeriodDuration: 5,
    );
    final start = DateTime.now().subtract(const Duration(days: 30));
    cycleRepository.cycles.add(
      Cycle(id: '1', startDate: start, flowIntensity: 'Medium'),
    );
    await viewModel.loadDashboard();
    expect(viewModel.isEndOfCycleCheckInDue, isTrue);

    await viewModel.completeEndOfCycleCheckIn(DateTime.now());

    expect(viewModel.isEndOfCycleCheckInDue, isFalse);
    final saved = cycleRepository.cycles.single;
    expect(saved.endDate, isNotNull);
    expect(saved.cycleLength, 31);
  });

  test(
    'already-completed end-of-cycle check-in stays not due after reload',
    () async {
      userProfileRepository.settings = const CycleSettings(
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );
      final start = DateTime.now().subtract(const Duration(days: 30));
      cycleRepository.cycles.add(
        Cycle(
          id: '1',
          startDate: start,
          endDate: DateTime.now(),
          cycleLength: 30,
          flowIntensity: 'Medium',
        ),
      );

      await viewModel.loadDashboard();
      expect(viewModel.isEndOfCycleCheckInDue, isFalse);

      // Simulate reopening the app: state is re-derived from persisted data.
      final reopened = HomeViewModel(
        userProfileRepository,
        cycleRepository,
        CycleEngine(),
      );
      await reopened.loadDashboard();
      expect(reopened.isEndOfCycleCheckInDue, isFalse);
    },
  );
}
