import 'package:flutter/material.dart';
import '../../../features/home_screen/model/space_model.dart';

class DeviceRoutine {
  final String deviceId;
  final String deviceName;
  final String deviceIcon;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<String> supportedModes;
  final bool isEnabled;
  final String? selectedMode;

  DeviceRoutine({
    required this.deviceId,
    required this.deviceName,
    required this.deviceIcon,
    required this.startTime,
    required this.endTime,
    this.supportedModes = const [],
    this.isEnabled = true,
    this.selectedMode,
  });

  DeviceRoutine copyWith({
    String? deviceId,
    String? deviceName,
    String? deviceIcon,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<String>? supportedModes,
    bool? isEnabled,
    String? selectedMode,
  }) {
    return DeviceRoutine(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceIcon: deviceIcon ?? this.deviceIcon,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      supportedModes: supportedModes ?? this.supportedModes,
      isEnabled: isEnabled ?? this.isEnabled,
      selectedMode: selectedMode ?? this.selectedMode,
    );
  }
}

class SmartRoutine {
  final String id;
  final String name;
  final Space space;
  final String frequency;
  final List<DeviceRoutine> devices;
  final bool isActive;

  SmartRoutine({
    required this.id,
    required this.name,
    required this.space,
    required this.frequency,
    required this.devices,
    this.isActive = true,
  });

  SmartRoutine copyWith({
    String? id,
    String? name,
    Space? space,
    String? frequency,
    List<DeviceRoutine>? devices,
    bool? isActive,
  }) {
    return SmartRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      space: space ?? this.space,
      frequency: frequency ?? this.frequency,
      devices: devices ?? this.devices,
      isActive: isActive ?? this.isActive,
    );
  }
}
