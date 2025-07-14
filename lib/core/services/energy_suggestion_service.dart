import 'package:flutter/foundation.dart';

/// Service for generating intelligent energy-saving suggestions
/// based on current usage patterns and monthly limits
class EnergySuggestionService with ChangeNotifier {
  // Thresholds for different suggestion types
  static const double _criticalThreshold = 0.9; // 90% of limit
  static const double _warningThreshold = 0.7; // 70% of limit
  static const double _moderateThreshold = 0.5; // 50% of limit

  /// Generate suggestions based on current usage and limit
  List<EnergySuggestion> generateSuggestions({
    required double currentUsage,
    required double monthlyLimit,
    required List<double> dailyUsage,
    required bool isProtected,
  }) {
    final List<EnergySuggestion> suggestions = [];

    // First, check if the limit has actually been exceeded.
    if (currentUsage >= monthlyLimit) {
      suggestions.add(
        EnergySuggestion(
          title: '🚨 Critical: Limit Exceeded',
          description:
              'You have exceeded your monthly limit of ${monthlyLimit.toStringAsFixed(0)} kWh. Immediate action required.',
          priority: SuggestionPriority.critical,
          estimatedSavings: 15.0,
          actions: [
            'Turn off non-essential devices immediately',
            'Reduce AC usage by 2-3 hours daily',
          ],
          timeRecommendation: 'Immediate',
        ),
      );
    } else {
      // If the limit is not exceeded, proceed with percentage-based suggestions.
      final double usagePercentage = currentUsage / monthlyLimit;
      final int daysRemaining = _calculateDaysRemaining();
      final double averageDailyUsage = _calculateAverageDailyUsage(dailyUsage);
      final double projectedUsage = _calculateProjectedUsage(
        currentUsage,
        averageDailyUsage,
        daysRemaining,
      );

      // Critical suggestions (90%+ of limit)
      if (usagePercentage >= _criticalThreshold) {
        suggestions.addAll(
          _generateCriticalSuggestions(
            currentUsage,
            monthlyLimit,
            projectedUsage,
            isProtected,
          ),
        );
      }
      // Warning suggestions (70%+ of limit)
      else if (usagePercentage >= _warningThreshold) {
        suggestions.addAll(
          _generateWarningSuggestions(
            currentUsage,
            monthlyLimit,
            projectedUsage,
            isProtected,
          ),
        );
      }
      // Moderate suggestions (50%+ of limit)
      else if (usagePercentage >= _moderateThreshold) {
        suggestions.addAll(
          _generateModerateSuggestions(
            currentUsage,
            monthlyLimit,
            projectedUsage,
            isProtected,
          ),
        );
      }
      // General suggestions (below 50%)
      else {
        suggestions.addAll(
          _generateGeneralSuggestions(
            currentUsage,
            monthlyLimit,
            projectedUsage,
            isProtected,
          ),
        );
      }
    }

    // Add time-based suggestions
    suggestions.addAll(
      _generateTimeBasedSuggestions(currentUsage, monthlyLimit, dailyUsage),
    );

    // Add device-specific suggestions
    suggestions.addAll(
      _generateDeviceSpecificSuggestions(
        currentUsage,
        monthlyLimit,
        isProtected,
      ),
    );

    return suggestions;
  }

  /// Generate critical suggestions for high usage
  List<EnergySuggestion> _generateCriticalSuggestions(
    double currentUsage,
    double monthlyLimit,
    double projectedUsage,
    bool isProtected,
  ) {
    return [
      EnergySuggestion(
        title: '🚨 Critical: Approaching Limit',
        description:
            'You have used over 90% of your monthly limit. Immediate action is recommended to avoid exceeding it.',
        priority: SuggestionPriority.critical,
        estimatedSavings: 15.0,
        actions: [
          'Turn off non-essential devices immediately',
          'Reduce AC usage by 2-3 hours daily',
          'Switch to energy-saving mode on all devices',
          'Consider using natural ventilation',
        ],
        timeRecommendation: 'Immediate',
      ),
      EnergySuggestion(
        title: '⚡ Emergency Power Management',
        description:
            'Switch to essential devices only to avoid additional charges.',
        priority: SuggestionPriority.critical,
        estimatedSavings: 25.0,
        actions: [
          'Keep only refrigerator and essential lights on',
          'Turn off all entertainment devices',
          'Reduce water heater usage',
          'Use ceiling fans instead of AC',
        ],
        timeRecommendation: 'Next 24 hours',
      ),
    ];
  }

  /// Generate warning suggestions for approaching limit
  List<EnergySuggestion> _generateWarningSuggestions(
    double currentUsage,
    double monthlyLimit,
    double projectedUsage,
    bool isProtected,
  ) {
    return [
      EnergySuggestion(
        title: '⚠️ Approaching Monthly Limit',
        description: 'You are close to exceeding your monthly energy limit.',
        priority: SuggestionPriority.warning,
        estimatedSavings: 10.0,
        actions: [
          'Reduce AC usage by 1-2 hours daily',
          'Turn off devices when not in use',
          'Use energy-efficient lighting',
          'Optimize refrigerator settings',
        ],
        timeRecommendation: 'Next 3 days',
      ),
      EnergySuggestion(
        title: '🌡️ Smart Temperature Management',
        description:
            'Optimize your AC and heating usage to stay within limits.',
        priority: SuggestionPriority.warning,
        estimatedSavings: 8.0,
        actions: [
          'Set AC temperature to 24-26°C',
          'Use programmable thermostat',
          'Close curtains during peak hours',
          'Maintain AC filters regularly',
        ],
        timeRecommendation: 'Daily',
      ),
    ];
  }

  /// Generate moderate suggestions for medium usage
  List<EnergySuggestion> _generateModerateSuggestions(
    double currentUsage,
    double monthlyLimit,
    double projectedUsage,
    bool isProtected,
  ) {
    return [
      EnergySuggestion(
        title: '💡 Energy Optimization Tips',
        description: 'Small changes can lead to significant savings.',
        priority: SuggestionPriority.moderate,
        estimatedSavings: 5.0,
        actions: [
          'Use LED bulbs throughout the house',
          'Unplug chargers when not in use',
          'Wash clothes in cold water',
          'Use microwave instead of oven when possible',
        ],
        timeRecommendation: 'Weekly',
      ),
      EnergySuggestion(
        title: '📱 Smart Device Management',
        description: 'Optimize your smart devices for better efficiency.',
        priority: SuggestionPriority.moderate,
        estimatedSavings: 3.0,
        actions: [
          'Enable power-saving modes',
          'Schedule device usage during off-peak hours',
          'Use smart plugs for automation',
          'Monitor device energy consumption',
        ],
        timeRecommendation: 'Daily',
      ),
    ];
  }

  /// Generate general suggestions for low usage
  List<EnergySuggestion> _generateGeneralSuggestions(
    double currentUsage,
    double monthlyLimit,
    double projectedUsage,
    bool isProtected,
  ) {
    return [
      EnergySuggestion(
        title: '✅ Great Energy Management!',
        description:
            'You are well within your monthly limit. Keep up the good work!',
        priority: SuggestionPriority.info,
        estimatedSavings: 2.0,
        actions: [
          'Continue current energy-saving habits',
          'Consider renewable energy options',
          'Share tips with family members',
          'Monitor usage patterns regularly',
        ],
        timeRecommendation: 'Ongoing',
      ),
    ];
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
          title: '⏰ Peak Hours Alert',
          description:
              'Energy rates are higher during peak hours. Consider delaying non-essential usage.',
          priority: SuggestionPriority.warning,
          estimatedSavings: 5.0,
          actions: [
            'Delay laundry until after 10 PM',
            'Use dishwasher during off-peak hours',
            'Reduce AC usage during peak hours',
            'Charge devices during off-peak hours',
          ],
          timeRecommendation: '6 PM - 10 PM daily',
        ),
      );
    }

    // Night suggestions (10 PM - 6 AM)
    if (hour >= 22 || hour <= 6) {
      suggestions.add(
        EnergySuggestion(
          title: '🌙 Night Mode Recommendations',
          description: 'Optimize energy usage during night hours.',
          priority: SuggestionPriority.info,
          estimatedSavings: 3.0,
          actions: [
            'Use night mode on devices',
            'Reduce lighting to essential areas',
            'Set devices to sleep mode',
            'Use energy-efficient night lights',
          ],
          timeRecommendation: '10 PM - 6 AM',
        ),
      );
    }

    return suggestions;
  }

  /// Generate device-specific suggestions
  List<EnergySuggestion> _generateDeviceSpecificSuggestions(
    double currentUsage,
    double monthlyLimit,
    bool isProtected,
  ) {
    return [
      EnergySuggestion(
        title: '🏠 Smart Home Optimization',
        description: 'Optimize your smart home devices for maximum efficiency.',
        priority: SuggestionPriority.moderate,
        estimatedSavings: 7.0,
        actions: [
          'Set smart thermostat to energy-saving mode',
          'Configure smart plugs with usage schedules',
          'Enable motion sensors for lighting',
          'Use smart blinds to regulate temperature',
        ],
        timeRecommendation: 'Setup once, ongoing benefits',
      ),
      EnergySuggestion(
        title: '🔌 Appliance Efficiency',
        description:
            'Optimize your major appliances for better energy efficiency.',
        priority: SuggestionPriority.moderate,
        estimatedSavings: 6.0,
        actions: [
          'Clean refrigerator coils monthly',
          'Use energy-efficient washing machine settings',
          'Maintain AC filters regularly',
          'Defrost freezer when ice builds up',
        ],
        timeRecommendation: 'Monthly maintenance',
      ),
    ];
  }

  /// Calculate remaining days in the month
  int _calculateDaysRemaining() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.day - now.day;
  }

  /// Calculate average daily usage
  double _calculateAverageDailyUsage(List<double> dailyUsage) {
    if (dailyUsage.isEmpty) return 0.0;
    final sum = dailyUsage.reduce((a, b) => a + b);
    return sum / dailyUsage.length;
  }

  /// Calculate projected usage for the month
  double _calculateProjectedUsage(
    double currentUsage,
    double averageDailyUsage,
    int daysRemaining,
  ) {
    return currentUsage + (averageDailyUsage * daysRemaining);
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

  EnergySuggestion({
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedSavings,
    required this.actions,
    required this.timeRecommendation,
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
