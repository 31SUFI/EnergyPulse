import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/weather_greeting.dart';
import '../widgets/today_usage_card.dart';
import '../widgets/my_spaces.dart';
import '../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [WeatherGreeting(), TodayUsageCard(), MySpaces()],
        ),
      ),
    );
  }
}
