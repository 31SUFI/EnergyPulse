import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FirebaseRealtimeProvider with ChangeNotifier {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final Map<String, Map<String, dynamic>> _localStateCache = {};
  static const _cooldownDuration = Duration(seconds: 5);

  Stream<Map<String, bool>> getRelayStates() {
    return _databaseReference.child('relays').onValue.map((event) {
      final Map<String, bool> relayStates = {};
      if (event.snapshot.value == null) {
        return relayStates;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data.forEach((key, value) {
        if (value is Map && value.containsKey('state')) {
          final bool firebaseState = value['state'] as bool;

          if (_localStateCache.containsKey(key)) {
            final cachedData = _localStateCache[key]!;
            final cachedState = cachedData['state'] as bool;
            final lastUpdate = cachedData['timestamp'] as DateTime;

            if (DateTime.now().difference(lastUpdate) < _cooldownDuration) {
              // Within cooldown, enforce local state
              relayStates[key] = cachedState;
              if (firebaseState != cachedState) {
                // If Firebase state mismatches, force update
                _forceUpdateRelayState(key, cachedState);
              }
            } else {
              // Cooldown expired, remove from cache and use Firebase state
              _localStateCache.remove(key);
              relayStates[key] = firebaseState;
            }
          } else {
            // Not in cache, use Firebase state
            relayStates[key] = firebaseState;
          }
        }
      });
      return relayStates;
    });
  }

  Future<void> toggleRelayState(String relayId, bool currentState) async {
    final newState = !currentState;
    _localStateCache[relayId] = {
      'state': newState,
      'timestamp': DateTime.now(),
    };
    await _forceUpdateRelayState(relayId, newState);
    notifyListeners();
  }

  Future<void> _forceUpdateRelayState(String relayId, bool state) async {
    try {
      final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _databaseReference.child('relays/$relayId').update({
        'state': state,
        'lastUpdate': timestamp,
      });
    } catch (error) {
      print('Error forcing relay state: $error');
    }
  }
}
