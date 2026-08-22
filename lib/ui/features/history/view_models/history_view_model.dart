import 'package:flutter/material.dart';

import '../../../../domain/models/check_up.dart';
import '../../../../domain/models/cycle.dart';
import '../../../../domain/models/report.dart';
import '../../../../domain/repositories/check_up_repository.dart';
import '../../../../domain/repositories/cycle_repository.dart';
import '../../../../domain/repositories/report_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final CycleRepository _cycleRepository;
  final CheckUpRepository _checkUpRepository;
  final ReportRepository _reportRepository;

  HistoryViewModel(
    this._cycleRepository,
    this._checkUpRepository,
    this._reportRepository,
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Cycle> _cycles = [];
  List<Cycle> get cycles => _cycles;

  List<CheckUp> _checkUps = [];
  List<CheckUp> get checkUps => _checkUps;

  List<Report> _reports = [];
  List<Report> get reports => _reports;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cycles = await _cycleRepository.getCycles();
      _checkUps = await _checkUpRepository.getCheckUps();
      _reports = await _reportRepository.getReports();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
