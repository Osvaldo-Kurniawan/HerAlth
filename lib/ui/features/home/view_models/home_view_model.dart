import 'package:flutter/material.dart';

import '../../../../domain/models/cycle.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/repositories/cycle_repository.dart';
import '../../../../domain/repositories/user_profile_repository.dart';
import '../../../../domain/services/cycle_engine.dart';

class HomeViewModel extends ChangeNotifier {
  final UserProfileRepository _userProfileRepository;
  final CycleRepository _cycleRepository;
  final CycleEngine _cycleEngine;

  HomeViewModel(
    this._userProfileRepository,
    this._cycleRepository,
    this._cycleEngine,
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  CycleSettings? _settings;
  CycleSettings? get settings => _settings;

  List<Cycle> _cycleHistory = [];
  List<Cycle> get cycleHistory => _cycleHistory;

  CyclePrediction? _prediction;
  CyclePrediction? get prediction => _prediction;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _userProfileRepository.getUserProfile();
      _settings = await _userProfileRepository.getCycleSettings();
      _cycleHistory = await _cycleRepository.getCycles();

      if (_settings != null) {
        _prediction = _cycleEngine.predictNextCycle(
          cycleHistory: _cycleHistory,
          settings: _settings!,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logPeriodStart(DateTime date) async {
    final newCycle = Cycle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: date,
      flowIntensity: 'Medium',
    );
    await _cycleRepository.saveCycle(newCycle);
    await loadDashboard();
  }

  /// Whether the current (most recent) cycle has reached or passed its
  /// predicted length without an end-of-cycle check-in yet. Derived from
  /// persisted cycle/settings state so it stays correct across app restarts.
  bool get isEndOfCycleCheckInDue {
    if (_cycleHistory.isEmpty || _settings == null) return false;

    final lastCycle = _cycleHistory.first;
    if (lastCycle.endDate != null) return false;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final start = DateTime(
      lastCycle.startDate.year,
      lastCycle.startDate.month,
      lastCycle.startDate.day,
    );
    final currentDay = todayDate.difference(start).inDays + 1;

    return currentDay >= _settings!.averageCycleLength;
  }

  /// Confirms the current cycle has ended, persisting its actual length
  /// via the existing cycle repository (upsert by id).
  Future<void> completeEndOfCycleCheckIn(DateTime endDate) async {
    if (_cycleHistory.isEmpty) return;

    final lastCycle = _cycleHistory.first;
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    final start = DateTime(
      lastCycle.startDate.year,
      lastCycle.startDate.month,
      lastCycle.startDate.day,
    );
    final length = normalizedEnd.difference(start).inDays + 1;

    await _cycleRepository.saveCycle(
      lastCycle.copyWith(
        endDate: normalizedEnd,
        cycleLength: length < 1 ? 1 : length,
      ),
    );
    await loadDashboard();
  }
}
