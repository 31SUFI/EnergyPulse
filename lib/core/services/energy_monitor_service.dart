import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_state.dart';

class EnergyMonitorService with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('readings');
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  double _lastNotifiedValue = -1;
  bool _initialized = false;

  Future<void> init(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;
    await _initNotifications();
    _dbRef.onValue.listen((event) => _onReadingsUpdateWithContext(event, context));
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notifications.initialize(initializationSettings);
  }

  void _onReadingsUpdateWithContext(DatabaseEvent event, BuildContext context) {
    final data = event.snapshot.value;
    if (data is Map) {
      final double energy = _toDouble(data['energy']);
      final double limit = _toDouble(data['monthly_limit']);
      if (limit > 0 && energy >= 0.7 * limit && energy != _lastNotifiedValue) {
        _showLimitAlert(energy, limit, context);
        _lastNotifiedValue = energy;
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

  Future<void> _showLimitAlert(double energy, double limit, BuildContext context) async {
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
    final notificationState = Provider.of<NotificationState>(context, listen: false);
    notificationState.addNotification(NotificationItem(
      title: 'Energy Limit Alert',
      message: 'Your energy usage is at ${energy.toStringAsFixed(1)} kWh, close to your limit of $limit kWh!',
      time: DateTime.now(),
      type: NotificationType.warning,
    ));
  }
}
