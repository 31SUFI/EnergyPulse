import '../../features/home_screen/model/space_model.dart';

class DeviceConfig {
  static final Map<int, DeviceInfo> relayDevices = {
    1: const DeviceInfo(id: 'relay_1', name: 'Smart Light', icon: '💡'),
    2: const DeviceInfo(id: 'relay_2', name: 'Smart Fan', icon: '🌀'),
    3: const DeviceInfo(id: 'relay_3', name: 'Smart Refrigerator', icon: '🧊'),
    4: const DeviceInfo(id: 'relay_4', name: 'Smart AC', icon: '❄️'),
  };

  static const Map<SpaceCategory, List<DeviceInfo>> devicesByCategory = {
    SpaceCategory.bedroom: [
      DeviceInfo(
        id: 'smart_heater',
        name: 'Smart Refrigerator',
        icon: '🧊',
        supportedModes: ['Economy Mode', 'Comfort Mode', 'Boost Mode'],
      ),
      DeviceInfo(id: 'smart_light', name: 'Smart Light', icon: '💡'),
      DeviceInfo(id: 'smart_ac', name: 'Smart AC', icon: '❄️'),
      DeviceInfo(id: 'smart_fan', name: 'Smart Fan', icon: '🌀'),
    ],
    SpaceCategory.bathroom: [
      DeviceInfo(id: 'water_heater', name: 'Water Heater', icon: '🚿'),
      DeviceInfo(id: 'smart_light', name: 'Smart Light', icon: '💡'),
      DeviceInfo(id: 'exhaust_fan', name: 'Exhaust Fan', icon: '🌀'),
    ],
    SpaceCategory.kitchen: [
      DeviceInfo(id: 'smart_fridge', name: 'Smart Fridge', icon: '❄️'),
      DeviceInfo(id: 'smart_oven', name: 'Smart Oven', icon: '🔥'),
      DeviceInfo(id: 'smart_light', name: 'Smart Light', icon: '💡'),
      DeviceInfo(
        id: 'coffee_maker',
        name: 'Smart Coffee Maker',
        icon: '☕',
      ),
    ],
    SpaceCategory.familyhall: [
      DeviceInfo(id: 'smart_tv', name: 'Smart TV', icon: '📺'),
      DeviceInfo(id: 'smart_light', name: 'Smart Light', icon: '💡'),
      DeviceInfo(id: 'smart_ac', name: 'Smart AC', icon: '❄️'),
      DeviceInfo(
        id: 'sound_system',
        name: 'Smart Sound System',
        icon: '🔊',
      ),
    ],
  };

  static const Map<String, List<DeviceInfo>> specialRoomDevices = {
    'baby': [
      DeviceInfo(id: 'baby_cam', name: 'Baby Cam', icon: '📹'),
      DeviceInfo(id: 'smart_cradle', name: 'Smart Cradle', icon: '🛏️'),
      DeviceInfo(id: 'smart_light', name: 'Smart Light', icon: '💡'),
      DeviceInfo(id: 'smart_ac', name: 'Smart AC', icon: '❄️'),
    ],
  };

  static List<DeviceInfo> getDevicesForSpace(String spaceName, SpaceCategory category) {
    // Check for special room types first
    if (spaceName.toLowerCase().contains('baby')) {
      return specialRoomDevices['baby'] ?? [];
    }
    
    // Return default devices for the category
    return devicesByCategory[category] ?? [];
  }
}

class DeviceInfo {
  final String id;
  final String name;
  final String icon;
  final List<String> supportedModes;

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.icon,
    this.supportedModes = const [],
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
