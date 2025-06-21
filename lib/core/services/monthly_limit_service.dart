import 'package:firebase_database/firebase_database.dart';

class MonthlyLimitService {
  final DatabaseReference _readingsRef =
      FirebaseDatabase.instance.ref().child('readings');

  Future<double?> getMonthlyLimit() async {
    final snapshot = await _readingsRef.child('monthly_limit').get();
    if (snapshot.exists) {
      return double.tryParse(snapshot.value.toString());
    }
    return null;
  }

  Future<void> setMonthlyLimit(double limit) async {
    await _readingsRef.child('monthly_limit').set(limit);
  }

  // Real-time stream for monthly limit
  Stream<double> getMonthlyLimitStream() {
    return _readingsRef.child('monthly_limit').onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    });
  }
}
