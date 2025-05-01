class ProfileModel {
  final String name;
  final String email;
  final String profilePicture;
  final String householdId;
  final String accountType;

  ProfileModel({
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.householdId,
    required this.accountType,
  });

  // Dummy data
  static ProfileModel dummyProfile = ProfileModel(
    name: 'John Doe',
    email: 'john.doe@example.com',
    profilePicture: 'https://i.pravatar.cc/150',
    householdId: 'HH-2025-001',
    accountType: 'Residential',
  );
}
