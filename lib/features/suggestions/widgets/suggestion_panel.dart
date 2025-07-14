import 'package:energy_meter_app/core/constants/app_colors.dart';
import 'package:energy_meter_app/features/suggestions/provider/suggestion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:energy_meter_app/features/suggestions/widgets/suggestion_card.dart';

class SuggestionPanel extends StatelessWidget {
  const SuggestionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestionProvider = context.watch<SuggestionProvider>();
    final suggestions = suggestionProvider.suggestions;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Energy Saving Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    suggestionProvider.togglePanel();
                  },
                ),
              ],
            ),
          ),
          if (suggestionProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (suggestions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No suggestions at the moment. Great job!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ),
            )
          else
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4, // Max 40% of screen height
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return SuggestionCard(
                    suggestion: suggestion,
                    onDismiss: () {
                      suggestionProvider.dismissSuggestion(suggestion);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
