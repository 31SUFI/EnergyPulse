class BillCalculator {
  // Tariff rates for different customer types and billing periods
  static final Map<String, Map<String, List<Map<String, dynamic>>>> tariffRates = {
    'current': {  // Jul-Sep 2024
      'protected': [
        {'max': 50, 'rate': 3.95, 'fixedCharge': 0, 'type': 'Lifeline'},
        {'max': 100, 'rate': 7.74, 'fixedCharge': 0, 'type': 'Lifeline'},
        {'max': 100, 'rate': 7.74, 'fixedCharge': 0, 'type': 'Protected'},
        {'max': 200, 'rate': 10.06, 'fixedCharge': 0, 'type': 'Protected'},
      ],
      'unprotected': [
        {'max': 100, 'rate': 16.48, 'fixedCharge': 0},
        {'max': 200, 'rate': 22.95, 'fixedCharge': 0},
        {'max': 300, 'rate': 34.26, 'fixedCharge': 0},
        {'max': 400, 'rate': 39.15, 'fixedCharge': 200},
        {'max': 500, 'rate': 41.36, 'fixedCharge': 400},
        {'max': 600, 'rate': 42.78, 'fixedCharge': 600},
        {'max': 700, 'rate': 43.92, 'fixedCharge': 800},
        {'max': double.maxFinite, 'rate': 48.84, 'fixedCharge': 1000},
      ]
    },
    'future': {  // Oct 2024 onwards
      'protected': [
        {'max': 50, 'rate': 3.95, 'fixedCharge': 0, 'type': 'Lifeline'},
        {'max': 100, 'rate': 7.74, 'fixedCharge': 0, 'type': 'Lifeline'},
        {'max': 100, 'rate': 11.69, 'fixedCharge': 0, 'type': 'Protected'},
        {'max': 200, 'rate': 14.16, 'fixedCharge': 0, 'type': 'Protected'},
      ],
      'unprotected': [
        {'max': 100, 'rate': 23.59, 'fixedCharge': 0},
        {'max': 200, 'rate': 30.07, 'fixedCharge': 0},
        {'max': 300, 'rate': 34.26, 'fixedCharge': 0},
        {'max': 400, 'rate': 39.15, 'fixedCharge': 200},
        {'max': 500, 'rate': 41.36, 'fixedCharge': 400},
        {'max': 600, 'rate': 42.78, 'fixedCharge': 600},
        {'max': 700, 'rate': 43.92, 'fixedCharge': 800},
        {'max': double.maxFinite, 'rate': 48.84, 'fixedCharge': 1000},
      ]
    }
  };

  /// Calculate electricity bill based on input parameters
  /// 
  /// [isUnprotected] - Whether the customer is unprotected (true) or protected (false)
  /// [period] - Billing period ('current' for Jul-Sep 2024 or 'future' for Oct 2024 onwards)
  /// [units] - Number of units consumed
  /// 
  /// Returns a Map containing all bill details
  static Map<String, dynamic> calculateBill({
    required bool isUnprotected, 
    required String period, 
    required int units
  }) {
    // Validate input
    if (units < 0) {
      throw ArgumentError('Units consumed must be a non-negative value');
    }
    
    if (period != 'current' && period != 'future') {
      throw ArgumentError('Period must be either "current" or "future"');
    }

    // Get customer type
    final customerType = isUnprotected ? 'unprotected' : 'protected';
    
    // Get applicable rates based on customer type and period
    final rates = tariffRates[period]![customerType]!;
    
    // Find applicable slab based on units consumed
    Map<String, dynamic>? applicableSlab;
    
    // For lifeline consumers, need special handling
    if (customerType == 'protected' && units <= 100) {
      if (units <= 50) {
        applicableSlab = rates[0]; // 0-50 units lifeline
      } else {
        applicableSlab = rates[1]; // 51-100 units lifeline
      }
    } else {
      // Find the first slab where the units are less than or equal to the max
      for (var slab in rates) {
        if (units <= slab['max']) {
          applicableSlab = slab;
          break;
        }
      }
      
      // If no slab is found (which shouldn't happen due to max value), use the last slab
      if (applicableSlab == null) {
        applicableSlab = rates.last;
      }
    }

    // Calculate bill
    final energyCharges = units * applicableSlab['rate'];
    final fixedCharges = applicableSlab['fixedCharge'];
    final totalBill = energyCharges + fixedCharges;
    
    // Format the slab description
    String slabText;
    if (applicableSlab['max'] == double.maxFinite) {
      slabText = 'Above 700 Units';
    } else {
      slabText = 'Up to ${applicableSlab['max']} Units';
    }
    
    if (applicableSlab.containsKey('type')) {
      slabText += ' (${applicableSlab['type']})';
    }

    // Return results as a map
    return {
      'customerType': isUnprotected ? 'Unprotected' : 'Protected',
      'units': units,
      'slabDescription': slabText,
      'ratePerUnit': applicableSlab['rate'],
      'energyCharges': energyCharges,
      'fixedCharges': fixedCharges,
      'totalBill': totalBill,
      'slab': applicableSlab,
    };
  }

  /// Format the bill results as a string for display
  /// 
  /// [billDetails] - The bill details returned from calculateBill()
  /// [format] - Output format: 'full' (default), 'summary', 'json', or 'table'
  static String formatBillOutput(Map<String, dynamic> billDetails, {String format = 'full'}) {
    switch (format) {
      case 'summary':
        return 'Total Bill: Rs. ${billDetails['totalBill'].toStringAsFixed(2)} for ${billDetails['units']} units (${billDetails['customerType']} customer)';
      
      case 'json':
        return '''
{
  "customerType": "${billDetails['customerType']}",
  "units": ${billDetails['units']},
  "slabDescription": "${billDetails['slabDescription']}",
  "ratePerUnit": ${billDetails['ratePerUnit'].toStringAsFixed(2)},
  "energyCharges": ${billDetails['energyCharges'].toStringAsFixed(2)},
  "fixedCharges": ${billDetails['fixedCharges'].toStringAsFixed(2)},
  "totalBill": ${billDetails['totalBill'].toStringAsFixed(2)}
}''';
      
      case 'table':
        return '''
┌─────────────────────┬────────────────────────────────┐
│ Customer Type       │ ${billDetails['customerType'].padRight(28)} │
│ Units Consumed      │ ${billDetails['units'].toString().padRight(28)} │
│ Applicable Slab     │ ${billDetails['slabDescription'].padRight(28)} │
│ Rate per Unit       │ Rs. ${billDetails['ratePerUnit'].toStringAsFixed(2).padRight(24)} │
│ Energy Charges      │ Rs. ${billDetails['energyCharges'].toStringAsFixed(2).padRight(24)} │
│ Fixed Charges       │ Rs. ${billDetails['fixedCharges'].toStringAsFixed(2).padRight(24)} │
├─────────────────────┼────────────────────────────────┤
│ Total Bill Amount   │ Rs. ${billDetails['totalBill'].toStringAsFixed(2).padRight(24)} │
└─────────────────────┴────────────────────────────────┘''';
      
      case 'full':
      default:
        return '''
K-Electric Bill Details
----------------------
Customer Type: ${billDetails['customerType']}
Units Consumed: ${billDetails['units']}
Applicable Slab: ${billDetails['slabDescription']}
Rate per Unit: Rs. ${billDetails['ratePerUnit'].toStringAsFixed(2)}
Energy Charges: Rs. ${billDetails['energyCharges'].toStringAsFixed(2)}
Fixed Charges: Rs. ${billDetails['fixedCharges'].toStringAsFixed(2)}
----------------------
Total Bill Amount: Rs. ${billDetails['totalBill'].toStringAsFixed(2)}
''';
    }
  }
  
  /// Get a specific part of the bill details
  /// 
  /// [billDetails] - The bill details returned from calculateBill()
  /// [field] - The specific field to retrieve (e.g., 'totalBill', 'ratePerUnit', etc.)
  /// [formatted] - Whether to return a formatted string (with currency symbol if applicable)
  static dynamic getBillField(Map<String, dynamic> billDetails, String field, {bool formatted = true}) {
    if (!billDetails.containsKey(field)) {
      throw ArgumentError('Invalid field: $field');
    }
    
    final value = billDetails[field];
    
    // Format numeric values if requested
    if (formatted) {
      if (field == 'totalBill' || field == 'energyCharges' || field == 'fixedCharges') {
        return 'Rs. ${value.toStringAsFixed(2)}';
      } else if (field == 'ratePerUnit') {
        return 'Rs. ${value.toStringAsFixed(2)}';
      }
    }
    
    return value;
  }

  /// Print the billing tariff table for reference
  /// 
  /// [period] - Billing period ('current' for Jul-Sep 2024 or 'future' for Oct 2024 onwards)
  static String getTariffTable(String period) {
    if (period != 'current' && period != 'future') {
      throw ArgumentError('Period must be either "current" or "future"');
    }
    
    final periodLabel = period == 'current' ? 'Jul - Sep 2024' : 'Oct 2024 onwards';
    StringBuffer output = StringBuffer();
    
    output.writeln('K-Electric Residential Tariff ($periodLabel)');
    output.writeln('==============================================');
    
    // Protected rates
    output.writeln('\nProtected Customers:');
    output.writeln('--------------------');
    output.writeln('Units Consumed      Rate (Rs/Unit)    Fixed Charges');
    output.writeln('------------------------------------------------');
    
    for (var slab in tariffRates[period]!['protected']!) {
      String maxUnits;
      if (slab['max'] == 50) {
        maxUnits = '0-50 Units';
      } else if (slab['max'] == 100) {
        if (slab['type'] == 'Lifeline') {
          maxUnits = '51-100 Units';
        } else {
          maxUnits = '1-100 Units';
        }
      } else {
        maxUnits = '101-${slab['max']} Units';
      }
      
      String typeInfo = slab.containsKey('type') ? ' (${slab['type']})' : '';
      output.writeln('${(maxUnits + typeInfo).padRight(20)}${slab['rate'].toStringAsFixed(2).padRight(18)}${slab['fixedCharge']}');
    }
    
    // Unprotected rates
    output.writeln('\nUnprotected Customers:');
    output.writeln('----------------------');
    output.writeln('Units Consumed      Rate (Rs/Unit)    Fixed Charges');
    output.writeln('------------------------------------------------');
    
    for (var i = 0; i < tariffRates[period]!['unprotected']!.length; i++) {
      var slab = tariffRates[period]!['unprotected']![i];
      String maxUnits;
      
      if (i == 0) {
        maxUnits = '1-${slab['max']} Units';
      } else if (i == tariffRates[period]!['unprotected']!.length - 1) {
        maxUnits = 'Above 700 Units';
      } else {
        var prevMax = tariffRates[period]!['unprotected']![i-1]['max'];
        maxUnits = '${prevMax+1}-${slab['max']} Units';
      }
      
      output.writeln('${maxUnits.padRight(20)}${slab['rate'].toStringAsFixed(2).padRight(18)}${slab['fixedCharge']}');
    }
    
    return output.toString();
  }

  /// Example usage of the calculator
  static void example() {
    print('Example Bill Calculation:');
    print('-----------------------');
    
    // Calculate bill for protected customer with 150 units in current period
    var billDetails = calculateBill(isUnprotected: false, period: 'current', units: 150);
    print(formatBillOutput(billDetails));
    
    // Get specific fields
    print('\nAccessing specific fields:');
    print('Total Bill: ${getBillField(billDetails, 'totalBill')}');
    print('Rate per Unit: ${getBillField(billDetails, 'ratePerUnit')}');
    
    // Different output formats
    print('\nSummary format:');
    print(formatBillOutput(billDetails, format: 'summary'));
    
    print('\nTable format:');
    print(formatBillOutput(billDetails, format: 'table'));
    
    // Show tariff table
    print('\n${getTariffTable("current")}');
  }
}

// Uncomment this to run example usage
// void main() {
//   BillCalculator.example();
// }
