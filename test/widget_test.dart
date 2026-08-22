import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/domain/models/user_profile.dart';
import 'package:heralth/domain/repositories/user_profile_repository.dart';
import 'package:heralth/ui/features/onboarding/view_models/onboarding_view_model.dart';
import 'package:heralth/ui/features/onboarding/views/onboarding_screen.dart';

class FakeUserProfileRepository implements UserProfileRepository {
  UserProfile? profile;
  CycleSettings? settings;
  ReminderSettings? reminders;
  AiSettings? ai;

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
  Future<AiSettings?> getAiSettings() async => ai;

  @override
  Future<void> saveAiSettings(AiSettings aiSettings) async {
    ai = aiSettings;
  }

  @override
  Future<void> clearAllData() async {
    profile = null;
    settings = null;
    reminders = null;
    ai = null;
  }
}

void main() {
  testWidgets('Onboarding flow - Complete happy path', (WidgetTester tester) async {
    final fakeUserProfileRepo = FakeUserProfileRepository();
    final viewModel = OnboardingViewModel(fakeUserProfileRepo);
    
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool isCompleted = false;

    await tester.pumpWidget(MaterialApp(
      home: OnboardingScreen(
        viewModel: viewModel,
        onComplete: () {
          isCompleted = true;
        },
      ),
    ));

    // 1. Welcome Screen
    expect(find.text('HerAlth'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);
    
    // Move to Privacy Screen
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // 2. Privacy Screen
    expect(find.text('Your data never leaves this phone.'), findsOneWidget);
    // Button is disabled because checkbox is not checked
    final continueBtn = find.text('Continue');
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();
    expect(viewModel.currentStep, 1); // Still on privacy screen

    // Check box and Continue
    final checkbox = find.byType(CheckboxListTile);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();
    expect(viewModel.currentStep, 2); // Moved to Last Period

    // 3. Last Period Screen
    expect(find.text('When did your last period start?'), findsOneWidget);
    // Tap a day in the calendar (e.g. day 14 of the month)
    final day14 = find.text('14');
    await tester.tap(day14);
    await tester.pumpAndSettle();
    
    final lastPeriodContinueBtn = find.text('Continue');
    await tester.ensureVisible(lastPeriodContinueBtn);
    await tester.tap(lastPeriodContinueBtn);
    await tester.pumpAndSettle();
    expect(viewModel.currentStep, 3); // Moved to Cycle Length

    // 4. Cycle Length Screen
    expect(find.text('How long is your cycle, usually?'), findsOneWidget);
    final cycleContinueBtn = find.text('Continue');
    await tester.ensureVisible(cycleContinueBtn);
    await tester.tap(cycleContinueBtn);
    await tester.pumpAndSettle();
    expect(viewModel.currentStep, 4); // Moved to Period Duration

    // 5. Period Duration Screen
    expect(find.text('How long is your period, usually?'), findsOneWidget);
    final periodContinueBtn = find.text('Continue');
    await tester.ensureVisible(periodContinueBtn);
    await tester.tap(periodContinueBtn);
    await tester.pumpAndSettle();
    expect(viewModel.currentStep, 5); // Moved to Goal

    // 6. Goal Screen
    expect(find.text('What brings you to HerAlth?'), findsOneWidget);
    // Tap unselected option
    final goalOption = find.text('Track my cycle');
    await tester.ensureVisible(goalOption);
    await tester.tap(goalOption);
    await tester.pumpAndSettle();
    
    final finishSetupBtn = find.text('Finish setup');
    await tester.ensureVisible(finishSetupBtn);
    await tester.tap(finishSetupBtn);
    await tester.pumpAndSettle();
    expect(viewModel.currentStep, 6); // Moved to Review

    // 7. Review Screen
    expect(find.text('You\'re all set.'), findsOneWidget);
    final openHerAlthBtn = find.text('Open HerAlth');
    await tester.ensureVisible(openHerAlthBtn);
    await tester.tap(openHerAlthBtn);
    await tester.pumpAndSettle();

    // Verify completed callback
    expect(isCompleted, true);
    expect(fakeUserProfileRepo.profile?.name, 'Jane Doe');
    expect(fakeUserProfileRepo.settings?.averageCycleLength, 28);
  });
}
