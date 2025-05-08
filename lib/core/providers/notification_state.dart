import 'package:flutter/material.dart';

class NotificationState extends ChangeNotifier {
  bool _isVisible = false;
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'High Energy Usage Alert',
      message: 'Living Room consumption is 25% above average',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.warning,
    ),
    NotificationItem(
      title: 'Smart Schedule Active',
      message: 'AC will automatically turn off at 10 PM',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.info,
    ),
    NotificationItem(
      title: 'Energy Goal Achieved',
      message: "You've met your daily energy saving target!",
      time: DateTime.now().subtract(const Duration(hours: 6)),
      type: NotificationType.success,
    ),
    NotificationItem(
      title: 'Device Offline',
      message: 'Kitchen smart plug is disconnected',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.error,
    ),
  ];

  bool get isVisible => _isVisible;
  List<NotificationItem> get notifications => _notifications;

  void togglePanel() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void removeNotification(int index) {
    _notifications.removeAt(index);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    this.type = NotificationType.info,
  });
}

enum NotificationType { info, warning, success, error }
