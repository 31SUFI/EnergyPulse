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
      _schedules = schedulesMap.entries
          .map((e) =>
              FirebaseSchedule.fromMap(e.key, Map<String, dynamic>.from(e.value)))
          .toList();
      notifyListeners();
    });
  }

  Future<void> createSchedule(FirebaseSchedule schedule) async {
    await _db.child('schedules').push().set(schedule.toMap());
    // If the new schedule is enabled, set the relay mode to 'scheduled'
    if (schedule.enabled) {
      await _updateRelayMode(schedule.relay, isScheduled: true);
    }
  }

  Future<void> updateSchedule(String id, Map<String, dynamic> updates) async {
    // First, get the relay number from the schedule being updated
    final scheduleToUpdate = _schedules.firstWhere((s) => s.id == id);
    final relayId = scheduleToUpdate.relay;

    // Update the schedule in Firebase
    await _db.child('schedules/$id').update(updates);

    // Re-evaluate the mode for the affected relay
    await _checkAndSetRelayMode(relayId);
  }

  Future<void> deleteSchedule(String id) async {
    // First, get the relay number from the schedule being deleted
    final scheduleToDelete = _schedules.firstWhere((s) => s.id == id);
    final relayId = scheduleToDelete.relay;

    // Delete the schedule from Firebase
    await _db.child('schedules/$id').remove();

    // Re-evaluate the mode for the affected relay
    await _checkAndSetRelayMode(relayId);
  }

  /// Checks all schedules for a given relay and sets its mode to 'scheduled' or 'manual'.
  Future<void> _checkAndSetRelayMode(int relayId) async {
    // It's crucial to read the latest state from Firebase to make a correct decision.
    final schedulesSnapshot =
        await _db.child('schedules').orderByChild('relay').equalTo(relayId).get();

    bool hasEnabledSchedule = false;
    if (schedulesSnapshot.exists && schedulesSnapshot.value != null) {
      final schedulesMap =
          Map<String, dynamic>.from(schedulesSnapshot.value as Map);
      // Check if any of the schedules for this relay are enabled
      hasEnabledSchedule =
          schedulesMap.values.any((s) => (s['enabled'] as bool? ?? false));
    }

    await _updateRelayMode(relayId, isScheduled: hasEnabledSchedule);
  }

  /// Directly updates the mode of a specific relay in Firebase.
  Future<void> _updateRelayMode(int relayId, {required bool isScheduled}) async {
    final newMode = isScheduled ? 'scheduled' : 'manual';
    await _db.child('relays/relay$relayId').update({'mode': newMode});
  }
}
