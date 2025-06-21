import 'package:flutter/material.dart';
import '../services/monthly_limit_service.dart';

class MonthlyLimitProvider with ChangeNotifier {
  double? _limit;
  bool _isLoading = false;

  double? get limit => _limit;
  bool get isLoading => _isLoading;

  MonthlyLimitProvider() {
    fetchLimit();
  }

  Future<void> fetchLimit() async {
    _isLoading = true;
    notifyListeners();
    _limit = await MonthlyLimitService().getMonthlyLimit();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLimit(double newLimit) async {
    _isLoading = true;
    notifyListeners();
    await MonthlyLimitService().setMonthlyLimit(newLimit);
    _limit = newLimit;
    _isLoading = false;
    notifyListeners();
  }
}
