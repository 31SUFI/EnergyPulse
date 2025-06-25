import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../model/firebase_schedule_model.dart';

class FirebaseScheduleProvider with ChangeNotifier {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  List<FirebaseSchedule> _schedules = [];

  List<FirebaseSchedule> get schedules => _schedules;

  FirebaseScheduleProvider() {
    listenToSchedules();
  }

  void listenToSchedules() {
    _db.child('schedules').onValue.listen((event) {
      final value = event.snapshot.value;
final schedulesMap = value is Map
    ? Map<String, dynamic>.from(value as Map)
    : <String, dynamic>{};
      _schedules = schedulesMap.entries.map((e) =>
        FirebaseSchedule.fromMap(e.key, Map<String, dynamic>.from(e.value))
      ).toList();
      notifyListeners();
    });
  }

  Future<void> createSchedule(FirebaseSchedule schedule) async {
    await _db.child('schedules').push().set(schedule.toMap());
  }

  Future<void> updateSchedule(String id, Map<String, dynamic> updates) async {
    await _db.child('schedules/$id').update(updates);
  }

  Future<void> deleteSchedule(String id) async {
    await _db.child('schedules/$id').remove();
  }
}
