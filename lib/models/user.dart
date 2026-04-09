import 'package:pet_circle/models/pet.dart';

enum UserRole {
  vet,
  owner,
  caregiver,
}

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    List<Pet> pets = const [],
  }) : pets = List.unmodifiable(pets);

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

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    List<Pet>? pets,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      pets: pets ?? this.pets,
    );
  }
}
