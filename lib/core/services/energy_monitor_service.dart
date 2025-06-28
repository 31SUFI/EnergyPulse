import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_state.dart';
import 'monthly_limit_service.dart';

class EnergyMonitorService with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('readings');
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final MonthlyLimitService _limitService = MonthlyLimitService();

  double _lastNotifiedValue = -1;
  bool _limitExceededNotified = false;
  bool _initialized = false;

  Future<void> init(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;
    await _initNotifications();
    _dbRef.onValue.listen(
      (event) => _onReadingsUpdateWithContext(event, context),
    );
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notifications.initialize(initializationSettings);
  }

  void _onReadingsUpdateWithContext(
    DatabaseEvent event,
    BuildContext context,
  ) async {
    final data = event.snapshot.value;
    if (data is Map) {
      final double energy = _toDouble(data['energy']);
      final double? limit = await _limitService.getMonthlyLimit();

      if (limit != null && limit > 0) {
        // Reset flag if usage drops below limit (e.g., new month or limit increase)
        if (energy < limit) {
          _limitExceededNotified = false;
        }

        // Check 1: Limit exceeded
        if (energy > limit && !_limitExceededNotified) {
          _showLimitExceededAlert(energy, limit, context);
          _limitExceededNotified = true;
        }
        // Check 2: Approaching limit (and not exceeded)
        else if (energy >= 0.7 * limit &&
            energy < limit &&
            energy != _lastNotifiedValue) {
          _showLimitAlert(energy, limit, context);
          _lastNotifiedValue = energy;
        }
      }
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> _showLimitExceededAlert(
    double energy,
    double limit,
    BuildContext context,
  ) async {
    await _notifications.show(
      1, // Different ID for the exceeded alert
      'Monthly Limit Exceeded',
      'You have used ${energy.toStringAsFixed(1)} kWh, surpassing your limit of $limit kWh!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'energy_alerts_exceeded',
          'Energy Limit Exceeded Alerts',
          channelDescription:
              'Notifications when energy usage exceeds the limit',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    // Add to in-app notification panel
    final notificationState = Provider.of<NotificationState>(
      context,
      listen: false,
    );
    notificationState.addNotification(
      NotificationItem(
        title: 'Monthly Limit Exceeded',
        message:
            'You have used ${energy.toStringAsFixed(1)} kWh, surpassing your limit of $limit kWh!',
        time: DateTime.now(),
        type: NotificationType.error, // Use error type for exceeded limit
      ),
    );
  }

  Future<void> _showLimitAlert(
    double energy,
    double limit,
    BuildContext context,
  ) async {
    await _notifications.show(
      0,
      'Energy Limit Alert',
      'Your energy usage is at ${energy.toStringAsFixed(1)} kWh, close to your limit of $limit kWh!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'energy_alerts',
          'Energy Alerts',
          channelDescription: 'Notifications when energy usage nears limit',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    // Add to in-app notification panel
    final notificationState = Provider.of<NotificationState>(
      context,
      listen: false,
    );
    notificationState.addNotification(
      NotificationItem(
        title: 'Energy Limit Alert',
        message:
            'Your energy usage is at ${energy.toStringAsFixed(1)} kWh, close to your limit of $limit kWh!',
        time: DateTime.now(),
        type: NotificationType.warning,
      ),
    );
  }
}
