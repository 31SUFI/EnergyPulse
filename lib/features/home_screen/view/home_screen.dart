import 'package:flutter/material.dart';
import '../widgets/weather_greeting.dart';
import '../widgets/today_usage_card.dart';
import '../widgets/my_spaces.dart';
import '../widgets/monthly_limit_card.dart';
import '../../../core/providers/app_state.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder:
          (context, appState, _) => SingleChildScrollView(
            child: Column(
              children: const [
                WeatherGreeting(),
                SizedBox(height: 16),
                MonthlyLimitCard(),
                SizedBox(height: 16),
                TodayUsageCard(),
                SizedBox(height: 16),
                MySpaces(),
              ],
            ),
          ),
    );
  }
}
