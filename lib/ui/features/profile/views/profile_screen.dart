import 'package:flutter/material.dart';

import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileViewModel viewModel;

  const ProfileScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('User Profile & Data Settings')),
          body: const Center(child: Text('Profile Skeleton Screen')),
        );
      },
    );
  }
}
