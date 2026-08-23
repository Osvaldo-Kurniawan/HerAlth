import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../domain/models/check_up.dart';
import '../../../../domain/models/cycle.dart';
import '../../../../domain/models/user_profile.dart';
import '../../check_up/view_models/check_up_view_model.dart';
import '../../check_up/views/check_up_screen.dart';
import '../view_models/history_view_model.dart';
import 'report_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryViewModel viewModel;

  const HistoryScreen({super.key, required this.viewModel});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'All'; // 'All', 'Flagged', 'Normal'
  CycleSettings _cycleSettings = const CycleSettings(averageCycleLength: 28, averagePeriodDuration: 5);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ServiceLocator.instance.userProfileRepository.getCycleSettings();
    if (settings != null && mounted) {
      setState(() {
        _cycleSettings = settings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFFCF5F5),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF9E385A)),
            ),
          );
        }

        final checkUps = widget.viewModel.checkUps;
        final cycles = widget.viewModel.cycles;

        // Filter the checkups
        final filteredCheckUps = checkUps.where((cu) {
          final isFlagged = _isCheckUpFlagged(cu);
          if (_activeFilter == 'Flagged') return isFlagged;
          if (_activeFilter == 'Normal') return !isFlagged;
          return true;
        }).toList();

        // Calculate statistics based on real checkUps list
        final totalCheckups = checkUps.length;
        final totalFlagged = checkUps.where(_isCheckUpFlagged).length;

        // Calculate months tracked
        final uniqueMonths = checkUps.map((c) => '${c.date.year}-${c.date.month}').toSet();
        final monthsTracked = uniqueMonths.isEmpty ? 0 : uniqueMonths.length;

        return Scaffold(
          backgroundColor: const Color(0xFFFCF5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCF5F5),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C2C2C), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            scrolledUnderElevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Serif History Title
                const Text(
                  'History',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Card
                _buildOverviewCard(
                  totalCheckups: totalCheckups,
                  totalFlagged: totalFlagged,
                  monthsTracked: monthsTracked,
                  checkUps: checkUps,
                ),
                const SizedBox(height: 24),

                // Filters Selector Bar
                _buildFiltersBar(),
                const SizedBox(height: 24),

                // Timeline & Cards / Empty State
                if (filteredCheckUps.isEmpty)
                  _buildEmptyState()
                else
                  _buildTimeline(filteredCheckUps, cycles),

                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildOverviewCard({
    required int totalCheckups,
    required int totalFlagged,
    required int monthsTracked,
    required List<CheckUp> checkUps,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'OVERVIEW',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF8E8E8E),
            ),
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$totalCheckups', 'CHECK-\nUPS'),
              _buildStatDivider(),
              _buildStatItem('$totalFlagged', 'FLAGGED'),
              _buildStatDivider(),
              _buildStatItem('$monthsTracked', 'MONTHS\nTRACKED'),
            ],
          ),
          const SizedBox(height: 28),
          // Monthly activity bar chart
          _buildActivityChart(checkUps),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8E8E8E),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 48,
      color: const Color(0xFFF2ECEC),
    );
  }

  Widget _buildActivityChart(List<CheckUp> checkUps) {
    // Generate data for the last 12 months dynamically
    final now = DateTime.now();
    final List<Map<String, dynamic>> monthlyStats = [];

    for (int i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final checkUpsInMonth = checkUps.where((c) {
        return c.date.year == monthDate.year && c.date.month == monthDate.month;
      }).toList();

      final hasFlagged = checkUpsInMonth.any(_isCheckUpFlagged);
      monthlyStats.add({
        'count': checkUpsInMonth.length,
        'hasFlagged': hasFlagged,
      });
    }

    // Find maximum count for scaling
    int maxCount = 1;
    for (var m in monthlyStats) {
      if (m['count'] > maxCount) {
        maxCount = m['count'] as int;
      }
    }

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthlyStats.map((data) {
          final count = data['count'] as int;
          final hasFlagged = data['hasFlagged'] as bool;

          // Scaled height: base 6dp up to 36dp
          final double barHeight = count == 0 ? 6.0 : 6.0 + (count / maxCount) * 30.0;
          final double barOpacity = count == 0 ? 0.08 : 0.4 + (count / maxCount) * 0.6;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Orange dot above the bar if flagged checkup exists in that month
              if (hasFlagged)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE88A8A),
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 8),
              // Bar representation
              Container(
                width: 14,
                height: barHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E385A).withOpacity(barOpacity),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFCF5F5),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF2ECEC)),
      ),
      child: Row(
        children: [
          _buildFilterPill('All'),
          _buildFilterPill('Flagged'),
          _buildFilterPill('Normal'),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isActive = _activeFilter == title;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () {
            setState(() {
              _activeFilter = title;
            });
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFE57A90) : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF6E6E6E),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(List<CheckUp> checkUps, List<Cycle> cycles) {
    // Group checkups by month dynamically
    final Map<String, List<CheckUp>> grouped = {};
    for (var cu in checkUps) {
      final monthName = _getMonthNameUppercase(cu.date.month);
      if (!grouped.containsKey(monthName)) {
        grouped[monthName] = [];
      }
      grouped[monthName]!.add(cu);
    }

    return Stack(
      children: [
        // Connecting line for vertical timeline
        Positioned(
          left: 18,
          top: 10,
          bottom: 10,
          child: Container(
            width: 1,
            color: const Color(0xFFE88A8A).withOpacity(0.3),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: grouped.entries.map((entry) {
            final month = entry.key;
            final list = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Month Label
                Padding(
                  padding: const EdgeInsets.only(left: 48.0, top: 16.0, bottom: 16.0),
                  child: Text(
                    month,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                ),
                // Cards under this month
                ...list.map((cu) => _buildTimelineItem(cu, cycles)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(CheckUp checkUp, List<Cycle> cycles) {
    final isFlagged = _isCheckUpFlagged(checkUp);
    final statusColor = isFlagged ? const Color(0xFFE88A8A) : const Color(0xFF5CB85C);

    // Calculate cycle day & phase context
    int cycleDay = 1;
    String phaseName = 'Menstruation';

    Cycle? matchedCycle;
    for (var cycle in cycles) {
      if (cycle.startDate.isBefore(checkUp.date) ||
          cycle.startDate.isAtSameMomentAs(checkUp.date)) {
        matchedCycle = cycle;
        break;
      }
    }

    if (matchedCycle != null) {
      cycleDay = checkUp.date.difference(matchedCycle.startDate).inDays + 1;
      if (cycleDay <= 0) cycleDay = 1;
      final di = ServiceLocator.instance;
      final phase = di.cycleEngine.getPhaseForDay(cycleDay, _cycleSettings);
      phaseName = _getPhaseDisplayName(phase);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot marker matching status
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 14.0, right: 26.0, top: 24.0),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          // History Card content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
                  // Row with Date & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatShortDate(checkUp.date),
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFlagged ? const Color(0xFFFDF0CD) : const Color(0xFFE2F4EC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isFlagged ? 'Attention' : 'Normal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isFlagged ? const Color(0xFF9E6E10) : const Color(0xFF276749),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Symptoms listed
                  if (checkUp.symptoms.isNotEmpty) ...[
                    _buildSymptomsWrap(checkUp.symptoms),
                    const SizedBox(height: 12),
                  ],
                  // Cycle day and phase info
                  Text(
                    'Day $cycleDay · $phaseName phase',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF2ECEC), height: 1),
                  const SizedBox(height: 8),
                  // Action View Report button row
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDetailScreen(
                            checkUp: checkUp,
                            cycles: cycles,
                            settings: _cycleSettings,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'View report',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Color(0xFFC0A6A6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsWrap(List<Symptom> symptoms) {
    // Show max 3 symptoms, then "+X"
    final displaySymptoms = symptoms.take(3).toList();
    final overflowCount = symptoms.length - 3;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...displaySymptoms.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF0F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                s.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
              ),
            )),
        if (overflowCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF0F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '+$overflowCount',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9E385A)),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Column(
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 64,
            color: Color(0xFFC0A6A6),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nothing else here',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You've reached the beginning of your journal.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E8E),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Switch parent bottom nav index to Check Up tab (index 1)
              // Wait, since we are in a Navigator pushed page, if we pop, we are back on MainNavigationContainer!
              // In MainNavigationContainer, we can navigate.
              // Let's open the check up landing screen!
              final di = ServiceLocator.instance;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckUpScreen(
                    viewModel: CheckUpViewModel(di.checkUpRepository),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57A90),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Start your next check-up',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  bool _isCheckUpFlagged(CheckUp cu) {
    const attentionSymptoms = {'fatigue', 'cramps', 'bloating', 'headache', 'nausea', 'acne', 'pain', 'heavy flow'};
    return cu.symptoms.any((s) => attentionSymptoms.contains(s.name.toLowerCase()));
  }

  String _getMonthNameUppercase(int month) {
    final months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return months[month - 1];
  }

  String _formatShortDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }

  String _getPhaseDisplayName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return 'Menstruation';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulatory:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
    }
  }
}
