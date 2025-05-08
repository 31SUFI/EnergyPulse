import 'package:energy_meter_app/features/auth/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/app_state.dart';
import 'core/providers/navigation_state.dart';
import 'core/providers/notification_state.dart';
import 'features/home_screen/providers/space_provider.dart';
import 'features/home_screen/providers/monthly_limit_provider.dart';
import 'features/stats_screen/providers/room_selection_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        ChangeNotifierProvider(create: (_) => NotificationState()),
        ChangeNotifierProvider(create: (_) => SpaceProvider()),
        ChangeNotifierProvider(create: (_) => RoomSelectionProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyLimitProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Meter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'AnekLatin',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
