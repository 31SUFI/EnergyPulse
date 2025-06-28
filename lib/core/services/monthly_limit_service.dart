import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MonthlyLimitService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');

  DatabaseReference? _getUserLimitRef() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _usersRef.child(user.uid).child('monthly_limit');
  }

  Future<double?> getMonthlyLimit() async {
    final ref = _getUserLimitRef();
    if (ref == null) return null;

    final snapshot = await ref.get();
    if (snapshot.exists) {
      return double.tryParse(snapshot.value.toString());
    }
    return null;
  }

  Future<void> setMonthlyLimit(double limit) async {
    final ref = _getUserLimitRef();
    if (ref != null) {
      await ref.set(limit);
    }
  }

  // Real-time stream for monthly limit
  Stream<double> getMonthlyLimitStream() {
    final ref = _getUserLimitRef();
    if (ref == null) {
      return Stream.value(0.0); // Return a default value if no user is logged in
    }
    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    });
  }
}
