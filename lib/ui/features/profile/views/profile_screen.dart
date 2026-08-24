import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/models/user_profile.dart';
import '../../check_up/views/check_up_flow_screen.dart';
import '../../history/view_models/history_view_model.dart';
import '../../history/views/history_screen.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileViewModel viewModel;

  const ProfileScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final profile =
            viewModel.profile ??
            const UserProfile(
              name: 'Your profile',
              age: 0,
              height: 0,
              weight: 0,
            );
        final cycleSettings =
            viewModel.cycleSettings ??
            const CycleSettings(
              averageCycleLength: 28,
              averagePeriodDuration: 5,
            );
        final aiSettings =
            viewModel.aiSettings ??
            const AiSettings(
              analysisModel: 'Gemini',
              autoAnalyzeUltrasounds: false,
            );

        return Scaffold(
          backgroundColor: HerAlthColors.background,
          appBar: AppBar(
            backgroundColor: HerAlthColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Profile', style: HerAlthTextStyles.pageTitle),
          ),
          body: RefreshIndicator(
            color: HerAlthColors.rose,
            onRefresh: viewModel.loadProfileData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                _ProfileHeader(profile: profile),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'PERSONAL DETAILS',
                  trailing: _EditButton(
                    onPressed: () => _editProfile(context, profile),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(label: 'Name', value: profile.name),
                      _InfoRow(
                        label: 'Age',
                        value: profile.age == 0
                            ? 'Not set'
                            : '${profile.age} years',
                      ),
                      _InfoRow(
                        label: 'Height',
                        value: profile.height == 0
                            ? 'Not set'
                            : '${profile.height.toStringAsFixed(0)} cm',
                      ),
                      _InfoRow(
                        label: 'Weight',
                        value: profile.weight == 0
                            ? 'Not set'
                            : '${profile.weight.toStringAsFixed(1)} kg',
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'CHECK-UP ACTIVITY',
                  trailing: _EditButton(
                    label: 'HISTORY',
                    onPressed: () => _openHistory(context),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActivityMetric(
                          value: '${viewModel.checkUpCount}',
                          label: 'CHECK-UPS SAVED',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 46,
                        color: HerAlthColors.divider,
                      ),
                      Expanded(
                        child: _ActivityMetric(
                          value: viewModel.latestCheckUpDate == null
                              ? '—'
                              : _formatDate(viewModel.latestCheckUpDate!),
                          label: 'LATEST ENTRY',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'CYCLE SETTINGS',
                  trailing: _EditButton(
                    onPressed: () => _editCycleSettings(context, cycleSettings),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        label: 'Average cycle',
                        value: '${cycleSettings.averageCycleLength} days',
                      ),
                      _InfoRow(
                        label: 'Period duration',
                        value: '${cycleSettings.averagePeriodDuration} days',
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'AI & PRIVACY',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: 'Analysis engine',
                        value: AppConfig.geminiModel,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: HerAlthColors.rose,
                          title: const Text(
                            'Use ultrasound context',
                            style: HerAlthTextStyles.cardTitle,
                          ),
                          subtitle: const Text(
                            'Attach an ultrasound only when you choose to.',
                            style: HerAlthTextStyles.cardBody,
                          ),
                          value: aiSettings.autoAnalyzeUltrasounds,
                          onChanged: (value) => viewModel.updateAiSettings(
                            aiSettings.copyWith(autoAnalyzeUltrasounds: value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _LocalStorageNote(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'LOCAL DATA',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your profile, cycle logs, symptoms, and AI reports are stored in the local HerAlth database on this device.',
                        style: HerAlthTextStyles.body,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _confirmClearData(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: HerAlthColors.rose,
                            side: const BorderSide(
                              color: HerAlthColors.softBorder,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Delete local data'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (viewModel.isLoading) ...[
                  const SizedBox(height: 18),
                  const LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: HerAlthColors.softBorder,
                    valueColor: AlwaysStoppedAnimation(HerAlthColors.rose),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editProfile(BuildContext context, UserProfile profile) async {
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(
      text: profile.age == 0 ? '' : '${profile.age}',
    );
    final heightController = TextEditingController(
      text: profile.height == 0 ? '' : profile.height.toStringAsFixed(0),
    );
    final weightController = TextEditingController(
      text: profile.weight == 0 ? '' : profile.weight.toStringAsFixed(1),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit personal details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(controller: nameController, label: 'Name'),
              _DialogField(
                controller: ageController,
                label: 'Age',
                keyboardType: TextInputType.number,
              ),
              _DialogField(
                controller: heightController,
                label: 'Height (cm)',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              _DialogField(
                controller: weightController,
                label: 'Weight (kg)',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) {
      nameController.dispose();
      ageController.dispose();
      heightController.dispose();
      weightController.dispose();
      return;
    }
    await viewModel.updateProfile(
      UserProfile(
        name: nameController.text.trim().isEmpty
            ? profile.name
            : nameController.text.trim(),
        age: int.tryParse(ageController.text) ?? profile.age,
        height: double.tryParse(heightController.text) ?? profile.height,
        weight: double.tryParse(weightController.text) ?? profile.weight,
      ),
    );
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
  }

  Future<void> _editCycleSettings(
    BuildContext context,
    CycleSettings settings,
  ) async {
    final cycleController = TextEditingController(
      text: '${settings.averageCycleLength}',
    );
    final periodController = TextEditingController(
      text: '${settings.averagePeriodDuration}',
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit cycle settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(
              controller: cycleController,
              label: 'Average cycle (days)',
              keyboardType: TextInputType.number,
            ),
            _DialogField(
              controller: periodController,
              label: 'Period duration (days)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) {
      cycleController.dispose();
      periodController.dispose();
      return;
    }
    final cycleLength = int.tryParse(cycleController.text);
    final periodDuration = int.tryParse(periodController.text);
    if (cycleLength == null || periodDuration == null) {
      cycleController.dispose();
      periodController.dispose();
      return;
    }
    await viewModel.updateCycleSettings(
      CycleSettings(
        averageCycleLength: cycleLength.clamp(15, 90),
        averagePeriodDuration: periodDuration.clamp(1, 14),
      ),
    );
    cycleController.dispose();
    periodController.dispose();
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete local data?'),
        content: const Text(
          'This removes your profile, cycle logs, check-ups, and saved AI reports from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await viewModel.clearAllData();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local HerAlth data deleted.')),
      );
    }
  }

  void _openHistory(BuildContext context) {
    final di = ServiceLocator.instance;
    final historyViewModel = HistoryViewModel(
      di.cycleRepository,
      di.checkUpRepository,
      di.reportRepository,
      userProfileRepository: di.userProfileRepository,
      cycleEngine: di.cycleEngine,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryScreen(viewModel: historyViewModel),
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

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final initial = profile.name.trim().isEmpty
        ? '?'
        : profile.name.trim()[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HerAlthColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [HerAlthShadows.soft],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: HerAlthColors.palePink,
            child: Text(
              initial,
              style: HerAlthTextStyles.pageTitle.copyWith(
                fontSize: 28,
                color: HerAlthColors.rose,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: HerAlthTextStyles.cardTitle),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: HerAlthColors.secondary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Private on this device',
                      style: HerAlthTextStyles.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
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
              Text(title, style: HerAlthTextStyles.section),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _EditButton({required this.onPressed, this.label = 'EDIT'});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: HerAlthColors.rose),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;

  const _InfoRow({required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: last
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: HerAlthColors.divider)),
            ),
      child: Row(
        children: [
          Text(label, style: HerAlthTextStyles.body.copyWith(fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, color: HerAlthColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityMetric extends StatelessWidget {
  final String value;
  final String label;

  const _ActivityMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: HerAlthTextStyles.pageTitle.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: HerAlthTextStyles.section.copyWith(
            fontSize: 10,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _LocalStorageNote extends StatelessWidget {
  const _LocalStorageNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HerAlthColors.palePink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, size: 17, color: HerAlthColors.rose),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Your check-up inputs and reports stay in the local database. The AI request uses only the data you submit for that analysis.',
              style: HerAlthTextStyles.small,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  const _DialogField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
