import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../../core/providers/notification_state.dart';
import '../../../core/services/energy_service.dart';
import '../../../core/services/monthly_limit_service.dart';

class MonthlyLimitProvider with ChangeNotifier {
  final NotificationState? _notificationState;
  double _limit = 0; // Default limit of 500 units
  List<double> _dailyUsage = [];
  double _currentEnergy = 0;
  final MonthlyLimitService _limitService = MonthlyLimitService();
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _limitCrossedNotified = false;

  MonthlyLimitProvider({NotificationState? notificationState})
      : _notificationState = notificationState {
    _init();
  }

  Stream<double>? _limitStream;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    // Listen to real-time changes from RTDB
    _limitStream = _limitService.getMonthlyLimitStream();
    _limitStream!.listen((limitFromDB) {
      _limit = limitFromDB;
      notifyListeners();
    });
    _initializeDailyUsage();
    _isLoading = false;
    notifyListeners();
  }

  void updateUsage(EnergyService energyService) {
    final newEnergy = energyService.totalEnergy;
    debugPrint('Energy reading received via provider: $newEnergy');

    if (newEnergy != _currentEnergy) {
      _currentEnergy = newEnergy;

      // Update the current day's usage with the new energy value
      _updateDailyUsageWithNewReading(newEnergy);
      if (currentUsage > _limit) {
        _limitService.updateProtectedStatus(false);
        if (!_limitCrossedNotified) {
          Future.microtask(() {
            _notificationState?.addNotification(
              NotificationItem(
                title: 'Energy Limit Crossed',
                message: 'You have crossed the ${_limit.toInt()} units limit.',
                time: DateTime.now(),
                type: NotificationType.warning,
              ),
            );
          });
          _limitCrossedNotified = true;
        }
      } else {
        _limitService.updateProtectedStatus(true);
        _limitCrossedNotified = false; // Reset when back under the limit
      }
      notifyListeners();
    }
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
  double get usagePercentage {
    if (_limit == 0 || _limit.isNaN || _limit.isInfinite) return 0;
    final percent = currentUsage / _limit;
    if (percent.isNaN || percent.isInfinite) return 0;
    return percent.clamp(0.0, 1.0);
  }

  Future<void> setLimit(double newLimit) async {
    if (newLimit <= 0) return;
    _limit = newLimit;
    _isLoading = true;
    notifyListeners();
    await _limitService.setMonthlyLimit(newLimit);
    _initializeDailyUsage(); // Reinitialize daily usage when limit changes
    _isLoading = false;
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
