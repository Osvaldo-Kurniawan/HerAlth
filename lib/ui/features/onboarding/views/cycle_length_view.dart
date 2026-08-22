import 'package:flutter/material.dart';
import '../view_models/onboarding_view_model.dart';

class CycleLengthView extends StatefulWidget {
  final OnboardingViewModel viewModel;

  const CycleLengthView({super.key, required this.viewModel});

  @override
  State<CycleLengthView> createState() => _CycleLengthViewState();
}

class _CycleLengthViewState extends State<CycleLengthView> {
  late ScrollController _scrollController;
  final int minDays = 15;
  final int maxDays = 45;
  final double itemWidth = 20.0;
  int _currentValue = 28;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.viewModel.cycleLength;
    _scrollController = ScrollController(
      initialScrollOffset: (_currentValue - minDays) * itemWidth,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final offset = _scrollController.offset;
    final index = (offset / itemWidth).round();
    final value = (minDays + index).clamp(minDays, maxDays);
    
    if (value != _currentValue) {
      setState(() {
        _currentValue = value;
      });
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
                      'How long is your cycle, usually?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Count from the first day of one period to the next.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6E6E6E),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Value Display
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$_currentValue',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'days',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF6E6E6E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Scrollable Ruler Card
                    _buildRulerCard(),
                    const SizedBox(height: 32),
                    // Average Suggestion Button
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentValue = 28;
                            final targetOffset = (28 - minDays) * itemWidth;
                            _scrollController.animateTo(
                              targetOffset,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                        },
                        icon: const Icon(Icons.help_outline_rounded, size: 16),
                        label: const Text('Not sure? 28 days is average'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9E385A),
                          side: BorderSide(color: const Color(0xFF9E385A).withOpacity(0.3)),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
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
                    // Continue button
                    ElevatedButton(
                      onPressed: () {
                        widget.viewModel.setCycleLength(_currentValue);
                        widget.viewModel.nextStep();
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
                        'Continue',
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
                'SETUP · STEP 2 OF 4',
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
        // Progress bar (50%)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 3,
                  color: const Color(0xFF9E385A),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 3,
                  color: const Color(0xFFE5D9D9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulerCard() {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background layout
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                _onScroll();
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              // Add padding on sides to center first/last items
              padding: const EdgeInsets.symmetric(horizontal: 160.0),
              itemCount: (maxDays - minDays) + 1,
              itemBuilder: (context, index) {
                final day = minDays + index;
                final isMajor = day % 5 == 0;
                
                return SizedBox(
                  width: itemWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tick marks
                      Container(
                        width: 1.5,
                        height: isMajor ? 32 : 16,
                        color: isMajor ? const Color(0xFF9E385A).withOpacity(0.5) : const Color(0xFF8E8E8E).withOpacity(0.3),
                      ),
                      if (isMajor) ...[
                        const SizedBox(height: 8),
                        Text(
                          '$day',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6E6E6E),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          // Central red indicator line
          IgnorePointer(
            child: Container(
              width: 2,
              height: 48,
              color: const Color(0xFF9E385A),
            ),
          ),
        ],
      ),
    );
  }
}
