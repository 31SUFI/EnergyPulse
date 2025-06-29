import 'package:energy_meter_app/features/auth/view/auth_wrapper.dart';
import 'package:energy_meter_app/features/routine/provider/firebase_realtime_provider.dart';
import 'package:energy_meter_app/features/routine/provider/firebase_schedule_provider.dart';
import 'package:energy_meter_app/features/suggestions/provider/suggestion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/app_state.dart';
import 'core/providers/navigation_state.dart';
import 'core/providers/notification_state.dart';
import 'features/home_screen/providers/space_provider.dart';
import 'features/home_screen/providers/monthly_limit_provider.dart';
import 'features/stats_screen/providers/room_selection_provider.dart';
import 'features/stats_screen/providers/energy_stats_provider.dart';
import 'core/services/energy_monitor_service.dart';
import 'core/services/energy_service.dart';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermissions() async {
  final status = await Permission.notification.request();
  if (status.isDenied) {
    debugPrint('Notification permission denied.');
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Import and initialize the EnergyMonitorService
    final energyMonitorService = EnergyMonitorService();
    await requestNotificationPermissions();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => NavigationState()),
          ChangeNotifierProvider(create: (_) => NotificationState()),
          ChangeNotifierProvider(create: (_) => SpaceProvider()),
          ChangeNotifierProvider(create: (_) => RoomSelectionProvider()),
          ChangeNotifierProvider(create: (_) => EnergyService()),
          ChangeNotifierProxyProvider<EnergyService, MonthlyLimitProvider>(
            create: (context) => MonthlyLimitProvider(
              notificationState: context.read<NotificationState>(),
            ),
            update: (_, energyService, monthlyLimitProvider) =>
                monthlyLimitProvider!..updateUsage(energyService),
          ),
          ChangeNotifierProvider(create: (_) => EnergyStatsProvider()),
          ChangeNotifierProvider(create: (_) => FirebaseScheduleProvider()),
          ChangeNotifierProvider(create: (_) => FirebaseRealtimeProvider()),
          ChangeNotifierProvider(
            create: (context) => SuggestionProvider(
              context.read<EnergyService>(),
              context.read<MonthlyLimitProvider>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // After the first frame, initialize EnergyMonitorService with context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        energyMonitorService.init(context);
      }
    });
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error initializing app: $e'))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Energy Meter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'AnekLatin',
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
