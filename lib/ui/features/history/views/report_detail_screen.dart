import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../domain/models/check_up.dart';
import '../../../../domain/models/cycle.dart';
import '../../../../domain/models/user_profile.dart';

class ReportDetailScreen extends StatelessWidget {
  final CheckUp checkUp;
  final List<Cycle> cycles;
  final CycleSettings settings;

  const ReportDetailScreen({
    super.key,
    required this.checkUp,
    required this.cycles,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    // Determine dynamic cycle context
    int cycleDay = 13;
    String phaseName = 'Ovulation';
    String lastPeriodText = 'Apr 7';

    // Find the cycle containing this checkup
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
      final phase = di.cycleEngine.getPhaseForDay(cycleDay, settings);
      phaseName = _getPhaseDisplayName(phase);
      lastPeriodText = _formatShortDate(matchedCycle.startDate);
    } else if (cycles.isNotEmpty) {
      lastPeriodText = _formatShortDate(cycles.first.startDate);
    }

    // Determine flagged status
    final isFlagged = _isCheckUpFlagged(checkUp);

    // Dynamic completed time
    final completedTime = '${checkUp.date.hour.toString().padLeft(2, '0')}:${checkUp.date.minute.toString().padLeft(2, '0')}';

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
            const Text(
              'ASSESSMENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFF8E8E8E),
              ),
            ),
            const SizedBox(height: 8),
            // Serif Date Title
            Text(
              _formatLongDate(checkUp.date),
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Completed at $completedTime · Day $cycleDay, $phaseName',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E8E),
              ),
            ),
            const SizedBox(height: 16),

            // Status Badge
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isFlagged ? const Color(0xFFFDF0CD) : const Color(0xFFE2F4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isFlagged ? const Color(0xFFD69E2E) : const Color(0xFF2F855A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isFlagged ? 'Attention suggested' : 'Normal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isFlagged ? const Color(0xFF9E6E10) : const Color(0xFF276749),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 1. Symptoms Card
            _buildCardHeader('SYMPTOMS REPORTED'),
            _buildCardContainer(
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: checkUp.symptoms.isEmpty
                    ? const Text(
                        'No symptoms reported.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF8E8E8E)),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: checkUp.symptoms.map((s) => _buildSymptomPill(s.name)).toList(),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Cycle Context Card
            _buildCardHeader('CYCLE CONTEXT'),
            _buildCardContainer(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    _buildContextRow('Cycle day', '$cycleDay'),
                    const Divider(color: Color(0xFFF2ECEC), height: 16),
                    _buildContextRow('Phase', phaseName),
                    const Divider(color: Color(0xFFF2ECEC), height: 16),
                    _buildContextRow('Avg cycle', '${settings.averageCycleLength} days'),
                    const Divider(color: Color(0xFFF2ECEC), height: 16),
                    _buildContextRow('Last period', lastPeriodText),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. HerAlth's Insight Card
            _buildCardHeader("HERALTH'S INSIGHT"),
            _buildCardContainer(
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFlagged
                          ? 'Based on your reported symptoms and current cycle phase, we note an overlap in fatigue and cramping that is somewhat atypical for mid-cycle.'
                          : 'Your reported symptoms are aligned with what is typically expected for this phase of your cycle. No atypical patterns were detected.',
                      style: const TextStyle(fontSize: 15, color: Color(0xFF2C2C2C), height: 1.45),
                    ),
                    if (isFlagged) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Color(0xFFE88A8A), width: 3),
                          ),
                        ),
                        child: const Text(
                          '"While ovulation can occasionally cause mild discomfort, the intensity of fatigue reported warrants observation."',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF2C2C2C),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'We recommend prioritizing rest over the next 48 hours and ensuring adequate hydration. If symptoms persist beyond Day 15, consider consulting your healthcare provider.',
                        style: TextStyle(fontSize: 15, color: Color(0xFF2C2C2C), height: 1.45),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Recommendations Card
            _buildCardHeader('RECOMMENDATIONS'),
            _buildCardContainer(
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: isFlagged
                    ? Column(
                        children: [
                          _buildRecommendationItem(
                            '01',
                            'Increase Magnesium',
                            'Helps mitigate cramping',
                          ),
                          const SizedBox(height: 16),
                          _buildRecommendationItem(
                            '02',
                            'Gentle Movement',
                            'Light stretching or walking',
                          ),
                          const SizedBox(height: 16),
                          _buildRecommendationItem(
                            '03',
                            'Log Tomorrow',
                            'Track progression of fatigue',
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildRecommendationItem(
                            '01',
                            'Stay Hydrated',
                            'Supports energy level maintenance',
                          ),
                          const SizedBox(height: 16),
                          _buildRecommendationItem(
                            '02',
                            'Balanced Nutrition',
                            'Eat magnesium and iron-rich foods',
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9E385A).withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF9E385A).withOpacity(0.08),
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
                      'This assessment is generated for informational purposes and does not constitute medical advice. Always consult a healthcare professional for diagnosis or treatment.',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF2C2C2C).withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Bottom Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generating PDF...')),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                    label: const Text(
                      'Generate PDF',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57A90),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE88A8A).withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.ios_share_rounded, color: Color(0xFF2C2C2C)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing report...')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // --- HELPERS & COMPONENT BUILDERS ---

  Widget _buildCardHeader(String title) {
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

  Widget _buildCardContainer(Widget child) {
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
      child: child,
    );
  }

  Widget _buildSymptomPill(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C2C2C),
        ),
      ),
    );
  }

  Widget _buildContextRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Color(0xFF6E6E6E)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(String number, String title, String subtitle) {
    return Row(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE57A90),
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E8E),
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFC0A6A6)),
      ],
    );
  }

  bool _isCheckUpFlagged(CheckUp cu) {
    const attentionSymptoms = {'fatigue', 'cramps', 'bloating', 'headache', 'nausea', 'acne', 'pain', 'heavy flow'};
    return cu.symptoms.any((s) => attentionSymptoms.contains(s.name.toLowerCase()));
  }

  String _formatLongDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatShortDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
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
