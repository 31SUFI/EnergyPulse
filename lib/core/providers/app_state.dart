import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // Weather data
  Map<String, dynamic> _weatherData = {};
  Map<String, dynamic> get weatherData => _weatherData;
  
  // Energy usage data
  double _todayUsage = 0.0;
  double get todayUsage => _todayUsage;
  
  // Spaces data
  List<Map<String, dynamic>> _spaces = [];
  List<Map<String, dynamic>> get spaces => _spaces;
  
  void updateWeatherData(Map<String, dynamic> data) {
    _weatherData = data;
    notifyListeners();
  }
  
  void updateTodayUsage(double usage) {
    _todayUsage = usage;
    notifyListeners();
  }
  
  void updateSpaces(List<Map<String, dynamic>> spaces) {
    _spaces = spaces;
    notifyListeners();
  }
}
