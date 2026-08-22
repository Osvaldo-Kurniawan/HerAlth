import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'ui/features/onboarding/view_models/onboarding_view_model.dart';
import 'ui/features/onboarding/views/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    final profile = await ServiceLocator.instance.userProfileRepository.getUserProfile();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE88A8A),
        ),
      ),
      home: _isChecking
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _isOnboarded
              ? const HomeScreen()
              : OnboardingScreen(
                  viewModel: OnboardingViewModel(
                    ServiceLocator.instance.userProfileRepository,
                  ),
                  onComplete: _onOnboardingComplete,
                ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HerAlth'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded, size: 64, color: Color(0xFFE88A8A)),
            SizedBox(height: 16),
            Text(
              'HerAlth',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Start developing the app here.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
