import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/validation/ultrasound_validator.dart';
import '../../../../data/services/gemini_analysis_service.dart';
import '../../../../domain/models/check_up.dart';
import '../../../../domain/models/check_up_analysis.dart';
import '../../../../domain/models/ultrasound_attachment.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../../domain/repositories/check_up_repository.dart';
import '../../../../domain/repositories/cycle_repository.dart';
import '../../../../domain/repositories/user_profile_repository.dart';
import '../../../../domain/services/analysis_notification_service.dart';
import '../../../../domain/services/check_up_analysis_service.dart';
import '../../../../domain/services/cycle_context_service.dart';

class CheckUpViewModel extends ChangeNotifier {
  final CheckUpRepository _checkUpRepository;
  final CycleRepository? cycleRepository;
  final UserProfileRepository? userProfileRepository;
  final CheckUpAnalysisService _analysisService;
  final AnalysisNotificationService _notificationService;
  final UltrasoundValidator _ultrasoundValidator;
  final CycleContextService _cycleContextService;

  CheckUpViewModel(
    this._checkUpRepository, {
    this.cycleRepository,
    this.userProfileRepository,
    CheckUpAnalysisService? analysisService,
    AnalysisNotificationService? notificationService,
    UltrasoundValidator? ultrasoundValidator,
    CycleContextService? cycleContextService,
  }) : _analysisService = analysisService ?? GeminiAnalysisService(),
       _notificationService =
           notificationService ?? const NoopAnalysisNotificationService(),
       _ultrasoundValidator = ultrasoundValidator ?? UltrasoundValidator(),
       _cycleContextService = cycleContextService ?? CycleContextService();

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

  CheckUp? _lastAnalyzedCheckUp;
  CheckUp? get lastAnalyzedCheckUp => _lastAnalyzedCheckUp;

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
    _lastAnalyzedCheckUp = null;
    _errorMessage = null;
    _diagnosticErrorMessage = null;
    _cycleContext = const CycleContextSnapshot.defaults();
    notifyListeners();
  }

  Future<void> loadCycleContext({DateTime? at}) async {
    if (cycleRepository == null || userProfileRepository == null) return;

    try {
      final settings = await userProfileRepository!.getCycleSettings();
      final cycles = await cycleRepository!.getCycles();
      _cycleContext = _cycleContextService.build(
        cycles: cycles,
        settings:
            settings ??
            const CycleSettings(
              averageCycleLength: 28,
              averagePeriodDuration: 5,
            ),
        at: at ?? DateTime.now(),
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
    if (_isAnalyzing) {
      throw const CheckUpValidationException(
        'An analysis is already in progress.',
      );
    }

    final analyzedAt = DateTime.now();
    _isAnalyzing = true;
    _analysis = null;
    _lastAnalyzedCheckUp = null;
    _errorMessage = null;
    _diagnosticErrorMessage = null;
    notifyListeners();

    final notificationsAllowed = await _requestNotificationPermission();
    await loadCycleContext(at: analyzedAt);

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
    var checkUpSaved = false;
    try {
      final analysis = await _analysisService.analyze(
        symptoms: selectedSymptoms,
        notes: _notes,
        cycleContext: _cycleContext,
        ultrasound: _ultrasound,
      );
      final analyzedCheckUp = CheckUp(
        id: checkUpId,
        date: analyzedAt,
        notes: _notes,
        ultrasoundPath: _ultrasound?.name,
        symptoms: symptoms,
      );
      await _checkUpRepository.saveCheckUp(analyzedCheckUp);
      checkUpSaved = true;
      await _checkUpRepository.saveAnalysisResult(
        AnalysisResult(
          id: '$checkUpId-analysis',
          checkUpId: checkUpId,
          resultText: jsonEncode({
            ...analysis.toJson(),
            'cycle_context': _cycleContext.toJson(),
          }),
          date: analyzedAt,
        ),
      );
      _analysis = analysis;
      _lastAnalyzedCheckUp = analyzedCheckUp;
      if (notificationsAllowed) {
        await _showCompletedNotification();
      }
      return analysis;
    } on InvalidUltrasoundException catch (error) {
      _errorMessage = error.message;
      _diagnosticErrorMessage = null;
      if (notificationsAllowed) await _showFailedNotification();
      rethrow;
    } on GeminiAnalysisException catch (error) {
      _errorMessage = error.message;
      _diagnosticErrorMessage = error.diagnosticMessage;
      if (notificationsAllowed) await _showFailedNotification();
      rethrow;
    } on Exception catch (error) {
      if (checkUpSaved) await _rollBackIncompleteCheckUp(checkUpId);
      _analysis = null;
      _lastAnalyzedCheckUp = null;
      _errorMessage =
          'Something went wrong while saving or analyzing. Please try again.';
      _diagnosticErrorMessage = error.toString();
      if (notificationsAllowed) await _showFailedNotification();
      rethrow;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<bool> _requestNotificationPermission() async {
    try {
      return await _notificationService.requestPermission();
    } on Exception {
      return false;
    }
  }

  Future<void> _showCompletedNotification() async {
    try {
      await _notificationService.showAnalysisCompleted();
    } on Exception {
      // A notification failure must not turn a successful analysis into a failure.
    }
  }

  Future<void> _showFailedNotification() async {
    try {
      await _notificationService.showAnalysisFailed();
    } on Exception {
      // Preserve the original analysis failure for the processing screen.
    }
  }

  Future<void> _rollBackIncompleteCheckUp(String checkUpId) async {
    try {
      await _checkUpRepository.deleteCheckUp(checkUpId);
    } on Exception {
      // Keep the original persistence exception as the diagnostic cause.
    }
  }
}

class CheckUpValidationException implements Exception {
  final String message;

  const CheckUpValidationException(this.message);
}
