import 'package:energy_meter_app/features/home_screen/widgets/power_info_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../widgets/greeting_card.dart';
import '../widgets/monthly_limit_card.dart';
import '../widgets/my_spaces.dart';
import '../widgets/today_usage_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder:
          (context, appState, _) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                GreetingCard(),
                SizedBox(height: 16),
                PowerInfoCard(),
                SizedBox(height: 24),
                MonthlyLimitCard(),
                SizedBox(height: 24),
                TodayUsageCard(),
              ],
            ),
          ),
    );
  }
}
