class DeviceUsage {
  final String deviceName;
  final double consumption;
  final String icon;

  DeviceUsage({
    required this.deviceName,
    required this.consumption,
    required this.icon,
  });
}

class RoomStats {
  final String roomName;
  final List<DeviceUsage> devices;
  final double totalConsumption;
  final double estimatedCost;
  final double weeklyChangePercentage;

  RoomStats({
    required this.roomName,
    required this.devices,
    required this.totalConsumption,
    required this.estimatedCost,
    required this.weeklyChangePercentage,
  });
}
