import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../domain/models/check_up.dart';
import '../../../../domain/models/check_up_analysis.dart';
import '../../check_up/views/check_up_flow_screen.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../../profile/views/profile_screen.dart';
import '../view_models/history_view_model.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
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
  }
}
