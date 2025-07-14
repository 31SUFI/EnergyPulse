import 'package:energy_meter_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../model/suggestion_model.dart';

class SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  final VoidCallback onDismiss;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.onDismiss,
  });

  // Helper to get color and icon based on priority
  _PriorityTheme _getPriorityTheme(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.critical:
        return _PriorityTheme(AppColors.error, Icons.error_outline);
      case SuggestionPriority.warning:
        return _PriorityTheme(AppColors.warning, Icons.warning_amber_rounded);
      case SuggestionPriority.moderate:
        return _PriorityTheme(AppColors.info, Icons.lightbulb_outline);
      case SuggestionPriority.info:
        return _PriorityTheme(AppColors.success, Icons.check_circle_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getPriorityTheme(suggestion.priority);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(theme.icon, color: theme.color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suggestion.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showActionsDialog(context, suggestion, theme),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Actions'),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionsDialog(
      BuildContext context, Suggestion suggestion, _PriorityTheme theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Row(
            children: [
              Icon(theme.icon, color: theme.color),
              const SizedBox(width: 8),
              Expanded(child: Text(suggestion.title)),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: suggestion.actions
                  .map((action) => ListTile(
                        leading: const Icon(Icons.arrow_right, color: AppColors.textSecondary),
                        title: Text(action),
                      ))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Dismiss Tip'),
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss(); // Call the original dismiss callback
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// A simple class to hold theme data for different priorities
class _PriorityTheme {
  final Color color;
  final IconData icon;
  _PriorityTheme(this.color, this.icon);
}
