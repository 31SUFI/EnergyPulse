import 'package:flutter/material.dart';

class NotificationState extends ChangeNotifier {
  bool _isVisible = false;
  List<NotificationItem> _notifications = [];

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
