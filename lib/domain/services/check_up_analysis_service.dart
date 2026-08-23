import '../models/check_up_analysis.dart';
import '../models/ultrasound_attachment.dart';

abstract class CheckUpAnalysisService {
  Future<CheckUpAnalysis> analyze({
    required List<String> symptoms,
    required String notes,
    required CycleContextSnapshot cycleContext,
    UltrasoundAttachment? ultrasound,
  });
}
