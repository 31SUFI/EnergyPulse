enum SpaceCategory {
  bedroom,
  bathroom,
  kitchen,
  familyhall;

  String get displayName {
    switch (this) {
      case SpaceCategory.bedroom:
        return 'Bedroom';
      case SpaceCategory.bathroom:
        return 'Bathroom';
      case SpaceCategory.kitchen:
        return 'Kitchen';
      case SpaceCategory.familyhall:
        return 'Family Hall';
    }
  }

  String get iconPath {
    switch (this) {
      case SpaceCategory.bedroom:
        return 'assets/images/bedroom.svg';
      case SpaceCategory.bathroom:
        return 'assets/images/bathroom.svg';
      case SpaceCategory.kitchen:
        return 'assets/images/kitchen.svg';
      case SpaceCategory.familyhall:
        return 'assets/images/familyhall.svg';
    }
  }
}

class Space {
  final String name;
  final SpaceCategory category;
  final bool isActive;
  final double energyConsumption;

  Space({
    required this.name,
    required this.category,
    this.isActive = true,
    this.energyConsumption = 0.0,
  });
}
