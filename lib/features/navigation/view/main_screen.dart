import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/navigation_state.dart';
import '../../../global widgets/custom_app_bar.dart';
import '../../../global widgets/custom_bottom_nav_bar.dart';
import '../../home_screen/view/home_screen.dart';
import '../../stats_screen/view/stats_screen.dart';
import '../../routine/view/routine_screen.dart';
import '../../profile/view/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationState>(
      builder: (context, navigationState, _) {
        return Scaffold(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          appBar: CustomAppBar(title: _getTitle(navigationState.currentIndex)),
          body: IndexedStack(
            index: navigationState.currentIndex,
            children: const [
              HomeScreen(),
              StatsScreen(),
              RoutineScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: navigationState.currentIndex,
            onTap: (index) => navigationState.setIndex(index),
          ),
        );
      },
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Energy Statistics';
      case 2:
        return 'Smart AI Routine';
      case 3:
        return 'Profile';
      default:
        return 'Home';
    }
  }
}
