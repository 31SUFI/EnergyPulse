import 'package:flutter/material.dart';
import 'notification_storage.dart';

class NotificationState extends ChangeNotifier {
  NotificationState() {
    _loadNotifications();
  }

  bool _isVisible = false;
  final List<NotificationItem> _notifications = [];

  bool get isVisible => _isVisible;
  List<NotificationItem> get notifications => _notifications;

  void togglePanel() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    NotificationStorage.saveNotifications(_notifications);
    notifyListeners();
  }

  void removeNotification(int index) {
    _notifications.removeAt(index);
    NotificationStorage.saveNotifications(_notifications);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    NotificationStorage.clearNotifications();
    notifyListeners();
  }

  Future<void> _loadNotifications() async {
    final loaded = await NotificationStorage.loadNotifications();
    _notifications.clear();
    _notifications.addAll(loaded);
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

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'time': time.toIso8601String(),
    'type': type.name,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
    title: json['title'] as String,
    message: json['message'] as String,
    time: DateTime.parse(json['time'] as String),
    type: NotificationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => NotificationType.info,
    ),
  );
}

enum NotificationType { info, warning, success, error }
