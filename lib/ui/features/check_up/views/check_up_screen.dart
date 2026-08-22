import 'package:flutter/material.dart';

import '../view_models/check_up_view_model.dart';

class CheckUpScreen extends StatelessWidget {
  final CheckUpViewModel viewModel;

  const CheckUpScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Check-Up & AI')),
          body: const Center(child: Text('Check-Up Skeleton Screen')),
        );
      },
    );
  }
}
