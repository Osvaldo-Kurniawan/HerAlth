import 'package:flutter/material.dart';

import 'dart:math';

import '../../../../core/di/service_locator.dart';
import '../../home/view_models/home_view_model.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../../profile/views/profile_screen.dart';
import '../../history/view_models/history_view_model.dart';
import '../../history/views/history_screen.dart';
import '../../../../domain/models/cycle.dart';
import '../../../../domain/models/user_profile.dart';

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final settings = widget.viewModel.settings;
        final cycleHistory = widget.viewModel.cycleHistory;

        if (widget.viewModel.isLoading && cycleHistory.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFFCF5F5),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF9E385A)),
            ),
          );
        }

        // Calculate current cycle metrics
        int currentDay = 1;
        CyclePhase currentPhase = CyclePhase.menstruation;
        String phaseName = "Menstruation";
        double progress = 0.0;
        int daysUntilNext = 28;
        int cycleLength = settings?.averageCycleLength ?? 28;
        int periodDuration = settings?.averagePeriodDuration ?? 5;

        if (cycleHistory.isNotEmpty) {
          final lastCycle = cycleHistory.first;
          final today = DateTime.now();
          // Reset time parts to get accurate date difference
          final todayDate = DateTime(today.year, today.month, today.day);
          final start = DateTime(
            lastCycle.startDate.year,
            lastCycle.startDate.month,
            lastCycle.startDate.day,
          );
          final diff = todayDate.difference(start).inDays;

          currentDay = diff + 1;
          if (currentDay <= 0)
            currentDay = 1; // Safeguard if user picks future date

          progress = (currentDay / cycleLength).clamp(0.0, 1.0);

          // Get Phase
          final di = ServiceLocator.instance;
          currentPhase = di.cycleEngine.getPhaseForDay(
            currentDay,
            settings ??
                const CycleSettings(
                  averageCycleLength: 28,
                  averagePeriodDuration: 5,
                ),
          );
          phaseName = _getPhaseDisplayName(currentPhase);

          final nextPeriod = lastCycle.startDate.add(
            Duration(days: cycleLength),
          );
          daysUntilNext = nextPeriod.difference(todayDate).inDays;
        }

        // Insights
        final di = ServiceLocator.instance;
        final insights = di.cycleEngine.generateInsights(
          cycleHistory: cycleHistory,
          settings:
              settings ??
              const CycleSettings(
                averageCycleLength: 28,
                averagePeriodDuration: 5,
              ),
        );
        final currentInsight = insights.isNotEmpty ? insights.first : null;

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
                    userProfileRepository: di.userProfileRepository,
                    cycleEngine: di.cycleEngine,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(viewModel: historyVM),
                    ),
                  ).then((_) => widget.viewModel.loadDashboard());
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
                    checkUpRepository: di.checkUpRepository,
                  );
                  profileVM.loadProfileData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(viewModel: profileVM),
                    ),
                  ).then((_) => widget.viewModel.loadDashboard());
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            color: const Color(0xFF9E385A),
            onRefresh: widget.viewModel.loadDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Circular Visual Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 36.0,
                      horizontal: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9E385A).withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'CURRENT CYCLE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Color(0xFF8E8E8E),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Animated Circle
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 1400),
                          curve: Curves.easeOutCubic,
                          builder: (context, animValue, child) {
                            return CustomPaint(
                              painter: CycleCirclePainter(
                                progress: animValue,
                                color: const Color(0xFFE88A8A),
                              ),
                              child: Container(
                                width: 220,
                                height: 220,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Day',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF6E6E6E),
                                      ),
                                    ),
                                    Text(
                                      '$currentDay',
                                      style: const TextStyle(
                                        fontSize: 64,
                                        fontFamily: 'serif',
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C2C2C),
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      phaseName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9E385A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 36),
                        const Divider(color: Color(0xFFF2ECEC), height: 1),
                        const SizedBox(height: 20),
                        // Metrics Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMetricItem(
                              'Next period',
                              daysUntilNext > 0
                                  ? 'in $daysUntilNext days'
                                  : daysUntilNext == 0
                                  ? 'Today'
                                  : 'Late by ${-daysUntilNext}d',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: const Color(0xFFF2ECEC),
                            ),
                            _buildMetricItem('Cycle length', '${cycleLength}d'),
                            Container(
                              width: 1,
                              height: 32,
                              color: const Color(0xFFF2ECEC),
                            ),
                            _buildMetricItem(
                              currentPhase == CyclePhase.luteal
                                  ? 'Luteal'
                                  : 'Period',
                              currentPhase == CyclePhase.luteal
                                  ? '14d'
                                  : '${periodDuration}d',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Today is the Day Action Button
                  ElevatedButton(
                    onPressed: () async {
                      final today = DateTime.now();
                      await widget.viewModel.logPeriodStart(today);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Period logged for today successfully!',
                            ),
                            backgroundColor: Color(0xFF9E385A),
                          ),
                        );
                      }
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Today is the day',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Insight Card
                  if (currentInsight != null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCF0F0),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFE88A8A).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF9E385A),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'INSIGHT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF9E385A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"${currentInsight.description}"',
                            style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF2C2C2C),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 100,
                  ), // Extra space to not get hidden by bottom navigation
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E8E)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  String _getPhaseDisplayName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return 'Menstruation phase';
      case CyclePhase.follicular:
        return 'Follicular phase';
      case CyclePhase.ovulatory:
        return 'Ovulation phase';
      case CyclePhase.luteal:
        return 'Luteal phase';
    }
  }
}

class CycleCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  CycleCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Draw background track
    final trackPaint = Paint()
      ..color = const Color(0xFFF2ECEC)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - 4, trackPaint);

    // Draw active progress arc
    final activePaint = Paint()
      ..color = const Color(0xFF9E385A)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -pi / 2, // Start at 12 o'clock
      sweepAngle,
      false,
      activePaint,
    );

    // Draw indicators at 12, 3, 6, 9 o'clock
    final indicatorPaint = Paint()
      ..color = const Color(0xFF9E385A).withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final indicatorLength = 6.0;

    // Top
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 8),
      Offset(center.dx, center.dy - radius + 8 + indicatorLength),
      indicatorPaint,
    );
    // Bottom
    canvas.drawLine(
      Offset(center.dx, center.dy + radius - 8),
      Offset(center.dx, center.dy + radius - 8 - indicatorLength),
      indicatorPaint,
    );
    // Left
    canvas.drawLine(
      Offset(center.dx - radius + 8, center.dy),
      Offset(center.dx - radius + 8 + indicatorLength, center.dy),
      indicatorPaint,
    );
    // Right
    canvas.drawLine(
      Offset(center.dx + radius - 8, center.dy),
      Offset(center.dx + radius - 8 - indicatorLength, center.dy),
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CycleCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
