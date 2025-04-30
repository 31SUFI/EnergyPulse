import 'dart:math' as math;
import '../../../core/config/device_config.dart';
import '../../home_screen/model/space_model.dart';

class DeviceUsage {
  final String deviceName;
  final String deviceIcon;
  final double usage; // in kWh
  final String? currentMode;

  DeviceUsage({
    required this.deviceName,
    required this.deviceIcon,
    required this.usage,
    this.currentMode,
  });
}

class RoomStats {
  final String roomName;
  final List<DeviceUsage> devices;
  final double totalUsage;
  final double estimatedCost;

  RoomStats({
    required this.roomName,
    required this.devices,
    required this.totalUsage,
    required this.estimatedCost,
  });

  // Generate random but consistent stats for a space
  static RoomStats getStatsForSpace(Space space) {
    final random = math.Random(space.name.hashCode); // Use consistent seed for same room
    
    // Get devices from central config
    final deviceInfos = DeviceConfig.getDevicesForSpace(space.name, space.category);
    
    final devices = deviceInfos.map((deviceInfo) {
      final usage = (random.nextDouble() * 8 + 2).roundToDouble(); // 2-10 kWh
      String? currentMode;
      
      // If device has modes, randomly select one
      if (deviceInfo.supportedModes.isNotEmpty) {
        currentMode = deviceInfo.supportedModes[
          random.nextInt(deviceInfo.supportedModes.length)
        ];
      }
      
      return DeviceUsage(
        deviceName: deviceInfo.name,
        deviceIcon: deviceInfo.icon,
        usage: usage,
        currentMode: currentMode,
      );
    }).toList();

    final totalUsage = devices.fold<double>(
      0,
      (sum, device) => sum + device.usage,
    );

    return RoomStats(
      roomName: space.name,
      devices: devices,
      totalUsage: totalUsage,
      estimatedCost: totalUsage * 0.25, // $0.25 per kWh
    );
  }
}
