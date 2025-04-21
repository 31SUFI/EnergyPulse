import 'package:energy_meter_app/global%20widgets/custom_app_bar.dart';
import 'package:energy_meter_app/global%20widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import '../widgets/weather_greeting.dart';
import '../widgets/today_usage_card.dart';
import '../widgets/my_spaces.dart';
import '../../../core/providers/app_state.dart';
import 'package:provider/provider.dart';
import '../../stats/view/stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: CustomAppBar(title: _selectedIndex == 0 ? "Home" : "Energy Statistics"),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home Screen
          Consumer<AppState>(
            builder:
                (context, appState, _) => SingleChildScrollView(
              child: Column(
                children: const [
                  WeatherGreeting(),
                  SizedBox(height: 16),
                  TodayUsageCard(),
                  SizedBox(height: 16),
                  MySpaces(),
                ],
              ),
            ),
          ),
          // Stats Screen
          const StatsScreen(),
          // Other screens can be added here
          const SizedBox(),
          const SizedBox(),
        ],
      ),
    );
  }
}
