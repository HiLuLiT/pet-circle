enum CareCircleRole { admin, member, viewer }

extension CareCirclePermissions on CareCircleRole {
  bool get canMeasure => this == CareCircleRole.admin || this == CareCircleRole.member;
  bool get canEditPet => this == CareCircleRole.admin;
  bool get canManageCircle => this == CareCircleRole.admin;
  bool get canAddNotes => true;
  bool get canDeletePet => this == CareCircleRole.admin;
}

class CareCircleMember {
  const CareCircleMember({
    required this.name,
    required this.avatarUrl,
    required this.role,
  });

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
}
