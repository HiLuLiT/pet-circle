import 'package:cloud_firestore/cloud_firestore.dart';

enum AppUserRole { vet, owner }

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.petIds = const [],
  });

  final String uid;
  final String email;
  final AppUserRole role;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final List<String> petIds;

  bool get isVet => role == AppUserRole.vet;
  bool get isOwner => role == AppUserRole.owner;
  bool get hasPets => petIds.isNotEmpty;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] == 'vet' ? AppUserRole.vet : AppUserRole.owner,
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      petIds: List<String>.from(data['petIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role == AppUserRole.vet ? 'vet' : 'owner',
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'petIds': petIds,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    AppUserRole? role,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    List<String>? petIds,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      petIds: petIds ?? this.petIds,
    );
  }
}
