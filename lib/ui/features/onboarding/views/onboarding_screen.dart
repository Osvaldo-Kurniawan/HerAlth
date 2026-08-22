import 'package:flutter/material.dart';

import '../view_models/onboarding_view_model.dart';

class OnboardingScreen extends StatelessWidget {
  final OnboardingViewModel viewModel;

  const OnboardingScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Welcome to HerAlth')),
          body: const Center(child: Text('Onboarding Skeleton Screen')),
        );
      },
    );
  }
}
