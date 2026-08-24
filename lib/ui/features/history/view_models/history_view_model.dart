import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../domain/models/check_up.dart';
import '../../../../domain/models/check_up_analysis.dart';
import '../../../../domain/models/cycle.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/models/report.dart';
import '../../../../domain/repositories/check_up_repository.dart';
import '../../../../domain/repositories/cycle_repository.dart';
import '../../../../domain/repositories/report_repository.dart';
import '../../../../domain/repositories/user_profile_repository.dart';
import '../../../../domain/services/cycle_engine.dart';

enum HistoryFilter { all, flagged, normal }

class HistoryViewModel extends ChangeNotifier {
  final CycleRepository _cycleRepository;
  final CheckUpRepository _checkUpRepository;
  final ReportRepository _reportRepository;
  final UserProfileRepository? _userProfileRepository;
  final CycleEngine? _cycleEngine;

  HistoryViewModel(
    this._cycleRepository,
    this._checkUpRepository,
    this._reportRepository, {
    UserProfileRepository? userProfileRepository,
    CycleEngine? cycleEngine,
  }) : _userProfileRepository = userProfileRepository,
       _cycleEngine = cycleEngine;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Cycle> _cycles = [];
  List<Cycle> get cycles => _cycles;

  List<CheckUp> _checkUps = [];
  List<CheckUp> get checkUps => _checkUps;

  List<Report> _reports = [];
  List<Report> get reports => _reports;

  List<AnalysisResult> _analysisResults = [];
  List<AnalysisResult> get analysisResults =>
      List.unmodifiable(_analysisResults);

  HistoryFilter _filter = HistoryFilter.all;
  HistoryFilter get filter => _filter;

  CycleContextSnapshot _cycleContext = const CycleContextSnapshot.defaults();
  CycleContextSnapshot get cycleContext => _cycleContext;

  List<CheckUp> get filteredCheckUps {
    return List.unmodifiable(
      _checkUps.where((checkUp) {
        return switch (_filter) {
          HistoryFilter.all => true,
          HistoryFilter.flagged => isFlagged(checkUp),
          HistoryFilter.normal => !isFlagged(checkUp),
        };
      }),
    );
  }

  int get flaggedCount => _checkUps.where(isFlagged).length;

  int get monthsTracked {
    final months = <String>{};
    for (final cycle in _cycles) {
      months.add('${cycle.startDate.year}-${cycle.startDate.month}');
    }
    for (final checkUp in _checkUps) {
      months.add('${checkUp.date.year}-${checkUp.date.month}');
    }
    return months.length;
  }

  void setFilter(HistoryFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cycles = await _cycleRepository.getCycles();
      _checkUps = await _checkUpRepository.getCheckUps();
      _reports = await _reportRepository.getReports();
      _analysisResults = await _checkUpRepository.getAnalysisResults();
      await _loadCycleContext();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CheckUpAnalysis? analysisFor(String checkUpId) {
    final result = _analysisResults.cast<AnalysisResult?>().firstWhere(
      (item) => item?.checkUpId == checkUpId,
      orElse: () => null,
    );
    if (result == null) return null;
    try {
      final json = jsonDecode(result.resultText);
      if (json is! Map<String, dynamic>) return null;
      return CheckUpAnalysis.fromJson(json, rawText: jsonEncode(json));
    } on FormatException {
      return null;
    }
  }

  bool isFlagged(CheckUp checkUp) {
    final analysis = analysisFor(checkUp.id);
    if (analysis == null) return false;
    final attention = analysis.attention.toLowerCase();
    return attention.contains('attention') || analysis.signalPercent >= 60;
  }

  Future<void> _loadCycleContext() async {
    final settings = await _userProfileRepository?.getCycleSettings();
    final latest = _cycles.isEmpty ? null : _cycles.first;
    final average = settings?.averageCycleLength ?? 28;
    final cycleDay = latest == null
        ? 13
        : DateTime.now().difference(latest.startDate).inDays + 1;
    final safeCycleDay = cycleDay.clamp(1, 60);
    final phase =
        _cycleEngine?.getPhaseForDay(
          safeCycleDay,
          settings ??
              const CycleSettings(
                averageCycleLength: 28,
                averagePeriodDuration: 5,
              ),
        ) ??
        CyclePhase.ovulatory;
    _cycleContext = CycleContextSnapshot(
      cycleDay: safeCycleDay,
      phase: _phaseLabel(phase),
      averageCycleLength: average,
      lastPeriod: latest?.startDate,
      regularity: _regularityLabel(_cycles),
      cycleLengths: _cycles
          .map((cycle) => cycle.cycleLength)
          .whereType<int>()
          .toList(),
    );
  }

  String _phaseLabel(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstruation => 'Menstruation',
      CyclePhase.follicular => 'Follicular',
      CyclePhase.ovulatory => 'Ovulation',
      CyclePhase.luteal => 'Luteal',
    };
  }

  String _regularityLabel(List<Cycle> cycles) {
    if (cycles.length < 3) return 'Not enough data';
    return 'Tracked locally';
  }
}
