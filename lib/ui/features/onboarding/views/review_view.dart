import 'package:flutter/material.dart';
import '../view_models/onboarding_view_model.dart';

class ReviewView extends StatelessWidget {
  final OnboardingViewModel viewModel;
  final VoidCallback onComplete;

  const ReviewView({
    super.key,
    required this.viewModel,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final lastPeriodFormatted = viewModel.lastPeriodDate != null
        ? '${_getMonthAbbreviation(viewModel.lastPeriodDate!.month)} ${viewModel.lastPeriodDate!.day}, ${viewModel.lastPeriodDate!.year}'
        : 'Not selected';

    return Container(
      color: const Color(0xFFFCF5F5),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Checkmark Circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE88A8A).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE88A8A),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: Color(0xFF9E385A),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'You\'re all set.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your cycle is saved locally and HerAlth will start predicting from today.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6E6E6E),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              // Summary Card
              Container(
                padding: const EdgeInsets.all(20),
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
                    // Last Period Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Last period',
                          style: TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
                        ),
                        Text(
                          lastPeriodFormatted,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Cycle Length Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cycle length',
                          style: TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
                        ),
                        Text(
                          '${viewModel.cycleLength} days',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Period Duration Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Period length',
                          style: TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
                        ),
                        Text(
                          '${viewModel.periodDuration} days',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Edit Action
                    TextButton(
                      onPressed: () => viewModel.goToStep(2), // Step 2 is Last Period
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Color(0xFF9E385A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Security note banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9E385A).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF9E385A),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stored on this device. You can export or delete it anytime in Profile.',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF2C2C2C).withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Action Button
              ElevatedButton(
                onPressed: () async {
                  await viewModel.completeOnboarding();
                  onComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E385A),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Open HerAlth',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
