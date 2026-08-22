import 'package:flutter/material.dart';

import '../../../../domain/models/check_up.dart';
import '../../../../domain/repositories/check_up_repository.dart';

class CheckUpViewModel extends ChangeNotifier {
  final CheckUpRepository _checkUpRepository;

  CheckUpViewModel(this._checkUpRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CheckUp> _checkUps = [];
  List<CheckUp> get checkUps => _checkUps;

  Future<void> loadCheckUps() async {
    _isLoading = true;
    notifyListeners();

    try {
      _checkUps = await _checkUpRepository.getCheckUps();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitCheckUp({
    required List<Symptom> symptoms,
    required String notes,
    String? ultrasoundPath,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final checkUp = CheckUp(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        notes: notes,
        ultrasoundPath: ultrasoundPath,
        symptoms: symptoms,
      );
      await _checkUpRepository.saveCheckUp(checkUp);
      await loadCheckUps();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
