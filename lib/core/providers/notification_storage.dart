import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_state.dart';

class NotificationStorage {
  static const String _key = 'notifications';

  static Future<void> saveNotifications(List<NotificationItem> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<List<NotificationItem>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((n) => NotificationItem.fromJson(n as Map<String, dynamic>)).toList();
  }

  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
