import 'package:flutter/material.dart';
import '../../../core/config/device_config.dart';
import '../../../features/home_screen/model/space_model.dart';
import '../model/routine_model.dart';

class RoutineProvider extends ChangeNotifier {
  Space? _selectedSpace;
  String _routineName = '';
  String _frequency = 'Everyday';
  final List<DeviceRoutine> _devices = [];
  final List<SmartRoutine> _routines = [];

  // Getters
  Space? get selectedSpace => _selectedSpace;
  String get routineName => _routineName;
  String get frequency => _frequency;
  List<DeviceRoutine> get devices => _devices;
  List<SmartRoutine> get routines => _routines;
  bool get canCreateRoutine => _selectedSpace != null && _routineName.isNotEmpty;

  // Setters
  void setSelectedSpace(Space space) {
    _selectedSpace = space;
    _devices.clear();
    
    // Get devices for the selected space using the central config
    final spaceDevices = DeviceConfig.getDevicesForSpace(space.name, space.category);
    
    // Initialize devices
    for (final deviceInfo in spaceDevices) {
      _devices.add(
        DeviceRoutine(
          deviceId: '${space.name}_${deviceInfo.id}',
          deviceName: deviceInfo.name,
          deviceIcon: deviceInfo.icon,
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 22, minute: 0),
          supportedModes: deviceInfo.supportedModes,
        ),
      );
    }
    notifyListeners();
  }

  void setRoutineName(String name) {
    _routineName = name;
    notifyListeners();
  }

  void setFrequency(String newFrequency) {
    _frequency = newFrequency;
    notifyListeners();
  }

  void updateDeviceRoutine(DeviceRoutine updatedDevice) {
    final index = _devices.indexWhere(
      (device) => device.deviceId == updatedDevice.deviceId,
    );
    if (index != -1) {
      _devices[index] = updatedDevice;
      notifyListeners();
    }
  }

  void createRoutine() {
    if (_selectedSpace == null || _routineName.isEmpty) return;

    final enabledDevices = _devices.where((device) => device.isEnabled).toList();
    if (enabledDevices.isEmpty) return;

    final routine = SmartRoutine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _routineName,
      space: _selectedSpace!,
      frequency: _frequency,
      devices: enabledDevices,
    );

    _routines.add(routine);
    _resetForm();
    notifyListeners();
  }

  void deleteRoutine(String routineId) {
    _routines.removeWhere((routine) => routine.id == routineId);
    notifyListeners();
  }

  void toggleRoutine(String routineId) {
    final index = _routines.indexWhere((routine) => routine.id == routineId);
    if (index != -1) {
      _routines[index] = _routines[index].copyWith(
        isActive: !_routines[index].isActive,
      );
      notifyListeners();
    }
  }

  void _resetForm() {
    _selectedSpace = null;
    _routineName = '';
    _frequency = 'Everyday';
    _devices.clear();
  }
}
