import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'ui/features/onboarding/view_models/onboarding_view_model.dart';
import 'ui/features/onboarding/views/onboarding_screen.dart';
import 'ui/features/home/views/main_navigation_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  await ServiceLocator.instance.setup();
  runApp(const HerAlthApp());
}

class HerAlthApp extends StatefulWidget {
  const HerAlthApp({super.key});

  @override
  State<HerAlthApp> createState() => _HerAlthAppState();
}

class _HerAlthAppState extends State<HerAlthApp> {
  bool _isOnboarded = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final profile = await ServiceLocator.instance.userProfileRepository
        .getUserProfile();
    setState(() {
      _isOnboarded = profile != null;
      _isChecking = false;
    });
  }

  void _onOnboardingComplete() {
    setState(() {
      _isOnboarded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HerAlth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE88A8A)),
      ),
      home: _isChecking
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _isOnboarded
          ? const MainNavigationContainer()
          : OnboardingScreen(
              viewModel: OnboardingViewModel(
                ServiceLocator.instance.userProfileRepository,
                ServiceLocator.instance.cycleRepository,
              ),
              onComplete: _onOnboardingComplete,
            ),
    );
  }
}
