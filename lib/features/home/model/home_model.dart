class HomeModel {
  final double energyUsage;
  final String weatherInfo;
  final List<SpaceModel> spaces;

  HomeModel({
    required this.energyUsage,
    required this.weatherInfo,
    required this.spaces,
  });
}

class SpaceModel {
  final String name;
  final String icon;
  final bool isActive;
  final double energyConsumption;

  SpaceModel({
    required this.name,
    required this.icon,
    required this.isActive,
    required this.energyConsumption,
  });
}
