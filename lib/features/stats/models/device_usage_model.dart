class DeviceUsage {
  final String deviceName;
  final double usage; // in kWh
  
  DeviceUsage({
    required this.deviceName,
    required this.usage,
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

  // Sample data for each room
  static RoomStats getStatsForRoom(String roomName) {
    switch (roomName) {
      case "Oliver's Bedroom":
        return RoomStats(
          roomName: roomName,
          devices: [
            DeviceUsage(deviceName: "Baby Cam", usage: 4),
            DeviceUsage(deviceName: "Heater", usage: 6),
            DeviceUsage(deviceName: "Smart Cradle", usage: 5),
            DeviceUsage(deviceName: "Speaker", usage: 3),
          ],
          totalUsage: 18,
          estimatedCost: 8.20,
        );
      case "Living Room":
        return RoomStats(
          roomName: roomName,
          devices: [
            DeviceUsage(deviceName: "TV", usage: 8),
            DeviceUsage(deviceName: "AC", usage: 12),
            DeviceUsage(deviceName: "Smart Lights", usage: 2),
            DeviceUsage(deviceName: "Game Console", usage: 5),
          ],
          totalUsage: 27,
          estimatedCost: 12.50,
        );
      case "Kitchen":
        return RoomStats(
          roomName: roomName,
          devices: [
            DeviceUsage(deviceName: "Refrigerator", usage: 15),
            DeviceUsage(deviceName: "Microwave", usage: 7),
            DeviceUsage(deviceName: "Coffee Maker", usage: 3),
            DeviceUsage(deviceName: "Dishwasher", usage: 8),
          ],
          totalUsage: 33,
          estimatedCost: 15.80,
        );
      default:
        throw Exception("Unknown room: $roomName");
    }
  }
}
