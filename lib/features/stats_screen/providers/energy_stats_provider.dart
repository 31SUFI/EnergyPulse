import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../home_screen/model/space_model.dart';
import '../models/device_usage_model.dart';
import '../../../core/config/device_config.dart';
import 'package:collection/collection.dart';

class EnergyStatsProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref('relays');
  final Map<String, double> _energyData = {};
  bool _isLoading = true;
  StreamSubscription<DatabaseEvent>? _subscription;
  String? _error;

  Map<String, double> get energyData => Map.unmodifiable(_energyData);
  bool get isLoading => _isLoading;
  String? get error => _error;

  EnergyStatsProvider() {
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeListener() {
    print('Setting up real-time listener...');
    try {
      _subscription = _database.onValue.listen(
        _handleDataUpdate,
        onError: _handleError,
        cancelOnError: false,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleDataUpdate(DatabaseEvent event) {
    try {
      print('Received data from Firebase');
      final data = event.snapshot.value;
      
      if (data == null) {
        print('No data received from Firebase');
        _error = 'No data available';
        _updateLoadingState();
        return;
      }
      
      if (data is! Map) {
        print('Unexpected data format from Firebase: ${data.runtimeType}');
        _error = 'Invalid data format';
        _updateLoadingState();
        return;
      }
      
      print('Processing relay data...');
      final relayData = Map<String, dynamic>.from(data);
      _updateEnergyData(relayData);
    } catch (e) {
      _handleError(e);
    }
  }
  
  void _handleError(Object error) {
    print('Error in Firebase listener: $error');
    _error = 'Failed to load energy data';
    _updateLoadingState();
  }
  
  void _updateLoadingState() {
    _isLoading = false;
    notifyListeners();
  }

  void _updateEnergyData(Map<String, dynamic> relayData) {
    print('Updating energy data with ${relayData.length} relays');
    
    // Create a new map to store updated values
    final updatedData = <String, double>{};
    
    relayData.forEach((relayId, relayInfo) {
      try {
        if (relayInfo is! Map) {
          print('Skipping non-map relay data for $relayId');
          return;
        }
        
        final relayMap = Map<String, dynamic>.from(relayInfo);
        if (!relayMap.containsKey('energy')) {
          print('No energy data for relay $relayId');
          return;
        }
        
        final energyValue = relayMap['energy'];
        final energy = double.tryParse(energyValue.toString()) ?? 0.0;
        
        // Only update if the value has changed
        if (_energyData[relayId] != energy) {
          updatedData[relayId] = energy;
          print('Updated relay $relayId energy: $energy');
        }
      } catch (e) {
        print('Error processing relay $relayId: $e');
      }
    });
    
    // Only update if we have changes
    if (updatedData.isNotEmpty) {
      _energyData.addAll(updatedData);
      print('Updated ${updatedData.length} energy values');
      _updateLoadingState();
    } else {
      print('No energy value updates');
    }
  }

  // Map relay IDs to device IDs based on their position in the room's device list
  String _getDeviceIdForRelay(String relayId, List<DeviceInfo> deviceInfos) {
    // Try to parse the relay number (e.g., 'relay1' -> 1)
    final relayNumber = int.tryParse(relayId.replaceAll('relay', ''));
    
    // If we can't parse the number or it's out of bounds, return the original ID
    if (relayNumber == null || relayNumber < 1 || relayNumber > deviceInfos.length) {
      return relayId;
    }
    
    // Return the corresponding device ID (1-based index to 0-based list)
    return deviceInfos[relayNumber - 1].id;
  }

  RoomStats getRoomStats(Space space) {
    try {
      if (_error != null) {
        print('Error state: $_error');
      }
      
      // Get devices for this space
      final deviceInfos = DeviceConfig.getDevicesForSpace(space.name, space.category);
      
      if (deviceInfos.isEmpty) {
        print('No devices found for space: ${space.name}');
        return RoomStats(
          roomName: space.name,
          devices: [],
          totalUsage: 0,
          estimatedCost: 0,
        );
      }
      
      print('Found ${deviceInfos.length} devices for space ${space.name}');
      print('Available energy data: $_energyData');
      
      // Create a map of device ID to energy usage
      final deviceEnergyMap = <String, double>{};
      
      // Map relay data to devices
      _energyData.forEach((relayId, energy) {
        final deviceId = _getDeviceIdForRelay(relayId, deviceInfos);
        if (deviceInfos.any((device) => device.id == deviceId)) {
          deviceEnergyMap[deviceId] = energy;
          print('Mapped relay $relayId to device $deviceId with energy $energy');
        }
      });
      
      // Create device usages with real-time energy data
      final devices = deviceInfos.map((deviceInfo) {
        final energy = deviceEnergyMap[deviceInfo.id] ?? 0.0;
        
        // Find the current mode if available
        String? currentMode;
        if (deviceInfo.supportedModes.isNotEmpty) {
          currentMode = deviceInfo.supportedModes.firstOrNull;
        }
        
        print('Device ${deviceInfo.name} (ID: ${deviceInfo.id}) - Energy: $energy');
        
        return DeviceUsage(
          deviceName: deviceInfo.name,
          deviceIcon: deviceInfo.icon,
          usage: energy,
          currentMode: currentMode,
        );
      }).toList();

      final totalUsage = devices.fold<double>(
        0,
        (sum, device) => sum + device.usage,
      );
      
      print('Total usage for ${space.name}: $totalUsage kWh');

      return RoomStats(
        roomName: space.name,
        devices: devices,
        totalUsage: totalUsage,
        estimatedCost: totalUsage * 0.25, // $0.25 per kWh
      );
    } catch (e, stackTrace) {
      print('Error in getRoomStats: $e');
      print('Stack trace: $stackTrace');
      return RoomStats(
        roomName: space.name,
        devices: [],
        totalUsage: 0,
        estimatedCost: 0,
      );
    }
  }
}
