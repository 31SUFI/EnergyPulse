import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class MonthlyLimitProvider with ChangeNotifier {
  double _limit = 500; // Default limit of 500 units
  List<double> _dailyUsage = [];

  MonthlyLimitProvider() {
    _initializeDailyUsage();
  }

  double get limit => _limit;
  List<double> get dailyUsage => List.unmodifiable(_dailyUsage);
  
  // Calculate current usage as sum of daily usage
  double get currentUsage => _dailyUsage.fold(0, (sum, usage) => sum + usage);
  
  // Calculate usage percentage
  double get usagePercentage => currentUsage / _limit;

  void setLimit(double newLimit) {
    _limit = newLimit;
    _initializeDailyUsage(); // Reinitialize daily usage when limit changes
    notifyListeners();
  }

  // Initialize daily usage with a realistic pattern
  void _initializeDailyUsage() {
    final targetUsage = _limit * 0.5; // 50% of limit
    final daysInMonth = 30;
    final averageDailyUsage = targetUsage / daysInMonth;
    
    // Create a realistic usage pattern with some variation
    _dailyUsage = List.generate(daysInMonth, (index) {
      // Add some random variation (±20% of average)
      final variation = (math.Random().nextDouble() - 0.5) * 0.4 * averageDailyUsage;
      return math.max(0, averageDailyUsage + variation);
    });

    // Calculate cumulative usage
    for (int i = 1; i < _dailyUsage.length; i++) {
      _dailyUsage[i] += _dailyUsage[i - 1];
    }
  }

  // Calculate projected usage based on current trend
  List<double> getProjectedUsage() {
    if (_dailyUsage.isEmpty) return [];
    
    final currentDay = _dailyUsage.length;
    if (currentDay < 2) return [];

    // Calculate average daily increase from the last 5 days
    final last5Days = _dailyUsage.sublist(math.max(0, currentDay - 5));
    final avgDailyIncrease = last5Days.last / last5Days.length;
    
    // Project for the remaining days
    List<double> projection = [];
    double lastValue = _dailyUsage.last;
    
    for (int i = 0; i < 10; i++) {
      lastValue += avgDailyIncrease;
      projection.add(lastValue);
    }
    
    return projection;
  }
}
