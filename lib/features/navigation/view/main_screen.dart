import 'package:energy_meter_app/features/suggestions/model/suggestion_model.dart';
import 'package:energy_meter_app/features/suggestions/provider/suggestion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/navigation_state.dart';
import '../../../core/providers/notification_state.dart';
import '../../../core/constants/app_colors.dart';
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
  void _showSuggestionDialog(BuildContext context, Suggestion suggestion) {
    final suggestionProvider = context.read<SuggestionProvider>();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(suggestion.title),
          content: Text(suggestion.description),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply Tip'),
              onPressed: () {
                suggestionProvider.applySuggestion(context);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationState, NotificationState>(
      builder: (context, navigationState, notificationState, _) {
        return Scaffold(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          appBar: CustomAppBar(
            title: _getTitle(navigationState.currentIndex),
            actions: [
              Consumer<SuggestionProvider>(
                builder: (context, suggestionProvider, child) {
                  final suggestion = suggestionProvider.suggestion;
                  if (suggestion == null) {
                    return const SizedBox.shrink(); // No suggestion, no icon
                  }
                  return IconButton(
                    icon: const Icon(Icons.lightbulb_outline),
                    onPressed: () {
                      _showSuggestionDialog(context, suggestion);
                    },
                  );
                },
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      notificationState.togglePanel();
                      if (!notificationState.isVisible) {
                        // Panel will open, mark all as read
                        notificationState.markAllAsRead();
                      }
                    },
                  ),
                  if (notificationState.hasUnread)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
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
