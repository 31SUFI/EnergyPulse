import 'package:flutter/material.dart';
import '../model/space_model.dart';

class SpaceProvider with ChangeNotifier {
  final List<Space> _spaces = [
    Space(
      name: 'Master Bedroom',
      category: SpaceCategory.bedroom,
      energyConsumption: 2.5,
    ),
    Space(
      name: 'Kitchen',
      category: SpaceCategory.kitchen,
      energyConsumption: 4.2,
    ),
  ];

  List<Space> get spaces => _spaces;

  void addSpace(Space space) {
    _spaces.add(space);
    notifyListeners();
  }

  void removeSpace(Space space) {
    _spaces.remove(space);
    notifyListeners();
  }

  double getSpaceEnergyConsumption(String spaceName) {
    final space = _spaces.firstWhere(
      (space) => space.name == spaceName,
      orElse: () => Space(name: '', category: SpaceCategory.bedroom),
    );
    return space.energyConsumption;
  }

  // Get random stats data for a space (temporary until Firebase integration)
  List<double> getSpaceHourlyStats(String spaceName) {
    return List.generate(24, (index) => (index % 5 + 1) * 0.8);
  }
}
