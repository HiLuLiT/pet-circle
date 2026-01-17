import 'package:pet_circle/models/pet.dart';

enum UserRole {
  vet,
  owner,
  caregiver,
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    this.pets = const [],
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String avatarUrl;
  final List<Pet> pets;

  String get roleLabel {
    switch (role) {
      case UserRole.vet:
        return 'Veterinarian';
      case UserRole.owner:
        return 'Pet Owner';
      case UserRole.caregiver:
        return 'Caregiver';
    }
  }
}
