import 'package:flutter/material.dart';

class RoomSelectionProvider extends ChangeNotifier {
  String _selectedRoom = "Oliver's Bedroom";
  
  String get selectedRoom => _selectedRoom;

  void selectRoom(String room) {
    _selectedRoom = room;
    notifyListeners();
  }
}
