import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../view_models/onboarding_view_model.dart';

class WelcomeView extends StatefulWidget {
  final OnboardingViewModel viewModel;

  const WelcomeView({super.key, required this.viewModel});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with TickerProviderStateMixin {
  late Ticker _ticker;
  double _elapsedSeconds = 0.0;

  late AnimationController _interactionController;

  @override
  void initState() {
    super.initState();

    // Ticker fires every frame to calculate elapsed time for smooth organic movements
    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsedSeconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
      });
    });
    _ticker.start();

    _interactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _interactionController.dispose();
    super.dispose();
  }

  void _handleSetUpCycle() {
    _interactionController.forward().then((_) {
      _interactionController.reverse().then((_) {
        widget.viewModel.nextStep();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F6),
      body: SafeArea(
        child: Stack(
          children: [
            // Concentric Rings in the center background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _interactionController,
                builder: (context, child) {
                  final time = _elapsedSeconds;
                  final interaction = _interactionController.value;

                  // 1. Group drift rotation (±1.5 degrees drift over 9s cycle)
                  final groupRotation = (1.5 * math.pi / 180.0) * math.sin(2.0 * math.pi * time / 9.0);

                  // 2. Outer Ring: Y ±8px, scale 100-102% over 6s cycle, interaction +4% scale
                  final outerY = 8.0 * math.sin(2.0 * math.pi * time / 6.0);
                  final outerScale = 1.0 + 0.01 + 0.01 * math.sin(2.0 * math.pi * time / 6.0) + (0.04 * interaction);

                  // 3. Middle Ring: Y ±6px, X ±3px over 5s cycle, interaction +3% scale
                  final middleY = 6.0 * math.sin(2.0 * math.pi * time / 5.0);
                  final middleX = 3.0 * math.cos(2.0 * math.pi * time / 5.0);
                  final middleScale = 1.0 + (0.03 * interaction);

                  // 4. Inner Ring: Y ±4px, scale 100-101.5% over 4s cycle, interaction +2% scale
                  final innerY = 4.0 * math.sin(2.0 * math.pi * time / 4.0);
                  final innerScale = 1.0 + 0.0075 + 0.0075 * math.sin(2.0 * math.pi * time / 4.0) + (0.02 * interaction);

                  return Center(
                    child: Transform.rotate(
                      angle: groupRotation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Ring
                          Transform.translate(
                            offset: Offset(0, outerY),
                            child: Transform.scale(
                              scale: outerScale,
                              child: _buildRing(size: 320),
                            ),
                          ),
                          // Middle Ring
                          Transform.translate(
                            offset: Offset(middleX, middleY),
                            child: Transform.scale(
                              scale: middleScale,
                              child: _buildRing(size: 230),
                            ),
                          ),
                          // Inner Ring
                          Transform.translate(
                            offset: Offset(0, innerY),
                            child: Transform.scale(
                              scale: innerScale,
                              child: _buildRing(size: 140),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Foreground Text & Layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Moon Icon Outline (Pink/Red)
                  const Icon(
                    Icons.nightlight_round_outlined,
                    size: 36,
                    color: Color(0xFFD6708A),
                  ),
                  const Spacer(),
                  // Headline (Serif style matching mock)
                  const Text(
                    'Understand\nyour body,\nmonth by\nmonth.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'serif',
                      height: 1.15,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Subtitle
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'A private, intuitive space to track your cycle and uncover insights about your overall health.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6E6E6E),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Info Pill: No account needed. Everything stays on this device.
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBEAEA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: Color(0xFF2C2C2C),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No account needed. Everything stays on this device.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Buttons
                  ElevatedButton(
                    onPressed: _handleSetUpCycle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6708A), // Vibrant rose pink
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Set up my cycle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => widget.viewModel.goToStep(7), // Restore Backup Step
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFDFC).withOpacity(0.4),
                      side: const BorderSide(color: Color(0xFFE8D5D5)),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Restore from a backup file',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C2C2C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Footer Medical Warning
                  const Text(
                    'Not a medical device. For wellness insight only.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRing({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFACC2F7).withValues(alpha: 0.35), // Very soft blue/periwinkle ring outline
          width: 1.5,
        ),
      ),
    );
  }
}
