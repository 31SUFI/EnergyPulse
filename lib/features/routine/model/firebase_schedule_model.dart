import 'package:flutter/material.dart';

class FirebaseSchedule {
  final String id;
  final int relay;
  final String action; // 'ON' or 'OFF'
  final String startTime; // 'HH:mm'
  final String endTime;   // 'HH:mm'
  final bool enabled;

  FirebaseSchedule({
    required this.id,
    required this.relay,
    required this.action,
    required this.startTime,
    required this.endTime,
    required this.enabled,
  });

  factory FirebaseSchedule.fromMap(String id, Map data) => FirebaseSchedule(
    id: id,
    relay: data['relay'],
    action: data['action'],
    startTime: data['startTime'],
    endTime: data['endTime'],
    enabled: data['enabled'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'relay': relay,
    'action': action,
    'startTime': startTime,
    'endTime': endTime,
    'enabled': enabled,
  };
}
