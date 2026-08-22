import 'package:flutter/material.dart';

import '../view_models/onboarding_view_model.dart';

class LastPeriodView extends StatefulWidget {
  final OnboardingViewModel viewModel;

  const LastPeriodView({super.key, required this.viewModel});

  @override
  State<LastPeriodView> createState() => _LastPeriodViewState();
}

class _LastPeriodViewState extends State<LastPeriodView> {
  DateTime _currentMonth = DateTime(
    2026,
    4,
  ); // Starting default month matching the mockup image (April 2026)
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.viewModel.lastPeriodDate;
    if (_selectedDate != null) {
      _currentMonth = DateTime(_selectedDate!.year, _selectedDate!.month);
    }
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCF5F5),
      child: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'When did your last period start?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This anchors every prediction HerAlth makes.',
                      style: TextStyle(fontSize: 15, color: Color(0xFF6E6E6E)),
                    ),
                    const SizedBox(height: 24),
                    // Calendar Container Card
                    _buildCalendarCard(),
                    const SizedBox(height: 16),
                    if (_selectedDate != null)
                      Center(
                        child: Text(
                          'Selected: ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.day}, ${_selectedDate!.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6E6E6E),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Lock note
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 16,
                            color: Color(0xFF8E8E8E),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Saved on this device only',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E8E8E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Continue button
                    ElevatedButton(
                      onPressed: _selectedDate != null
                          ? () {
                              widget.viewModel.setLastPeriod(_selectedDate!);
                              widget.viewModel.nextStep();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9E385A),
                        disabledBackgroundColor: const Color(0xFFE5D9D9),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedDate != null
                              ? Colors.white
                              : const Color(0xFF8E8E8E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => widget.viewModel.prevStep(),
              ),
              const Text(
                'SETUP · STEP 1 OF 4',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFF6E6E6E),
                ),
              ),
              const SizedBox(width: 48), // Spacer to balance back arrow
            ],
          ),
        ),
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9E385A),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(2),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(height: 3, color: const Color(0xFFE5D9D9)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final daysInMonth = _getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    final firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday %
        7; // Sunday is 0

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                onPressed: _prevMonth,
              ),
              Text(
                '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Weekdays S M T W T F S
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayLabel('S'),
              _WeekdayLabel('M'),
              _WeekdayLabel('T'),
              _WeekdayLabel('W'),
              _WeekdayLabel('T'),
              _WeekdayLabel('F'),
              _WeekdayLabel('S'),
            ],
          ),
          const SizedBox(height: 8),
          // Month Grid Days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 rows of 7 days
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final dayIndex = index - firstWeekday + 1;
              if (dayIndex <= 0 || dayIndex > daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayDate = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                dayIndex,
              );
              final isSelected =
                  _selectedDate != null &&
                  _selectedDate!.year == dayDate.year &&
                  _selectedDate!.month == dayDate.month &&
                  _selectedDate!.day == dayDate.day;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = dayDate;
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
                      fontSize: 14,
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
        ],
      ),
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  String _getMonthName(int month) {
    const months = [
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

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8E8E8E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
