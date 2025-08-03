/// Model for energy suggestions, aligned with EnergySuggestionService.
class Suggestion {
  final String title;
  final String description;
  final SuggestionPriority priority;
  final double estimatedSavings;
  final List<String> actions;
  final String timeRecommendation;
  final Map<String, dynamic>? schedulePayload;

  Suggestion({
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedSavings,
    required this.actions,
    required this.timeRecommendation,
    this.schedulePayload,
  });

  // Factory constructor to create a Suggestion from an EnergySuggestion
  factory Suggestion.fromEnergySuggestion(dynamic energySuggestion) {
    // A bit of a hack to handle the type from a different library
    // In a real app, these models would be shared.
    return Suggestion(
      title: energySuggestion.title,
      description: energySuggestion.description,
      priority: SuggestionPriority.values.firstWhere(
        (e) => e.toString() == energySuggestion.priority.toString(),
      ),
      estimatedSavings: energySuggestion.estimatedSavings,
      actions: List<String>.from(energySuggestion.actions),
      timeRecommendation: energySuggestion.timeRecommendation,
      schedulePayload: energySuggestion.schedulePayload,
    );
  }
}

/// Priority levels for suggestions, mirroring the service layer.
enum SuggestionPriority { critical, warning, moderate, info }
