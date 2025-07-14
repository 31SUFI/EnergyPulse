import 'package:energy_meter_app/features/home_screen/providers/monthly_limit_provider.dart';
import 'package:flutter/material.dart';
import '../../../core/services/energy_service.dart';
import '../model/suggestion_model.dart';

class SuggestionProvider extends ChangeNotifier {
  EnergyService _energyService;
  MonthlyLimitProvider _monthlyLimitProvider;

  bool _isLoading = false;
  bool _isPanelVisible = false;
  List<Suggestion> _suggestions = [];

  SuggestionProvider(this._energyService, this._monthlyLimitProvider) {

    fetchSuggestions();
  }

  bool get isLoading => _isLoading;
  bool get isPanelVisible => _isPanelVisible;
  List<Suggestion> get suggestions => _suggestions;

  // Allows providers to be updated via ProxyProvider
  void update(EnergyService energyService, MonthlyLimitProvider monthlyLimitProvider) {
    _energyService = energyService;
    _monthlyLimitProvider = monthlyLimitProvider;
    fetchSuggestions(); // Re-fetch suggestions when dependencies change
  }

  Future<void> fetchSuggestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final monthlyLimit = _monthlyLimitProvider.limit;
      final newSuggestions = await _energyService.getEnergySuggestions(
        monthlyLimit: monthlyLimit,
      );
      _suggestions = newSuggestions
          .map((serviceSuggestion) =>
              Suggestion.fromEnergySuggestion(serviceSuggestion))
          .toList();
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      _suggestions = [];
    } finally {
      _isLoading = false;
      if (_suggestions.isEmpty) {
        _isPanelVisible = false;
      }
      notifyListeners();
    }
  }

  void dismissSuggestion(Suggestion suggestion) {
    _suggestions.remove(suggestion);
    if (_suggestions.isEmpty) {
      _isPanelVisible = false;
    }
    notifyListeners();
  }

  void togglePanel() {
    if (_suggestions.isNotEmpty) {
      _isPanelVisible = !_isPanelVisible;
      notifyListeners();
    }
  }
}
