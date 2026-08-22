import 'package:flutter/material.dart';

import '../view_models/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('HerAlth Home')),
          body: const Center(child: Text('Home Skeleton Screen')),
        );
      },
    );
  }
}
