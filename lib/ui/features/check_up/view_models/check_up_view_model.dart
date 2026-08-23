import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/validation/ultrasound_validator.dart';
import '../../../../data/services/gemini_analysis_service.dart';
import '../../../../domain/models/check_up.dart';
import '../../../../domain/models/check_up_analysis.dart';
import '../../../../domain/models/cycle.dart';
import '../../../../domain/models/ultrasound_attachment.dart';
import '../../../../domain/repositories/check_up_repository.dart';
import '../../../../domain/repositories/cycle_repository.dart';
import '../../../../domain/repositories/user_profile_repository.dart';
import '../../../../domain/services/check_up_analysis_service.dart';

class CheckUpViewModel extends ChangeNotifier {
  final CheckUpRepository _checkUpRepository;
  final CycleRepository? cycleRepository;
  final UserProfileRepository? userProfileRepository;
  final CheckUpAnalysisService _analysisService;
  final UltrasoundValidator _ultrasoundValidator;

  CheckUpViewModel(
    this._checkUpRepository, {
    this.cycleRepository,
    this.userProfileRepository,
    CheckUpAnalysisService? analysisService,
    UltrasoundValidator? ultrasoundValidator,
  }) : _analysisService = analysisService ?? GeminiAnalysisService(),
       _ultrasoundValidator = ultrasoundValidator ?? UltrasoundValidator();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  List<CheckUp> _checkUps = [];
  List<CheckUp> get checkUps => List.unmodifiable(_checkUps);

  final Set<String> _selectedSymptoms = <String>{};
  List<String> get selectedSymptoms => List.unmodifiable(_selectedSymptoms);

  String _notes = '';
  String get notes => _notes;

  UltrasoundAttachment? _ultrasound;
  UltrasoundAttachment? get ultrasound => _ultrasound;

  CycleContextSnapshot _cycleContext = const CycleContextSnapshot.defaults();
  CycleContextSnapshot get cycleContext => _cycleContext;

  CheckUpAnalysis? _analysis;
  CheckUpAnalysis? get analysis => _analysis;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _diagnosticErrorMessage;
  String? get diagnosticErrorMessage => _diagnosticErrorMessage;

  void toggleSymptom(String symptom) {
    if (_selectedSymptoms.contains(symptom)) {
      _selectedSymptoms.remove(symptom);
    } else if (_selectedSymptoms.length < 20) {
      _selectedSymptoms.add(symptom);
    }
    _errorMessage = null;
    _diagnosticErrorMessage = null;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes.trim().length > 200 ? notes.trim().substring(0, 200) : notes;
    notifyListeners();
  }

  Future<UltrasoundValidationResult> setUltrasound({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final payload = await _ultrasoundValidator.validate(
      fileName: fileName,
      bytes: bytes,
    );
    if (!payload.isValid || payload.mimeType == null) {
      _errorMessage = payload.errorMessage;
      _diagnosticErrorMessage = null;
      notifyListeners();
      return payload;
    }
    _ultrasound = UltrasoundAttachment(
      name: fileName,
      bytes: bytes,
      mimeType: payload.mimeType!,
    );
    _errorMessage = null;
    _diagnosticErrorMessage = null;
    notifyListeners();
    return payload;
  }

  void removeUltrasound() {
    _ultrasound = null;
    _errorMessage = null;
    _diagnosticErrorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _diagnosticErrorMessage = null;
    notifyListeners();
  }

  void resetFlow() {
    _selectedSymptoms.clear();
    _notes = '';
    _ultrasound = null;
    _analysis = null;
    _errorMessage = null;
    _diagnosticErrorMessage = null;
    _cycleContext = const CycleContextSnapshot.defaults();
    notifyListeners();
  }

  Future<void> loadCycleContext() async {
    if (cycleRepository == null || userProfileRepository == null) return;

    try {
      final settings = await userProfileRepository!.getCycleSettings();
      final cycles = await cycleRepository!.getCycles();
      final sorted = [...cycles]
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
      final latest = sorted.isEmpty ? null : sorted.first;
      final average = settings?.averageCycleLength ?? 28;
      final cycleDay = latest == null
          ? 13
          : DateTime.now().difference(latest.startDate).inDays.clamp(1, 60);
      final lengths = _cycleLengths(sorted);
      _cycleContext = CycleContextSnapshot(
        cycleDay: cycleDay,
        phase: _phaseFor(cycleDay, average),
        averageCycleLength: average,
        lastPeriod: latest?.startDate,
        regularity: _regularityFor(lengths),
        cycleLengths: lengths,
      );
      notifyListeners();
    } catch (_) {
      // The review flow remains usable with neutral defaults.
    }
  }

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

  Future<CheckUpAnalysis> analyzeCurrentCheckUp() async {
    if (_selectedSymptoms.isEmpty) {
      throw const CheckUpValidationException(
        'Select at least one symptom first.',
      );
    }

    _isAnalyzing = true;
    _errorMessage = null;
    _diagnosticErrorMessage = null;
    notifyListeners();

    final checkUpId = DateTime.now().millisecondsSinceEpoch.toString();
    final symptoms = _selectedSymptoms
        .map(
          (name) => Symptom(
            id: '$checkUpId-$name',
            checkUpId: checkUpId,
            name: name,
            category: SymptomCategory.physical,
          ),
        )
        .toList();
    try {
      final analysis = await _analysisService.analyze(
        symptoms: selectedSymptoms,
        notes: _notes,
        cycleContext: _cycleContext,
        ultrasound: _ultrasound,
      );
      _analysis = analysis;
      await _checkUpRepository.saveCheckUp(
        CheckUp(
          id: checkUpId,
          date: DateTime.now(),
          notes: _notes,
          ultrasoundPath: _ultrasound?.name,
          symptoms: symptoms,
        ),
      );
      await _checkUpRepository.saveAnalysisResult(
        AnalysisResult(
          id: '$checkUpId-analysis',
          checkUpId: checkUpId,
          resultText: jsonEncode(analysis.toJson()),
          date: DateTime.now(),
        ),
      );
      return analysis;
    } on InvalidUltrasoundException catch (error) {
      _errorMessage = error.message;
      _diagnosticErrorMessage = null;
      rethrow;
    } on GeminiAnalysisException catch (error) {
      _errorMessage = error.message;
      _diagnosticErrorMessage = error.diagnosticMessage;
      rethrow;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  List<int> _cycleLengths(List<Cycle> cycles) {
    final lengths = <int>[];
    for (var index = 0; index + 1 < cycles.length; index++) {
      final difference = cycles[index].startDate
          .difference(cycles[index + 1].startDate)
          .inDays;
      if (difference >= 15 && difference <= 90) lengths.add(difference);
    }
    if (lengths.isEmpty) return const [27, 29, 28, 31, 26, 30];
    return lengths.take(6).map((length) => length.clamp(15, 90)).toList();
  }

  String _phaseFor(int cycleDay, int cycleLength) {
    if (cycleDay <= 5) return 'Menstruation';
    if (cycleDay <= (cycleLength / 2).round() - 2) return 'Follicular';
    if (cycleDay <= (cycleLength / 2).round() + 2) return 'Ovulation';
    return 'Luteal';
  }

  String _regularityFor(List<int> lengths) {
    if (lengths.length < 2) return 'Not enough data';
    final max = lengths.reduce((a, b) => a > b ? a : b);
    final min = lengths.reduce((a, b) => a < b ? a : b);
    return max - min <= 3 ? 'Regular' : 'Slightly irregular';
  }
}

class CheckUpValidationException implements Exception {
  final String message;

  const CheckUpValidationException(this.message);
}
