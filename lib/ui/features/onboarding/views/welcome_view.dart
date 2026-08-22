import 'package:flutter/material.dart';
import '../view_models/onboarding_view_model.dart';

class WelcomeView extends StatefulWidget {
  final OnboardingViewModel viewModel;

  const WelcomeView({super.key, required this.viewModel});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Smooth, slow 6-second breathing loop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCF5F5),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Circular element
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2.0 * 3.14159,
                    child: Transform.scale(
                      scale: 1.0 + (_controller.value * 0.05), // Subtle scale (breathing 5%)
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFE88A8A).withOpacity(0.4),
                              const Color(0xFF9E385A).withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF9E385A).withOpacity(0.3),
                            width: 2.0,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 64,
                            color: Color(0xFF9E385A),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              const Text(
                'HerAlth',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your calm, secure, and private local-first cycle and symptom tracker.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6E6E6E),
                  height: 1.4,
                ),
              ),
              const Spacer(),
              // CTA Buttons
              ElevatedButton(
                onPressed: () => widget.viewModel.nextStep(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E385A),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => widget.viewModel.goToStep(7), // Step 7 is Restore Backup
                child: const Text(
                  'Restore from Backup',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9E385A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
