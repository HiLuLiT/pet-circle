enum CareCircleRole { owner, member }

extension CareCirclePermissions on CareCircleRole {
  bool get canMeasure => true;
  bool get canEditPet => this == CareCircleRole.owner;
  bool get canManageCircle => this == CareCircleRole.owner;
  bool get canAddNotes => true;
  bool get canDeletePet => this == CareCircleRole.owner;

  /// Maps legacy Firestore values to the simplified role model.
  /// 'admin' -> owner, everything else -> member.
  static CareCircleRole fromString(String value) {
    switch (value) {
      case 'admin':
      case 'owner':
        return CareCircleRole.owner;
      case 'member':
      case 'viewer':
        return CareCircleRole.member;
      default:
        return CareCircleRole.member;
    }
  }
}

class CareCircleMember {
  const CareCircleMember({
    this.uid,
    required this.name,
    required this.avatarUrl,
    required this.role,
  });

  final String? uid;
  final String name;
  final String avatarUrl;
  final CareCircleRole role;

  String get roleLabel {
    switch (role) {
      case CareCircleRole.owner:
        return 'Owner';
      case CareCircleRole.member:
        return 'Member';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role.name,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }

  factory CareCircleMember.fromFirestore(String uid, Map<String, dynamic> data) {
    return CareCircleMember(
      uid: uid,
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      role: CareCirclePermissions.fromString(data['role'] ?? 'member'),
    );
  }
}
