import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../home/view_models/home_view_model.dart';
import '../../home/views/home_screen.dart';
import '../../check_up/view_models/check_up_view_model.dart';
import '../../check_up/views/check_up_screen.dart';
import '../../reads/view_models/reads_view_model.dart';
import '../../reads/views/reads_screen.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  late final HomeViewModel _homeViewModel;
  late final CheckUpViewModel _checkUpViewModel;
  late final ReadsViewModel _readsViewModel;

  @override
  void initState() {
    super.initState();
    // Initialize view models using ServiceLocator
    final di = ServiceLocator.instance;
    _homeViewModel = HomeViewModel(
      di.userProfileRepository,
      di.cycleRepository,
      di.cycleEngine,
    );
    _checkUpViewModel = CheckUpViewModel(di.checkUpRepository);
    _readsViewModel = ReadsViewModel(di.articleRepository);

    // Initial load
    _homeViewModel.loadDashboard();
    _checkUpViewModel.loadCheckUps();
    _readsViewModel.loadArticles();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Refresh data when navigating to specific tabs
    switch (index) {
      case 0:
        _homeViewModel.loadDashboard();
        break;
      case 1:
        _checkUpViewModel.loadCheckUps();
        break;
      case 2:
        _readsViewModel.loadArticles();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5F5),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 80.0,
            ), // Padding to avoid overlap with bottom navigation bar
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(viewModel: _homeViewModel),
                CheckUpScreen(viewModel: _checkUpViewModel),
                ReadsScreen(viewModel: _readsViewModel),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E385A).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home_rounded),
          _buildNavItem(
            1,
            Icons.medical_services_outlined,
            Icons.medical_services_rounded,
          ),
          _buildNavItem(2, Icons.menu_book_outlined, Icons.menu_book_rounded),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon) {
    final isActive = _currentIndex == index;
    final activeColor = const Color(0xFF9E385A);
    final inactiveColor = const Color(0xFF8E8E8E);

    return InkWell(
      onTap: () => _onTabTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? filledIcon : outlineIcon,
              color: isActive ? activeColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            // Tiny active dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
