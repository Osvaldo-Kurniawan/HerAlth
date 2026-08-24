import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../core/error_state_widget.dart';
import '../../history/view_models/history_view_model.dart';
import '../../history/views/history_screen.dart';
import '../../onboarding/view_models/onboarding_view_model.dart';
import '../../onboarding/views/onboarding_screen.dart';
import '../../home/views/main_navigation_container.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileViewModel viewModel;

  const ProfileScreen({super.key, required this.viewModel});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.viewModel.isLoading && !widget.viewModel.hasLoaded) {
      widget.viewModel.loadProfileData();
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

        if (widget.viewModel.errorMessage != null) {
          return Scaffold(
            body: ErrorStateWidget(
              errorMessage: widget.viewModel.errorMessage!,
              onRetry: () => widget.viewModel.loadProfileData(),
              onGoBack: () => Navigator.pop(context),
            ),
          );
        }

        final profile = widget.viewModel.profile;
        final settings = widget.viewModel.cycleSettings;
        final reminders = widget.viewModel.reminderSettings;

        final nicknameDisplay = profile?.name.isNotEmpty == true
            ? profile!.name
            : 'Not set';
        final cycleLengthDisplay = settings != null
            ? '${settings.averageCycleLength} days'
            : '28 days';
        final periodLengthDisplay = settings != null
            ? '${settings.averagePeriodDuration} days'
            : '5 days';

        String lastPeriodDisplay = 'Not set';
        if (widget.viewModel.lastPeriodDate != null) {
          final date = widget.viewModel.lastPeriodDate!;
          lastPeriodDisplay = _formatDate(date);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFCF5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCF5F5),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2C2C2C),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            scrolledUnderElevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Serif Profile Title
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 24),

                // Top Device/Account Card
                _buildDeviceAccountCard(
                  storageMb: widget.viewModel.storageSizeMb,
                  nickname: nicknameDisplay,
                  onTapNickname: _showEditNicknameDialog,
                ),
                const SizedBox(height: 24),

                // Check-up Activity Section
                _buildSectionHeader('CHECK-UP ACTIVITY'),
                _buildCardContainer([
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActivityMetric(
                            value: '${widget.viewModel.checkUpCount}',
                            label: 'CHECK-UPS SAVED',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: const Color(0xFFF2ECEC),
                        ),
                        Expanded(
                          child: _buildActivityMetric(
                            value: widget.viewModel.latestCheckUpDate == null
                                ? '—'
                                : _formatDate(
                                    widget.viewModel.latestCheckUpDate!,
                                  ),
                            label: 'LATEST ENTRY',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _CustomDivider(),
                  _buildRowItem(
                    icon: Icons.history_rounded,
                    title: 'View check-up history',
                    onTap: _openHistory,
                  ),
                ]),
                const SizedBox(height: 24),

                // Cycle Section
                _buildSectionHeader('CYCLE'),
                _buildCardContainer([
                  _buildRowItem(
                    icon: Icons.water_drop_outlined,
                    title: 'Average cycle length',
                    trailingText: cycleLengthDisplay,
                    onTap: _showCycleLengthPicker,
                  ),
                  const _CustomDivider(),
                  _buildRowItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'Period length',
                    trailingText: periodLengthDisplay,
                    onTap: _showPeriodDurationPicker,
                  ),
                  const _CustomDivider(),
                  _buildRowItem(
                    icon: Icons.history_rounded,
                    title: 'Last period date',
                    trailingText: lastPeriodDisplay,
                    onTap: _showLastPeriodDatePicker,
                  ),
                  const _CustomDivider(),
                  _buildToggleRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Cycle reminders',
                    value: reminders?.cycleRemindersEnabled ?? true,
                    onChanged: (val) {
                      if (reminders != null) {
                        widget.viewModel.updateReminderSettings(
                          reminders.copyWith(cycleRemindersEnabled: val),
                        );
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 24),

                // Reminders Section
                _buildSectionHeader('REMINDERS'),
                _buildCardContainer([
                  _buildToggleRow(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'Daily check-in',
                    value: reminders?.checkUpReminderEnabled ?? true,
                    onChanged: (val) {
                      if (reminders != null) {
                        widget.viewModel.updateReminderSettings(
                          reminders.copyWith(checkUpReminderEnabled: val),
                        );
                      }
                    },
                  ),
                  const _CustomDivider(),
                  _buildToggleRow(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Fertile window',
                    value: reminders?.fertilityReminderEnabled ?? true,
                    onChanged: (val) {
                      if (reminders != null) {
                        widget.viewModel.updateReminderSettings(
                          reminders.copyWith(fertilityReminderEnabled: val),
                        );
                      }
                    },
                  ),
                  const _CustomDivider(),
                  _buildToggleRow(
                    icon: Icons.trending_up_rounded,
                    title: 'Period forecast',
                    value: reminders?.periodReminderEnabled ?? true,
                    onChanged: (val) {
                      if (reminders != null) {
                        widget.viewModel.updateReminderSettings(
                          reminders.copyWith(periodReminderEnabled: val),
                        );
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    'Local notifications, scheduled on your phone.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8E8E8E)),
                  ),
                ),
                const SizedBox(height: 24),

                // Your Data Section
                _buildSectionHeader('LOCAL DATA'),
                _buildCardContainer([
                  _buildRowItem(
                    icon: Icons.file_upload_outlined,
                    title: 'Export backup file',
                    onTap: _exportBackupFlow,
                  ),
                  const _CustomDivider(),
                  _buildRowItem(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Clear check-up history',
                    onTap: _showClearHistoryConfirmation,
                  ),
                  const _CustomDivider(),
                  _buildRowItem(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete all data',
                    titleColor: const Color(0xFFC95B6F),
                    iconColor: const Color(0xFFC95B6F),
                    showChevron: false,
                    onTap: _showDeleteAllDataConfirmation,
                  ),
                ]),
                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader('ABOUT'),
                _buildCardContainer([
                  _buildRowItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy',
                    onTap: _navigateToPrivacyScreen,
                  ),
                  const _CustomDivider(),
                  _buildRowItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    trailingText: 'v1.0.0',
                    showChevron: false,
                    onTap: null,
                  ),
                ]),
                const SizedBox(height: 48),

                // Footer Disclaimer
                const Center(
                  child: Text(
                    'HerAlth v1.0.0 · Offline app\nNot a medical device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E8E),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Color(0xFF8E8E8E),
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildActivityMetric({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 24,
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
            letterSpacing: 0.7,
            color: Color(0xFF8E8E8E),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceAccountCard({
    required double storageMb,
    required String nickname,
    required VoidCallback onTapNickname,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E385A).withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phonelink_lock_rounded,
                  size: 20,
                  color: Color(0xFF9E385A),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All data is on this device',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'No account · No cloud · No sync',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8E8E8E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Storage used · ${storageMb.toStringAsFixed(1)} MB',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF2ECEC), height: 1),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTapNickname,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 4.0,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nickname',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
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
    );
  }

  Widget _buildRowItem({
    required IconData icon,
    required String title,
    String? trailingText,
    Color titleColor = const Color(0xFF2C2C2C),
    Color iconColor = const Color(0xFF8E8E8E),
    bool showChevron = true,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E8E)),
              ),
              const SizedBox(width: 8),
            ],
            if (showChevron)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFFC0A6A6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF8E8E8E)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF9E385A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5D9D9),
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  // --- ACTIONS & SHEETS ---

  void _showEditNicknameDialog() {
    final controller = TextEditingController(
      text: widget.viewModel.profile?.name ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Nickname',
          style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter nickname',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9E385A)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8E8E8E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              Navigator.pop(context);
              try {
                await widget.viewModel.updateNickname(newName);
              } catch (_) {}
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF9E385A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCycleLengthPicker() {
    _showNumberPickerSheet(
      title: 'Average cycle length',
      subtitle: 'Count from the first day of one period to the next.',
      initialValue: widget.viewModel.cycleSettings?.averageCycleLength ?? 28,
      minValue: 15,
      maxValue: 45,
      unit: 'days',
      onSaved: (val) => widget.viewModel.updateCycleLength(val),
    );
  }

  void _showPeriodDurationPicker() {
    _showNumberPickerSheet(
      title: 'Period duration',
      subtitle: 'How many days does your bleeding usually last?',
      initialValue: widget.viewModel.cycleSettings?.averagePeriodDuration ?? 5,
      minValue: 2,
      maxValue: 14,
      unit: 'days',
      onSaved: (val) => widget.viewModel.updatePeriodDuration(val),
    );
  }

  void _showNumberPickerSheet({
    required String title,
    required String subtitle,
    required int initialValue,
    required int minValue,
    required int maxValue,
    required String unit,
    required ValueChanged<int> onSaved,
  }) {
    int selectedVal = initialValue;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Standard ListWheelScrollView for nice selection
                    SizedBox(
                      height: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 44,
                              controller: FixedExtentScrollController(
                                initialItem: selectedVal - minValue,
                              ),
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setModalState(() {
                                  selectedVal = minValue + index;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: (maxValue - minValue) + 1,
                                builder: (context, index) {
                                  final val = minValue + index;
                                  final isSelected = val == selectedVal;
                                  return Center(
                                    child: Text(
                                      '$val',
                                      style: TextStyle(
                                        fontSize: isSelected ? 24 : 18,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFF9E385A)
                                            : const Color(0xFF8E8E8E),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Text(
                            unit,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6E6E6E),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onSaved(selectedVal);
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
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLastPeriodDatePicker() {
    DateTime selectedDate = widget.viewModel.lastPeriodDate ?? DateTime.now();
    DateTime currentMonth = DateTime(selectedDate.year, selectedDate.month);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final daysInMonth = DateTime(
              currentMonth.year,
              currentMonth.month + 1,
              0,
            ).day;
            final firstWeekday =
                DateTime(currentMonth.year, currentMonth.month, 1).weekday %
                7; // Sunday is 0

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Last Period Date',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Month controller
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                          ),
                          onPressed: () {
                            setModalState(() {
                              currentMonth = DateTime(
                                currentMonth.year,
                                currentMonth.month - 1,
                              );
                            });
                          },
                        ),
                        Text(
                          '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                          onPressed: () {
                            setModalState(() {
                              currentMonth = DateTime(
                                currentMonth.year,
                                currentMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Weekday headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Expanded(
                          child: Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'M',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'T',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'W',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'T',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'F',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Calendar grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 35, // 5 rows
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                      itemBuilder: (context, index) {
                        final dayIndex = index - firstWeekday + 1;
                        if (dayIndex <= 0 || dayIndex > daysInMonth) {
                          return const SizedBox.shrink();
                        }

                        final dayDate = DateTime(
                          currentMonth.year,
                          currentMonth.month,
                          dayIndex,
                        );
                        final isSelected =
                            dayDate.year == selectedDate.year &&
                            dayDate.month == selectedDate.month &&
                            dayDate.day == selectedDate.day;

                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedDate = dayDate;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF9E385A)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$dayIndex',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF2C2C2C),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.viewModel.updateLastPeriodDate(selectedDate);
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
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _exportBackupFlow() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = p.join(
        tempDir.path,
        'heralth_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await widget.viewModel.exportBackup(path);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Backup Exported',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Your local backup has been successfully exported to:\n\n$path',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF9E385A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (_) {}
  }

  void _showClearHistoryConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.cleaning_services_outlined,
                  size: 48,
                  color: Color(0xFF9E385A),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Clear Check-up History?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This will permanently delete all your previous check-up logs, symptom reports, and analysis results from this device. Cycle tracking logs are not deleted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6E6E6E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final di = ServiceLocator.instance;
                    await widget.viewModel.clearCheckUpHistory(
                      di.checkUpRepository,
                      di.reportRepository,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Check-up history cleared.'),
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
                  child: const Text(
                    'Yes, Clear History',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF8E8E8E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAllDataConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 48,
                  color: Color(0xFFC95B6F),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete All Application Data?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This is a destructive action. All cycle logs, settings, preferences, and symptoms will be permanently wiped. This cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6E6E6E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await widget.viewModel.clearAllData();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingScreen(
                            viewModel: OnboardingViewModel(
                              ServiceLocator.instance.userProfileRepository,
                              ServiceLocator.instance.cycleRepository,
                            ),
                            onComplete: () {
                              // Re-navigate to home screen by rebuilding root or pushing container
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MainNavigationContainer(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC95B6F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Yes, Delete Everything',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF8E8E8E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToPrivacyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyScreen()),
    );
  }

  void _openHistory() {
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

  // --- HELPERS ---

  String _formatDate(DateTime date) {
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

  String _getMonthName(int month) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

// Standalone reusable PrivacyScreen wrapping the PrivacyView checklist info
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2C2C2C),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        scrolledUnderElevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF9E385A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.phonelink_lock_rounded,
                size: 32,
                color: Color(0xFF9E385A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your data never leaves this phone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Everything you log is stored locally on your device. There is no account server, and nothing is uploaded or shared.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF6E6E6E),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureCard(
              icon: Icons.no_accounts_rounded,
              title: 'No account, ever',
              subtitle: 'No email, no password, no sign-in. HerAlth doesn\'t know who you are.',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.cloud_off_rounded,
              title: 'No cloud, no tracking',
              subtitle: 'There is no server. Nothing is uploaded, synced or analysed remotely.',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.delete_sweep_rounded,
              title: 'You can erase it anytime',
              subtitle: 'Delete everything from Profile settings in one tap.',
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE88A8A).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF9E385A), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6E6E6E),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 56.0),
      child: Divider(color: Color(0xFFF2ECEC), height: 1),
    );
  }
}
