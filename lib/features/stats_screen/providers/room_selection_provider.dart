import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../features/home_screen/providers/space_provider.dart';

class RoomSelectionProvider with ChangeNotifier {
  String? _selectedRoom;

  String? get selectedRoom => _selectedRoom;

  // Initialize with first room
  void initializeWithFirstRoom(BuildContext context) {
    if (_selectedRoom == null) {
      final spaceProvider = Provider.of<SpaceProvider>(context, listen: false);
      if (spaceProvider.spaces.isNotEmpty) {
        _selectedRoom = spaceProvider.spaces.first.name;
        notifyListeners();
      }
    }
  }

  void selectRoom(String roomName) {
    _selectedRoom = roomName;
    notifyListeners();
  }
}
