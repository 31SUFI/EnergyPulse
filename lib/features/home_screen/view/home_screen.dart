import 'package:energy_meter_app/features/suggestions/provider/suggestion_provider.dart';
import 'package:energy_meter_app/features/suggestions/widgets/suggestion_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state.dart';
import '../widgets/greeting_card.dart';
import '../widgets/monthly_limit_card.dart';
import '../widgets/my_spaces.dart';
import '../widgets/today_usage_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestionProvider = context.watch<SuggestionProvider>();
    final suggestion = suggestionProvider.suggestion;

    return Consumer<AppState>(
      builder: (context, appState, _) => SingleChildScrollView(
        child: Column(
          children: [
            const GreetingCard(),
            const SizedBox(height: 16),
            if (suggestion != null)
              SuggestionCard(
                suggestion: suggestion,
                onApply: () {
                  suggestionProvider.applySuggestion(context);
                },
              ),
            const MonthlyLimitCard(),
            const SizedBox(height: 16),
            const TodayUsageCard(),
            const SizedBox(height: 16),
            const MySpaces(),
          ],
        ),
      ),
    );
  }
}
