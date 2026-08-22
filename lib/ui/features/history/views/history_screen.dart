import 'package:flutter/material.dart';

import '../view_models/history_view_model.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryViewModel viewModel;

  const HistoryScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('History & Reports')),
          body: const Center(child: Text('History Skeleton Screen')),
        );
      },
    );
  }
}
