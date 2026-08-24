import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../domain/models/check_up.dart';
import '../../../../domain/models/check_up_analysis.dart';
import '../../check_up/views/check_up_flow_screen.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../../profile/views/profile_screen.dart';
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
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(widget.viewModel.loadHistory);
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
          backgroundColor: HerAlthColors.background,
          appBar: AppBar(
            backgroundColor: HerAlthColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('History', style: HerAlthTextStyles.pageTitle),
            actions: [
              IconButton(
                tooltip: 'Profile',
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: HerAlthColors.ink,
                  size: 26,
                ),
                onPressed: () => _openProfile(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            color: HerAlthColors.rose,
            onRefresh: widget.viewModel.loadHistory,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                _OverviewCard(viewModel: widget.viewModel),
                const SizedBox(height: 20),
                _FilterBar(
                  selected: widget.viewModel.filter,
                  onChanged: widget.viewModel.setFilter,
                ),
                const SizedBox(height: 28),
                if (widget.viewModel.isLoading &&
                    widget.viewModel.checkUps.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: HerAlthColors.rose,
                      ),
                    ),
                  )
                else if (widget.viewModel.filteredCheckUps.isEmpty)
                  const _EmptyHistory()
                else
                  ..._buildMonthGroups(widget.viewModel.filteredCheckUps),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMonthGroups(List<CheckUp> checkUps) {
    final grouped = <String, List<CheckUp>>{};
    for (final checkUp in checkUps) {
      grouped.putIfAbsent(_monthKey(checkUp.date), () => []).add(checkUp);
    }

    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 12),
          child: Text(entry.key, style: HerAlthTextStyles.section),
        ),
      );
      widgets.add(
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: HerAlthColors.softBorder, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: entry.value
                  .map(
                    (checkUp) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HistoryCard(
                        checkUp: checkUp,
                        flagged: widget.viewModel.isFlagged(checkUp),
                        cycleContext: widget.viewModel.cycleContext,
                        onViewReport: () => _viewReport(context, checkUp),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );
    }
    widgets.add(const SizedBox(height: 32));
    widgets.add(const _JournalEnd());
    return widgets;
  }

  String _monthKey(DateTime date) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _viewReport(BuildContext context, CheckUp checkUp) async {
    final analysis = widget.viewModel.analysisFor(checkUp.id);
    if (analysis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This check-up does not have a saved AI report yet.'),
        ),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisResultsScreen(
          analysis: analysis,
          cycleContext: widget.viewModel.cycleContext,
          closeToRoot: false,
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    final di = ServiceLocator.instance;
    final profileViewModel = ProfileViewModel(
      di.userProfileRepository,
      di.backupRepository,
      checkUpRepository: di.checkUpRepository,
    )..loadProfileData();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(viewModel: profileViewModel),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final HistoryViewModel viewModel;

  const _OverviewCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OVERVIEW', style: HerAlthTextStyles.section),
          const SizedBox(height: 18),
          Row(
            children: [
              _OverviewMetric(
                value: '${viewModel.checkUps.length}',
                label: 'CHECK-UPS',
              ),
              const _MetricDivider(),
              _OverviewMetric(
                value: '${viewModel.flaggedCount}',
                label: 'FLAGGED',
              ),
              const _MetricDivider(),
              _OverviewMetric(
                value: '${viewModel.monthsTracked}',
                label: 'MONTHS\nTRACKED',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HistoryBars(checkUps: viewModel.checkUps),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final String value;
  final String label;

  const _OverviewMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
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
            style: HerAlthTextStyles.pageTitle.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: HerAlthTextStyles.section.copyWith(
              fontSize: 11,
              letterSpacing: 0.8,
              color: HerAlthColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: HerAlthColors.softBorder);
  }
}

class _HistoryBars extends StatelessWidget {
  final List<CheckUp> checkUps;

  const _HistoryBars({required this.checkUps});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final checkUp in checkUps) {
      final key = '${checkUp.date.year}-${checkUp.date.month}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final values = counts.values.take(7).toList().reversed.toList();
    final bars = values.isEmpty ? <int>[0, 0, 0, 0, 0, 0] : values;
    final maxValue = bars.fold<int>(
      1,
      (max, value) => value > max ? value : max,
    );

    return SizedBox(
      height: 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: bars
            .map(
              (value) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 22,
                height: value == 0 ? 10 : 10 + (value / maxValue * 28),
                decoration: BoxDecoration(
                  color: value == 0
                      ? HerAlthColors.palePink
                      : HerAlthColors.pink,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final HistoryFilter selected;
  final ValueChanged<HistoryFilter> onChanged;

  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Row(
        children: [
          _FilterButton(
            label: 'All',
            selected: selected == HistoryFilter.all,
            onTap: () => onChanged(HistoryFilter.all),
          ),
          _FilterButton(
            label: 'Flagged',
            selected: selected == HistoryFilter.flagged,
            onTap: () => onChanged(HistoryFilter.flagged),
          ),
          _FilterButton(
            label: 'Normal',
            selected: selected == HistoryFilter.normal,
            onTap: () => onChanged(HistoryFilter.normal),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? HerAlthColors.pink : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? Colors.white : HerAlthColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CheckUp checkUp;
  final bool flagged;
  final CycleContextSnapshot cycleContext;
  final VoidCallback onViewReport;

  const _HistoryCard({
    required this.checkUp,
    required this.flagged,
    required this.cycleContext,
    required this.onViewReport,
  });

  @override
  Widget build(BuildContext context) {
    final visibleSymptoms = checkUp.symptoms.take(3).toList();
    final remaining = checkUp.symptoms.length - visibleSymptoms.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatDate(checkUp.date),
                style: HerAlthTextStyles.cardTitle,
              ),
              const Spacer(),
              _StatusPill(flagged: flagged),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...visibleSymptoms.map(
                (symptom) => _SymptomPill(label: symptom.name),
              ),
              if (remaining > 0) _SymptomPill(label: '+$remaining'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Day ${cycleContext.cycleDay} · ${cycleContext.phase} phase',
            style: HerAlthTextStyles.body.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Divider(color: HerAlthColors.divider, height: 1),
          TextButton(
            onPressed: onViewReport,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(top: 12),
              foregroundColor: HerAlthColors.ink,
            ),
            child: const Row(
              children: [
                Text('View report', style: HerAlthTextStyles.cardTitle),
                Spacer(),
                Icon(Icons.chevron_right_rounded, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
}

class _StatusPill extends StatelessWidget {
  final bool flagged;

  const _StatusPill({required this.flagged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: flagged ? const Color(0xFFFFF3DF) : const Color(0xFFEAF5EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        flagged ? 'Attention' : 'Normal',
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.4,
          color: flagged ? const Color(0xFFE49A35) : const Color(0xFF6AA586),
        ),
      ),
    );
  }
}

class _SymptomPill extends StatelessWidget {
  final String label;

  const _SymptomPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: HerAlthColors.palePink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Icon(Icons.access_time_rounded, color: HerAlthColors.muted, size: 42),
          SizedBox(height: 18),
          Text('Nothing else here', style: HerAlthTextStyles.pageTitle),
          SizedBox(height: 8),
          Text(
            "You've reached the beginning of your journal.",
            textAlign: TextAlign.center,
            style: HerAlthTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _JournalEnd extends StatelessWidget {
  const _JournalEnd();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.access_time_rounded, color: HerAlthColors.muted, size: 40),
        SizedBox(height: 16),
        Text('Nothing else here', style: HerAlthTextStyles.pageTitle),
        SizedBox(height: 8),
        Text(
          "You've reached the beginning of your journal.",
          textAlign: TextAlign.center,
          style: HerAlthTextStyles.body,
        ),
        SizedBox(height: 20),
      ],
    );
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
