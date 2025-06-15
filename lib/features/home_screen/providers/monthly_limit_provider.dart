import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/energy_service.dart';

class MonthlyLimitProvider with ChangeNotifier {
    final EnergyService _energyService = EnergyService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _limitKey = 'monthly_limit';

  double _limit = 500; // Default limit of 500 units
  List<double> _dailyUsage = [];
  double _currentEnergy = 0;
  late final SharedPreferences _prefs;

  MonthlyLimitProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _limit = _prefs.getDouble(_limitKey) ?? 500;
    _initializeDailyUsage();
    _setupEnergyListener();
    notifyListeners();
  }

  void _setupEnergyListener() {
    _energyService.getEnergyReadings().listen((reading) {
      final newEnergy =
          double.tryParse(reading['energy']?.toString() ?? '0') ?? 0;
      debugPrint('Energy reading received: $newEnergy');

      if (newEnergy != _currentEnergy) {
        _currentEnergy = newEnergy;

        // Update the current day's usage with the new energy value
        _updateDailyUsageWithNewReading(newEnergy);

        notifyListeners();
      }
    });
  }

  void _updateDailyUsageWithNewReading(double newEnergy) {
    final now = DateTime.now();
    final currentDay = now.day;

    // Ensure we have enough days in our list
    while (_dailyUsage.length < currentDay) {
      _dailyUsage.add(0.0);
    }

    // Update the current day's usage
    if (currentDay > 0) {
      _dailyUsage[currentDay - 1] = newEnergy;

      // Ensure the list doesn't exceed 30 days
      if (_dailyUsage.length > 30) {
        _dailyUsage = _dailyUsage.sublist(0, 30);
      }
    }
  }

  double get limit => _limit;
  List<double> get dailyUsage => List.unmodifiable(_dailyUsage);

  // Calculate current usage as sum of daily usage
  double get currentUsage => _currentEnergy;

  // Calculate usage percentage
  double get usagePercentage => currentUsage / _limit;

  Future<void> setLimit(double newLimit) async {
    if (newLimit <= 0) return;

    _limit = newLimit;
    await _prefs.setDouble(_limitKey, newLimit);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('user_settings').doc(user.uid).set({
          'monthly_limit': newLimit,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error saving limit to Firestore: $e');
      }
    }

    _initializeDailyUsage(); // Reinitialize daily usage when limit changes
    notifyListeners();
  }

  // Initialize daily usage with the current energy reading
  void _initializeDailyUsage() {
    final now = DateTime.now();
    final currentDay = now.day.clamp(1, 30);

    // Initialize with zeros for all previous days
    _dailyUsage = List.filled(currentDay, 0.0);

    // If we have a current energy reading, set it for today
    if (_currentEnergy > 0) {
      _dailyUsage[currentDay - 1] = _currentEnergy;
    }
  }

  // Calculate projected usage based on current trend
  List<double> getProjectedUsage() {
    if (_dailyUsage.isEmpty || _dailyUsage.length < 2) return [];

    final currentDay = _dailyUsage.length;
    final remainingDays = 30 - currentDay;
    if (remainingDays <= 0) return [];

    // Don't show projection if we don't have enough data
    if (currentDay < 2) return [];

    // Calculate trend based on last 3-7 days (whichever is available)
    final daysToConsider = math.min(7, currentDay - 1);
    double totalIncrease = 0;

    // Calculate average daily increase
    for (int i = currentDay - daysToConsider; i < currentDay; i++) {
      totalIncrease += _dailyUsage[i] - (i > 0 ? _dailyUsage[i - 1] : 0);
    }
    double avgDailyIncrease = totalIncrease / daysToConsider;

    // Limit the maximum daily increase to prevent extreme projections
    final maxDailyIncrease = _limit * 0.05; // Max 5% of limit per day
    avgDailyIncrease = avgDailyIncrease.clamp(
      -maxDailyIncrease,
      maxDailyIncrease,
    );

    // Calculate projection
    final projected = <double>[];
    double lastValue = _dailyUsage.last;
    final maxProjectedValue = _limit * 1.2; // Max 120% of limit

    for (int i = 0; i < remainingDays; i++) {
      // Gradually reduce the impact of the trend as we project further
      final distanceFactor = (i + 1) / remainingDays;

      // Add some random variation (±10%)
      final variation = 0.9 + (math.Random().nextDouble() * 0.2);

      // Calculate next value with trend and variation, but limit the increase
      double nextValue =
          lastValue +
          (avgDailyIncrease * variation * (1 - (distanceFactor * 0.5)));

      // Ensure the projection stays within reasonable bounds
      nextValue = nextValue.clamp(0, maxProjectedValue);

      // If we're at the limit, don't project any higher
      if (nextValue >= _limit * 0.95) {
        projected.add(_limit);
        break;
      }

      projected.add(nextValue);
      lastValue = nextValue;
    }

    return projected;
  }
}
