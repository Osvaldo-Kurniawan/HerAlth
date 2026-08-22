import 'package:flutter/material.dart';
import '../view_models/onboarding_view_model.dart';

class GoalView extends StatefulWidget {
  final OnboardingViewModel viewModel;

  const GoalView({super.key, required this.viewModel});

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  String? _selectedGoal;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel.goal.isNotEmpty) {
      _selectedGoal = widget.viewModel.goal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCF5F5),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopNavBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'What brings you to HerAlth?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This shapes your insights. Pick one.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6E6E6E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Goal Option Cards
                    _buildGoalCard(
                      goalValue: 'Track my cycle',
                      title: 'Track my cycle',
                      icon: Icons.sync_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildGoalCard(
                      goalValue: 'Understand my symptoms',
                      title: 'Understand my symptoms',
                      icon: Icons.analytics_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildGoalCard(
                      goalValue: 'Trying to conceive',
                      title: 'Trying to conceive',
                      icon: Icons.child_care_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildGoalCard(
                      goalValue: 'Just curious',
                      title: 'Just curious',
                      icon: Icons.search_rounded,
                    ),
                    const SizedBox(height: 32),
                    // Lock note
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF8E8E8E)),
                          SizedBox(width: 8),
                          Text(
                            'Saved on this device only',
                            style: TextStyle(fontSize: 12, color: Color(0xFF8E8E8E)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Finish button
                    ElevatedButton(
                      onPressed: _selectedGoal != null
                          ? () {
                              widget.viewModel.setGoal(_selectedGoal!);
                              widget.viewModel.nextStep(); // Goes to Review (Step 6)
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
                        'Finish setup',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedGoal != null ? Colors.white : const Color(0xFF8E8E8E),
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
                'SETUP · STEP 4 OF 4',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFF6E6E6E),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        // Progress bar (100%)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            height: 3,
            color: const Color(0xFF9E385A),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required String goalValue,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedGoal == goalValue;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoal = goalValue;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF9E385A) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE88A8A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF9E385A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF9E385A),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
