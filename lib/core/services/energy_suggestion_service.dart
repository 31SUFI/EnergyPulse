import 'package:flutter/foundation.dart';

/// Service for generating intelligent energy-saving suggestions
/// based on current usage patterns and monthly limits
class EnergySuggestionService with ChangeNotifier {


  /// Generate suggestions based on current usage and limit
  List<EnergySuggestion> generateSuggestions({
    required double currentUsage,
    required double monthlyLimit,
    required List<double> dailyUsage,
    required bool isProtected,
  }) {
    // Only generate time-based actionable suggestions
    return _generateTimeBasedSuggestions(currentUsage, monthlyLimit, dailyUsage);
  }



  /// Generate time-based suggestions
  List<EnergySuggestion> _generateTimeBasedSuggestions(
    double currentUsage,
    double monthlyLimit,
    List<double> dailyUsage,
  ) {
    final List<EnergySuggestion> suggestions = [];
    final now = DateTime.now();
    final hour = now.hour;

    // Peak hours suggestions (6 PM - 10 PM)
    if (hour >= 18 && hour <= 22) {
      suggestions.add(
        EnergySuggestion(
          title: '⏰ Schedule Peak Hour Savings',
          description:
              'Energy rates are high. Schedule non-essential devices to turn off automatically during peak hours (6 PM - 10 PM).',
          priority: SuggestionPriority.warning,
          estimatedSavings: 7.0,
          actions: [
            'Tap to schedule AC to turn off',
            'Tap to schedule Water Heater to turn off',
          ],
          timeRecommendation: '6 PM - 10 PM',
          schedulePayload: {
            'startTime': '18:00',
            'endTime': '22:00',
            'action': 'Turn Off',
            'enabled': true,
          },
        ),
      );
    }

    // Night suggestions (10 PM - 6 AM)
    if (hour >= 22 || hour <= 6) {
      suggestions.add(
        EnergySuggestion(
          title: '🌙 Schedule Night-Time Appliances',
          description:
              'Energy is cheaper at night. Schedule appliances like water pumps or EV chargers to run after 10 PM.',
          priority: SuggestionPriority.info,
          estimatedSavings: 4.0,
          actions: [
            'Tap to schedule Water Pump to run',
            'Tap to schedule EV Charger to run',
          ],
          timeRecommendation: '10 PM - 6 AM',
          schedulePayload: {
            'startTime': '22:00',
            'endTime': '06:00',
            'action': 'Turn On',
            'enabled': true,
          },
        ),
      );
    }

    return suggestions;
  }



  /// Get suggestion statistics
  Map<String, dynamic> getSuggestionStats(List<EnergySuggestion> suggestions) {
    double totalSavings = 0.0;
    int criticalCount = 0;
    int warningCount = 0;
    int moderateCount = 0;
    int infoCount = 0;

    for (final suggestion in suggestions) {
      totalSavings += suggestion.estimatedSavings;
      switch (suggestion.priority) {
        case SuggestionPriority.critical:
          criticalCount++;
          break;
        case SuggestionPriority.warning:
          warningCount++;
          break;
        case SuggestionPriority.moderate:
          moderateCount++;
          break;
        case SuggestionPriority.info:
          infoCount++;
          break;
      }
    }

    return {
      'totalSuggestions': suggestions.length,
      'totalEstimatedSavings': totalSavings,
      'criticalSuggestions': criticalCount,
      'warningSuggestions': warningCount,
      'moderateSuggestions': moderateCount,
      'infoSuggestions': infoCount,
    };
  }
}

/// Model for energy suggestions
class EnergySuggestion {
  final String title;
  final String description;
  final SuggestionPriority priority;
  final double estimatedSavings;
  final List<String> actions;
  final String timeRecommendation;
  final Map<String, dynamic>? schedulePayload; // To make suggestions actionable

  EnergySuggestion({
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedSavings,
    required this.actions,
    required this.timeRecommendation,
    this.schedulePayload,
  });
}

/// Priority levels for suggestions
enum SuggestionPriority { critical, warning, moderate, info }

/// Extension for priority colors and icons
extension SuggestionPriorityExtension on SuggestionPriority {
  String get icon {
    switch (this) {
      case SuggestionPriority.critical:
        return '🚨';
      case SuggestionPriority.warning:
        return '⚠️';
      case SuggestionPriority.moderate:
        return '💡';
      case SuggestionPriority.info:
        return 'ℹ️';
    }
  }

  String get color {
    switch (this) {
      case SuggestionPriority.critical:
        return '#FF4444';
      case SuggestionPriority.warning:
        return '#FF8800';
      case SuggestionPriority.moderate:
        return '#FFCC00';
      case SuggestionPriority.info:
        return '#00CCFF';
    }
  }
}
