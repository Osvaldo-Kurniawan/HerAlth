import 'package:flutter/material.dart';
import '../view_models/onboarding_view_model.dart';

class PrivacyView extends StatefulWidget {
  final OnboardingViewModel viewModel;

  const PrivacyView({super.key, required this.viewModel});

  @override
  State<PrivacyView> createState() => _PrivacyViewState();
}

class _PrivacyViewState extends State<PrivacyView> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCF5F5),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Phone lock icon
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Everything you log is stored locally on your device, there is no account server, and nothing is uploaded or shared.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6E6E6E),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              // Checklist Cards
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
                subtitle: 'Delete everything from Profile in one tap.',
              ),
              const SizedBox(height: 24),
              // Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF9E385A).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF9E385A).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF9E385A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Because data is local, uninstalling the app deletes it permanently. Export a backup from Profile anytime.',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF2C2C2C).withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isChecked,
                  onChanged: (val) {
                    setState(() {
                      _isChecked = val ?? false;
                    });
                  },
                  title: const Text(
                    'I understand my data is stored only on this device.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF9E385A),
                ),
              ),
              const SizedBox(height: 24),
              // Button
              ElevatedButton(
                onPressed: _isChecked ? () => widget.viewModel.nextStep() : null,
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
                    color: _isChecked ? Colors.white : const Color(0xFF8E8E8E),
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
            child: Icon(
              icon,
              color: const Color(0xFF9E385A),
              size: 24,
            ),
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
