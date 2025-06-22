class BillCalculatorService {
  /// Calculates the estimated bill based on consumed units and protection status.
  static double calculateBill(double consumedUnits, bool isProtected) {
    if (consumedUnits <= 0) return 0;

    return isProtected
        ? _calculateProtectedBill(consumedUnits)
        : _calculateUnprotectedBill(consumedUnits);
  }

  /// Calculates bill for protected customers (telescopic rates).
  static double _calculateProtectedBill(double units) {
    double cost = 0;

    if (units > 0) {
      final slab1Units = units > 50 ? 50.0 : units;
      cost += slab1Units * 3.95;
    }
    if (units > 50) {
      final slab2Units = units > 100 ? 50.0 : units - 50;
      cost += slab2Units * 7.74;
    }
    if (units > 100) {
      final slab3Units = units > 200 ? 100.0 : units - 100;
      cost += slab3Units * 10.06;
    }

    return cost;
  }

  /// Calculates bill for unprotected customers (telescopic rates + fixed charges).
  static double _calculateUnprotectedBill(double units) {
    double cost = 0;
    double fixedCharge = 0;

    if (units > 0) {
      final slab1Units = units > 100 ? 100.0 : units;
      cost += slab1Units * 23.59;
    }
    if (units > 100) {
      final slab2Units = units > 200 ? 100.0 : units - 100;
      cost += slab2Units * 30.07;
    }
    if (units > 200) {
      final slab3Units = units > 300 ? 100.0 : units - 200;
      cost += slab3Units * 34.26;
    }
    if (units > 300) {
      final slab4Units = units > 400 ? 100.0 : units - 300;
      cost += slab4Units * 39.15;
      fixedCharge = 200;
    }
    if (units > 400) {
      final slab5Units = units > 500 ? 100.0 : units - 400;
      cost += slab5Units * 41.36;
      fixedCharge = 400;
    }
    if (units > 500) {
      final slab6Units = units > 600 ? 100.0 : units - 500;
      cost += slab6Units * 42.78;
      fixedCharge = 600;
    }
    if (units > 600) {
      final slab7Units = units > 700 ? 100.0 : units - 600;
      cost += slab7Units * 43.92;
      fixedCharge = 800;
    }
    if (units > 700) {
      final slab8Units = units - 700;
      cost += slab8Units * 48.84;
      fixedCharge = 1000;
    }

    return cost + fixedCharge;
  }
}
