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
}
