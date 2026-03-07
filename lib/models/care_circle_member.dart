enum CareCircleRole { admin, member, viewer }

extension CareCirclePermissions on CareCircleRole {
  bool get canMeasure => this == CareCircleRole.admin || this == CareCircleRole.member;
  bool get canEditPet => this == CareCircleRole.admin;
  bool get canManageCircle => this == CareCircleRole.admin;
  bool get canAddNotes => true;
  bool get canDeletePet => this == CareCircleRole.admin;

  static CareCircleRole fromString(String value) {
    switch (value) {
      case 'admin':
        return CareCircleRole.admin;
      case 'member':
        return CareCircleRole.member;
      case 'viewer':
        return CareCircleRole.viewer;
      default:
        return CareCircleRole.viewer;
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
      case CareCircleRole.admin:
        return 'Admin';
      case CareCircleRole.member:
        return 'Member';
      case CareCircleRole.viewer:
        return 'Viewer';
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
      role: CareCirclePermissions.fromString(data['role'] ?? 'viewer'),
    );
  }
}
