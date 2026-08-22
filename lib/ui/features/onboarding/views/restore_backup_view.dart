import 'package:flutter/material.dart';

import '../view_models/onboarding_view_model.dart';

class RestoreBackupView extends StatefulWidget {
  final OnboardingViewModel viewModel;
  final VoidCallback onRestoreSuccess;

  const RestoreBackupView({
    super.key,
    required this.viewModel,
    required this.onRestoreSuccess,
  });

  @override
  State<RestoreBackupView> createState() => _RestoreBackupViewState();
}

class _RestoreBackupViewState extends State<RestoreBackupView> {
  final TextEditingController _jsonController = TextEditingController();

  // Valid mock backup JSON template to help the user test the system easily
  static const String _mockBackupJson = '''{
  "exportedAt": "2026-08-22T12:00:00Z",
  "userProfile": {
    "name": "Jane Doe",
    "age": 28,
    "height": 165.0,
    "weight": 58.5
  },
  "cycleSettings": {
    "averageCycleLength": 28,
    "averagePeriodDuration": 5
  },
  "reminderSettings": {
    "periodReminderEnabled": true,
    "fertilityReminderEnabled": false,
    "checkUpReminderEnabled": true
  },
  "aiSettings": {
    "analysisModel": "Premium Health Model",
    "autoAnalyzeUltrasounds": true
  },
  "cycles": [],
  "cycleEntries": [],
  "checkUps": [],
  "analysisResults": [],
  "reports": []
}''';

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCF5F5),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Navigation Arrow
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () =>
                    widget.viewModel.goToStep(0), // Welcome screen is step 0
              ),
              const SizedBox(height: 16),
              const Text(
                'Restore Backup',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Paste your exported backup JSON code below, or use the test template button to simulate loading a file.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6E6E6E),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // JSON code input field
              Expanded(
                child: TextField(
                  controller: _jsonController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: '{\n  "exportedAt": "...",\n  "userProfile": { ... }\n}',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: const Color(0xFF9E385A).withOpacity(0.15),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF9E385A),
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _jsonController.text = _mockBackupJson;
                    },
                    icon: const Icon(Icons.code_rounded, size: 18),
                    label: const Text('Insert template'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9E385A),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _jsonController.clear();
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Status Message
              ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  if (widget.viewModel.restoreStatusMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Center(
                        child: Text(
                          widget.viewModel.restoreStatusMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                widget.viewModel.restoreStatusMessage!
                                        .startsWith('Error') ||
                                    widget.viewModel.restoreStatusMessage!
                                        .startsWith('Invalid')
                                ? Colors.redAccent
                                : Colors.green,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.viewModel.goToStep(0);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF9E385A)),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF9E385A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await widget.viewModel
                            .restoreFromBackupString(_jsonController.text);
                        if (success) {
                          widget.onRestoreSuccess();
                        }
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
                        'Restore',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
