import 'package:flutter/material.dart';

import 'dart:math';

import '../../../../core/di/service_locator.dart';
import '../../home/view_models/home_view_model.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../../profile/views/profile_screen.dart';
import '../../history/view_models/history_view_model.dart';
import '../../history/views/history_screen.dart';
import '../../check_up/views/check_up_flow_screen.dart'
    show HerAlthColors, HerAlthTextStyles;
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

        final today = DateTime.now();
        final alreadyLoggedStartToday =
            cycleHistory.isNotEmpty &&
            cycleHistory.first.startDate.year == today.year &&
            cycleHistory.first.startDate.month == today.month &&
            cycleHistory.first.startDate.day == today.day;
        final alreadyLoggedEndToday =
            cycleHistory.isNotEmpty &&
            cycleHistory.first.endDate != null &&
            cycleHistory.first.endDate!.year == today.year &&
            cycleHistory.first.endDate!.month == today.month &&
            cycleHistory.first.endDate!.day == today.day;

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
          if (currentDay <= 0) {
            currentDay = 1; // Safeguard if user picks future date
          }

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
            title: const Text(
              'HerAlth',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF9E385A),
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
                    di.cycleRepository,
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

                  // Log Cycle Dates
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9E385A).withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LOG CYCLE DATES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Color(0xFF8E8E8E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: alreadyLoggedStartToday
                                    ? null
                                    : () => _selectAndLogPeriodStart(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9E385A),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.water_drop_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  alreadyLoggedStartToday
                                      ? 'Logged (Log tomorrow)'
                                      : 'Log Start',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            if (cycleHistory.isNotEmpty &&
                                (cycleHistory.first.endDate == null ||
                                    alreadyLoggedEndToday)) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: alreadyLoggedEndToday
                                      ? null
                                      : () => _selectAndLogPeriodEnd(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF9E385A),
                                    side: const BorderSide(
                                      color: Color(0xFF9E385A),
                                    ),
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.event_available_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    alreadyLoggedEndToday
                                        ? 'Logged today'
                                        : 'Log End',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cycle Summary Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9E385A).withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CYCLE SUMMARY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Color(0xFF8E8E8E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryStat(
                              label: 'Average Cycle',
                              value: settings != null
                                  ? '${settings.averageCycleLength} days'
                                  : '28 days',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: const Color(0xFFF2ECEC),
                            ),
                            _buildSummaryStat(
                              label: 'Average Period',
                              value: settings != null
                                  ? '${settings.averagePeriodDuration} days'
                                  : '5 days',
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: const Color(0xFFF2ECEC),
                            ),
                            _buildSummaryStat(
                              label: 'Cycles Logged',
                              value: '${cycleHistory.length}',
                            ),
                          ],
                        ),
                        if (cycleHistory.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFF2ECEC), height: 1),
                          const SizedBox(height: 12),
                          const Text(
                            'RECENT CYCLES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Color(0xFF8E8E8E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: min(cycleHistory.length, 3),
                            separatorBuilder: (context, index) => const Divider(
                              color: Color(0xFFFCF5F5),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final cycle = cycleHistory[index];
                              final isCurrent =
                                  index == 0 && cycle.endDate == null;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cycle.endDate != null
                                              ? '${_formatDateShort(cycle.startDate)} - ${_formatDateShort(cycle.endDate!)}'
                                              : '${_formatDateShort(cycle.startDate)} - Present',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2C2C2C),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isCurrent
                                              ? 'Active Cycle'
                                              : 'Flow: ${cycle.flowIntensity}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF8E8E8E),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? const Color(0xFFFCF0F0)
                                            : const Color(0xFFF2ECEC),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        cycle.cycleLength != null
                                            ? '${cycle.cycleLength} days'
                                            : 'Day ${DateTime.now().difference(cycle.startDate).inDays + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent
                                              ? const Color(0xFF9E385A)
                                              : const Color(0xFF6E6E6E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'No cycle history found.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8E8E8E),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // End of Cycle Check-In — distinct from the regular
                  // "Today is the day" action, surfaced only once the
                  // current cycle has reached its predicted length.
                  if (widget.viewModel.isEndOfCycleCheckInDue) ...[
                    _EndOfCycleCheckInCard(
                      onCheckIn: () => _showEndOfCycleCheckIn(context),
                    ),
                    const SizedBox(height: 20),
                  ],

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

  void _showEndOfCycleCheckIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Log your cycle\'s end date',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: HerAlthColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Save today as the end date for this cycle so HerAlth can keep your history and predictions accurate. This is separate from logging a new period start date.',
                  style: HerAlthTextStyles.body,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await widget.viewModel.completeEndOfCycleCheckIn(
                      DateTime.now(),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('End date saved for this cycle.'),
                          backgroundColor: HerAlthColors.rose,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HerAlthColors.rose,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Save end date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text(
                    'Not yet',
                    style: TextStyle(color: HerAlthColors.muted),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  String _formatDateShort(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Future<void> _selectAndLogPeriodStart(BuildContext context) async {
    final today = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today.subtract(const Duration(days: 90)),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9E385A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2C2C2C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      await widget.viewModel.logPeriodStart(pickedDate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Start date saved — ${_formatDateShort(pickedDate)} logged as the first day of your period.',
            ),
            backgroundColor: const Color(0xFF9E385A),
          ),
        );
      }
    }
  }

  Future<void> _selectAndLogPeriodEnd(BuildContext context) async {
    if (widget.viewModel.cycleHistory.isEmpty) return;
    final lastCycle = widget.viewModel.cycleHistory.first;
    final today = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: lastCycle.startDate,
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9E385A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2C2C2C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      await widget.viewModel.completeEndOfCycleCheckIn(pickedDate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('End date saved: ${_formatDateShort(pickedDate)}.'),
            backgroundColor: const Color(0xFF9E385A),
          ),
        );
      }
    }
  }

  Widget _buildSummaryStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E8E)),
        ),
      ],
    );
  }
}

class _EndOfCycleCheckInCard extends StatelessWidget {
  final VoidCallback onCheckIn;

  const _EndOfCycleCheckInCard({required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: HerAlthColors.rose.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: HerAlthColors.palePink,
            child: Icon(
              Icons.event_available_rounded,
              color: HerAlthColors.rose,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End of cycle reached',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: HerAlthColors.ink,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Save this cycle\'s end date to close it out.',
                  style: HerAlthTextStyles.cardBody,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onCheckIn,
            style: OutlinedButton.styleFrom(
              foregroundColor: HerAlthColors.rose,
              side: const BorderSide(color: HerAlthColors.rose),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Log end date'),
          ),
        ],
      ),
    );
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
