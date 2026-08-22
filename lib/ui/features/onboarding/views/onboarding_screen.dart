import 'package:flutter/material.dart';

import '../view_models/onboarding_view_model.dart';
import 'welcome_view.dart';
import 'privacy_view.dart';
import 'last_period_view.dart';
import 'cycle_length_view.dart';
import 'period_duration_view.dart';
import 'goal_view.dart';
import 'review_view.dart';
import 'restore_backup_view.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingViewModel viewModel;
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.viewModel,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.viewModel.currentStep);
    widget.viewModel.addListener(_onStepChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onStepChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        widget.viewModel.currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Control navigation programmatically via ViewModel
        children: [
          WelcomeView(viewModel: widget.viewModel), // Index 0
          PrivacyView(viewModel: widget.viewModel), // Index 1
          LastPeriodView(viewModel: widget.viewModel), // Index 2
          CycleLengthView(viewModel: widget.viewModel), // Index 3
          PeriodDurationView(viewModel: widget.viewModel), // Index 4
          GoalView(viewModel: widget.viewModel), // Index 5
          ReviewView(
            viewModel: widget.viewModel,
            onComplete: widget.onComplete,
          ), // Index 6
          RestoreBackupView(
            viewModel: widget.viewModel,
            onRestoreSuccess: widget.onComplete,
          ), // Index 7
        ],
      ),
    );
  }
}
