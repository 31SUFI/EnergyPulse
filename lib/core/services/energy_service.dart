import 'package:firebase_auth/firebase_auth.dart';

import 'bill_calculator_service.dart';
import 'package:firebase_database/firebase_database.dart';
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

  double get totalEnergy => _totalEnergy;
  bool get isProtected => _isProtected;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get householdId => _householdId;
  String get propertyType => _propertyType;

  /// Calculates the estimated bill based on the current energy consumption.
  double get estimatedBill {
    final billDetails = BillCalculator.calculateBill(
      isUnprotected: !_isProtected, 
      period: 'current', // Defaulting to 'current' period
      units: _totalEnergy.toInt(),
    );
    return billDetails['totalBill'];
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
            _userEmail = data['email'] as String? ?? "UserEmail                                                               ";
            _householdId = data['houseId'] as String? ?? "HouseholdId";
            _propertyType = data['propertyType'] as String? ?? "PropertyType";
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
          _isProtected = data['protected'] as bool? ?? true;
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
}
