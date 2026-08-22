import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../view_models/onboarding_view_model.dart';

class WelcomeView extends StatefulWidget {
  final OnboardingViewModel viewModel;

  const WelcomeView({super.key, required this.viewModel});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _interactionController;

  // Animations driven by the single master idle controller
  late Animation<double> _groupRotation;
  late Animation<double> _outerY;
  late Animation<double> _outerScale;
  late Animation<double> _middleY;
  late Animation<double> _middleX;
  late Animation<double> _innerY;
  late Animation<double> _innerScale;

  @override
  void initState() {
    super.initState();

    // 6-second loop for the calm breathing/floating cycle
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _interactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Group drift rotation (±4 degrees)
    _groupRotation = Tween<double>(begin: -4.0 * math.pi / 180.0, end: 4.0 * math.pi / 180.0).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Outer Ring: Y ±20px, scale 100-106%
    _outerY = Tween<double>(begin: -20.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutSine),
      ),
    );
    _outerScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    // Middle Ring: Y ±16px, X ±10px
    _middleY = Tween<double>(begin: -16.0, end: 16.0).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOutSine),
      ),
    );
    _middleX = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutSine),
      ),
    );

    // Inner Ring: Y ±12px, scale 100-104%
    _innerY = Tween<double>(begin: -12.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOutSine),
      ),
    );
    _innerScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOutSine),
      ),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
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
                animation: Listenable.merge([_idleController, _interactionController]),
                builder: (context, child) {
                  final interaction = _interactionController.value;

                  // Apply interaction offset to scales
                  final currentOuterScale = _outerScale.value + (0.04 * interaction);
                  final currentMiddleScale = 1.0 + (0.03 * interaction);
                  final currentInnerScale = _innerScale.value + (0.02 * interaction);

                  return Center(
                    child: Transform.rotate(
                      angle: _groupRotation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Ring
                          Transform.translate(
                            offset: Offset(0, _outerY.value),
                            child: Transform.scale(
                              scale: currentOuterScale,
                              child: _buildRing(size: 320),
                            ),
                          ),
                          // Middle Ring
                          Transform.translate(
                            offset: Offset(_middleX.value, _middleY.value),
                            child: Transform.scale(
                              scale: currentMiddleScale,
                              child: _buildRing(size: 230),
                            ),
                          ),
                          // Inner Ring
                          Transform.translate(
                            offset: Offset(0, _innerY.value),
                            child: Transform.scale(
                              scale: currentInnerScale,
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
          color: const Color(0xFFACC2F7).withValues(alpha: 0.5), // Soft blue/periwinkle ring outline
          width: 2.0,
        ),
      ),
    );
  }
}
