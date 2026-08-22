import 'package:flutter/material.dart';

import '../../../../domain/models/user_profile.dart';
import '../../../../domain/repositories/user_profile_repository.dart';

class OnboardingViewModel extends ChangeNotifier {
  final UserProfileRepository _userProfileRepository;

  OnboardingViewModel(this._userProfileRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> completeOnboarding({
    required String name,
    required int age,
    required double height,
    required double weight,
    required int averageCycleLength,
    required int averagePeriodDuration,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final profile = UserProfile(
        name: name,
        age: age,
        height: height,
        weight: weight,
      );
      final settings = CycleSettings(
        averageCycleLength: averageCycleLength,
        averagePeriodDuration: averagePeriodDuration,
      );
      const reminders = ReminderSettings(
        periodReminderEnabled: true,
        fertilityReminderEnabled: true,
        checkUpReminderEnabled: true,
      );
      const ai = AiSettings(
        analysisModel: 'General Health GPT',
        autoAnalyzeUltrasounds: false,
      );

      await _userProfileRepository.saveUserProfile(profile);
      await _userProfileRepository.saveCycleSettings(settings);
      await _userProfileRepository.saveReminderSettings(reminders);
      await _userProfileRepository.saveAiSettings(ai);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
