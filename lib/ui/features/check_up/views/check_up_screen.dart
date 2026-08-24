import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../history/view_models/history_view_model.dart';
import '../../history/views/history_screen.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../../profile/views/profile_screen.dart';
import '../view_models/check_up_view_model.dart';
import 'check_up_flow_screen.dart';

class CheckUpScreen extends StatelessWidget {
  final CheckUpViewModel viewModel;

  const CheckUpScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final di = ServiceLocator.instance;
    return Scaffold(
      backgroundColor: HerAlthColors.background,
      appBar: AppBar(
        backgroundColor: HerAlthColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('HerAlth', style: HerAlthTextStyles.brand),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(
              Icons.access_time_rounded,
              color: HerAlthColors.ink,
              size: 26,
            ),
            onPressed: () {
              final historyVM = HistoryViewModel(
                di.cycleRepository,
                di.checkUpRepository,
                di.reportRepository,
                userProfileRepository: di.userProfileRepository,
                cycleEngine: di.cycleEngine,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(viewModel: historyVM),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(
              Icons.account_circle_outlined,
              color: HerAlthColors.ink,
              size: 26,
            ),
            onPressed: () {
              final profileVM = ProfileViewModel(
                di.userProfileRepository,
                di.backupRepository,
                di.cycleRepository,
                checkUpRepository: di.checkUpRepository,
              )..loadProfileData();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(viewModel: profileVM),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Something feels\ndifferent?',
                          style: HerAlthTextStyles.hero,
                        ),
                      ),
                      SizedBox(
                        width: 92,
                        height: 92,
                        child: CustomPaint(painter: CharacterPainter()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'HerAlth reviews your logged symptoms, cycle trends, and optional ultrasound data to surface patterns worth discussing with your doctor.',
                    style: HerAlthTextStyles.body,
                  ),
                  const SizedBox(height: 34),
                  const _LandingStep(
                    number: '01',
                    title: 'Symptoms',
                    subtitle: "Select what you're noticing now.",
                  ),
                  const SizedBox(height: 14),
                  const _LandingStep(
                    number: '02',
                    title: 'Ultrasound (optional)',
                    subtitle: 'Upload images for pattern analysis.',
                  ),
                  const SizedBox(height: 14),
                  const _LandingStep(
                    number: '03',
                    title: 'Review & analyze',
                    subtitle: 'Private summary of potential patterns.',
                  ),
                  const SizedBox(height: 30),
                  const HerAlthDisclaimerBanner(),
                  const SizedBox(height: 30),
                  HerAlthPrimaryButton(
                    label: 'I want to check mine',
                    onPressed: () {
                      viewModel.resetFlow();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/symptoms'),
                          builder: (_) =>
                              SymptomSelectionScreen(viewModel: viewModel),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LandingStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _LandingStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: HerAlthColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: HerAlthColors.softBorder),
          ),
          alignment: Alignment.center,
          child: Text(number, style: HerAlthTextStyles.stepNumber),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: HerAlthColors.card,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [HerAlthShadows.soft],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: HerAlthTextStyles.cardTitle),
                const SizedBox(height: 3),
                Text(subtitle, style: HerAlthTextStyles.cardBody),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 4);
    final outline = Paint()
      ..color = HerAlthColors.pink
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = HerAlthColors.pink
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - 15), 24, outline);
    canvas.drawCircle(Offset(center.dx - 8, center.dy - 18), 2, fill);
    canvas.drawCircle(Offset(center.dx + 8, center.dy - 18), 2, fill);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy - 18), radius: 9),
      0.2,
      pi - 0.4,
      false,
      outline,
    );
    final leftArm = Path()
      ..moveTo(center.dx - 24, center.dy - 14)
      ..quadraticBezierTo(
        center.dx - 40,
        center.dy - 18,
        center.dx - 40,
        center.dy - 35,
      );
    final rightArm = Path()
      ..moveTo(center.dx + 24, center.dy - 14)
      ..quadraticBezierTo(
        center.dx + 40,
        center.dy - 18,
        center.dx + 40,
        center.dy - 35,
      );
    canvas.drawPath(leftArm, outline);
    canvas.drawPath(rightArm, outline);
    canvas.drawLine(
      Offset(center.dx - 8, center.dy + 8),
      Offset(center.dx - 19, center.dy + 25),
      outline,
    );
    canvas.drawLine(
      Offset(center.dx + 8, center.dy + 8),
      Offset(center.dx + 19, center.dy + 25),
      outline,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
