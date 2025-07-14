import 'package:firebase_auth/firebase_auth.dart';

import 'bill_calculator_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'energy_suggestion_service.dart';
import 'package:flutter/material.dart';

class EnergyService with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('readings');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _totalEnergy = 0.0;
  bool _isProtected = true; // Default value
  String _userName = "User";
  String _userEmail = "UserEmail";
  String _householdId = "HouseholdId";
  String _propertyType = "PropertyType";
  double _voltage = 0.0;
  double _current = 0.0;

  double get totalEnergy => _totalEnergy;
  double get voltage => _voltage;
  double get current => _current;
  bool get isProtected => _isProtected;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get householdId => _householdId;
  String get propertyType => _propertyType;

  /// Returns the full details of the calculated bill.
  Map<String, dynamic> get billDetails {
    return BillCalculator.calculateBill(
      isUnprotected: !_isProtected,
      period: 'current', // Defaulting to 'current' period
      units: _totalEnergy.toInt(),
    );
  }

  /// Calculates the estimated bill amount for convenience.
  double get estimatedBill {
    return billDetails['totalBill'] ?? 0.0;
  }

  EnergyService() {
    _listenToEnergyData();
    _listenToUserData();
  }

  void _listenToUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      userRef.onValue.listen(
        (event) {
          if (event.snapshot.exists && event.snapshot.value != null) {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            _userName = data['name'] as String? ?? "User";
            _userEmail =
                data['email'] as String? ??
                "UserEmail                                                               ";
            _householdId = data['houseId'] as String? ?? "HouseholdId";
            _propertyType = data['propertyType'] as String? ?? "PropertyType";
            _isProtected = data['protected'] as bool? ?? true;

            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint("Error listening to user data: $error");
        },
      );
    }
  }

  void _listenToEnergyData() {
    _dbRef.onValue.listen(
      (event) {
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          _totalEnergy = (data['energy'] as num?)?.toDouble() ?? 0.0;
          _voltage = (data['voltage'] as num?)?.toDouble() ?? 0.0;
          _current = (data['current'] as num?)?.toDouble() ?? 0.0;
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint("Error listening to energy data: $error");
      },
    );
  }

  Future<void> updateEnergyReading(Map<String, dynamic> reading) async {
    await _dbRef.update(reading);
  }

  /// Fetch historical daily kWh data from the 'history/days' node in Firebase.
  /// Returns a map of date (YYYYMMDD) to daily_kwh value.
  Future<Map<String, double>> fetchHistoricalDailyKwh() async {
    final historyRef = FirebaseDatabase.instance.ref('history/days');
    final snapshot = await historyRef.get();
    if (!snapshot.exists || snapshot.value == null) return {};
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final Map<String, double> dailyKwh = {};
    data.forEach((date, value) {
      if (value is Map && value['e'] != null) {
        final kwh = (value['e'] as num?)?.toDouble();
        if (kwh != null) {
          dailyKwh[date] = kwh;
        }
      }
    });
    debugPrint('Fetched e data: ' + dailyKwh.toString());
    return dailyKwh;
  }

  Future<List<EnergySuggestion>> getEnergySuggestions({
    required double monthlyLimit,
  }) async {
    try {
      // Use the live total energy reading as the primary source for current usage.
      final double currentUsage = _totalEnergy;

      debugPrint('[EnergyService] Generating suggestions with Current Usage: $currentUsage kWh and Monthly Limit: $monthlyLimit kWh');

      // Fetch historical data for pattern analysis, but don't use it for the current usage total.
      final dailyUsageData = await fetchHistoricalDailyKwh();
      final List<double> allUsageValues = dailyUsageData.values.toList();

      // Instantiate the suggestion service and generate suggestions
      final suggestionService = EnergySuggestionService();
      final suggestions = suggestionService.generateSuggestions(
        currentUsage: currentUsage,
        monthlyLimit: monthlyLimit,
        dailyUsage: allUsageValues, // Full history for pattern analysis
        isProtected: _isProtected,
      );

      debugPrint('[EnergyService] Generated ${suggestions.length} suggestions.');
      return suggestions;
    } catch (e, stackTrace) {
      debugPrint('Error getting energy suggestions: $e');
      debugPrint('Stack trace: $stackTrace');
      return []; // Return empty list on error
    }
  }
}
