import 'package:flutter/material.dart';

import 'dart:math';

import '../../../../core/di/service_locator.dart';
import '../../check_up/view_models/check_up_view_model.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../../profile/views/profile_screen.dart';
import '../../history/view_models/history_view_model.dart';
import '../../history/views/history_screen.dart';

class CheckUpScreen extends StatelessWidget {
  final CheckUpViewModel viewModel;

  const CheckUpScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final di = ServiceLocator.instance;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFCF5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCF5F5),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'HerAlth',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF9E385A),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF2C2C2C),
                  size: 26,
                ),
                onPressed: () {
                  final historyVM = HistoryViewModel(
                    di.cycleRepository,
                    di.checkUpRepository,
                    di.reportRepository,
                  );
                  historyVM.loadHistory();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(viewModel: historyVM),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: Color(0xFF2C2C2C),
                  size: 26,
                ),
                onPressed: () {
                  final profileVM = ProfileViewModel(
                    di.userProfileRepository,
                    di.backupRepository,
                  );
                  profileVM.loadProfileData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(viewModel: profileVM),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Heading & Character Illustration
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 12),
                          Text(
                            'Something feels\ndifferent?',
                            style: TextStyle(
                              fontSize: 32,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2C),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Custom Character Drawing
                    Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: const Size(80, 80),
                        painter: CharacterPainter(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'HerAlth reviews your logged symptoms, cycle trends, and optional ultrasound data to surface patterns worth discussing with your doctor.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6E6E6E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                // Connected Steps List
                _buildStepsTimeline(),
                const SizedBox(height: 32),

                // Info Warning Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCF0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF9E385A),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'HerAlth does not diagnose. Results are informational and should be reviewed with a healthcare professional.',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF2C2C2C).withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // CTA button
                ElevatedButton(
                  onPressed: () {
                    // Scope is only landing. Open the intended flow or placeholder.
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      builder: (context) => _buildCheckUpIntroSheet(context),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E385A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'I want to check mine',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepsTimeline() {
    return Stack(
      children: [
        // Connecting line
        Positioned(
          left: 27,
          top: 30,
          bottom: 30,
          child: Container(
            width: 1,
            color: const Color(0xFFE88A8A).withOpacity(0.3),
          ),
        ),
        Column(
          children: [
            _buildStepItem(
              '01',
              'Symptoms',
              'Select what you\'re noticing now.',
            ),
            const SizedBox(height: 24),
            _buildStepItem(
              '02',
              'Ultrasound (optional)',
              'Upload images for pattern analysis.',
            ),
            const SizedBox(height: 24),
            _buildStepItem(
              '03',
              'Review & analyze',
              'Private summary of potential patterns.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepItem(String number, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom circle number
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE88A8A).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9E385A),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E8E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckUpIntroSheet(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.healing_outlined,
              size: 48,
              color: Color(0xFF9E385A),
            ),
            const SizedBox(height: 20),
            const Text(
              'Assessment Coming Soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The medical symptom assessment questionnaire and AI ultrasound pattern analysis are currently in development for a future release.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6E6E6E),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E385A),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9E385A)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    // Head (Circle with subtle hand-drawn offset style)
    canvas.drawCircle(Offset(center.dx, center.dy - 10), 22, paint);

    // Eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF9E385A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 8, center.dy - 13), 2.5, eyePaint);
    canvas.drawCircle(Offset(center.dx + 8, center.dy - 13), 2.5, eyePaint);

    // Smile (Arc)
    final smilePaint = Paint()
      ..color = const Color(0xFF9E385A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy - 14), radius: 10),
      0.3,
      pi - 0.6,
      false,
      smilePaint,
    );

    // Raised Arms (Waving stick character shape matching the mock image)
    // Left Arm (waving upward)
    final p1 = Path()
      ..moveTo(center.dx - 22, center.dy - 10)
      ..quadraticBezierTo(
        center.dx - 35,
        center.dy - 15,
        center.dx - 40,
        center.dy - 30,
      );
    canvas.drawPath(p1, paint);

    // Right Arm (waving upward)
    final p2 = Path()
      ..moveTo(center.dx + 22, center.dy - 10)
      ..quadraticBezierTo(
        center.dx + 35,
        center.dy - 15,
        center.dx + 40,
        center.dy - 30,
      );
    canvas.drawPath(p2, paint);

    // Body base/legs (simple lines matching the character)
    canvas.drawLine(
      Offset(center.dx - 10, center.dy + 12),
      Offset(center.dx - 22, center.dy + 26),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + 10, center.dy + 12),
      Offset(center.dx + 22, center.dy + 26),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
