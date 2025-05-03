import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/navigation_state.dart';
import '../../../core/providers/notification_state.dart';
import '../../../global widgets/custom_app_bar.dart';
import '../../../global widgets/custom_bottom_nav_bar.dart';
import '../../home_screen/view/home_screen.dart';
import '../../stats_screen/view/stats_screen.dart';
import '../../routine/view/routine_screen.dart';
import '../../profile/view/profile_screen.dart';
import '../../notification/widgets/notification_panel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationState, NotificationState>(
      builder: (context, navigationState, notificationState, _) {
        return Scaffold(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          appBar: CustomAppBar(
            title: _getTitle(navigationState.currentIndex),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => notificationState.togglePanel(),
              ),
            ],
          ),
          body: Stack(
            children: [
              IndexedStack(
                index: navigationState.currentIndex,
                children: const [
                  HomeScreen(),
                  StatsScreen(),
                  RoutineScreen(),
                  ProfileScreen(),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top:
                    notificationState.isVisible
                        ? 0
                        : -(MediaQuery.of(context).size.height),
                right: 0,
                left: 0,
                child: const NotificationPanel(),
              ),
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
        return 'Smart Routine';
      case 3:
        return 'Profile';
      default:
        return 'Home';
    }
  }
}
