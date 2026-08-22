import 'package:flutter/material.dart';

import '../view_models/reads_view_model.dart';

class ReadsScreen extends StatelessWidget {
  final ReadsViewModel viewModel;

  const ReadsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Offline Reads')),
          body: const Center(child: Text('Reads Skeleton Screen')),
        );
      },
    );
  }
}
