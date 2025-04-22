import 'dart:math' as math;
import '../../home_screen/model/space_model.dart';

class DeviceUsage {
  final String deviceName;
  final double usage; // in kWh

  DeviceUsage({required this.deviceName, required this.usage});
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

  static final Map<SpaceCategory, List<String>> _devicesByCategory = {
    SpaceCategory.bedroom: [
      'Lights',
      'AC',
      'TV',
      'Phone Charger',
      'Laptop Charger',
    ],
    SpaceCategory.bathroom: [
      'Water Heater',
      'Hair Dryer',
      'Exhaust Fan',
      'Lights',
    ],
    SpaceCategory.kitchen: [
      'Refrigerator',
      'Microwave',
      'Coffee Maker',
      'Dishwasher',
      'Lights',
    ],
    SpaceCategory.familyhall: [
      'TV',
      'AC',
      'Game Console',
      'Smart Lights',
      'Sound System',
    ],
  };

  // Generate random but consistent stats for a space
  static RoomStats getStatsForSpace(Space space) {
    final random = math.Random(
      space.name.hashCode,
    ); // Use consistent seed for same room
    final deviceList = _devicesByCategory[space.category] ?? [];
    final numDevices = math.min(4, deviceList.length);

    final devices =
        deviceList
            .take(numDevices)
            .map(
              (name) => DeviceUsage(
                deviceName: name,
                usage:
                    (random.nextDouble() * 8 + 2).roundToDouble(), // 2-10 kWh
              ),
            )
            .toList();

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
