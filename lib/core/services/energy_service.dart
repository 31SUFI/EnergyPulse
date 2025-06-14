import 'package:firebase_database/firebase_database.dart';

class EnergyService {
  final DatabaseReference _readingsRef = FirebaseDatabase.instance.ref('readings');

  Stream<Map<String, dynamic>> getEnergyReadings() {
    return _readingsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return Map<String, dynamic>.from(data as Map);
      }
      return {};
    });
  }

  Future<void> updateEnergyReading(Map<String, dynamic> reading) async {
    await _readingsRef.update(reading);
  }
}
