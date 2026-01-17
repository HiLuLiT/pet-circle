import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/models/user.dart';
import 'package:pet_circle/theme/app_theme.dart';

class MockData {
  // ── Users ──────────────────────────────────────────────────────────────────
  static final currentVetUser = User(
    id: 'vet-1',
    name: 'Dr. Smith',
    email: 'dr.smith@petclinic.com',
    role: UserRole.vet,
    avatarUrl: 'https://ui-avatars.com/api/?name=Dr+Smith&size=128&rounded=true&background=5B2C3F&color=fff',
  );

  static final currentOwnerUser = User(
    id: 'owner-1',
    name: 'Hila',
    email: 'hila@example.com',
    role: UserRole.owner,
    avatarUrl: 'https://ui-avatars.com/api/?name=Hila&size=128&rounded=true&background=E8B4B8&color=5B2C3F',
  );

  // ── Care Circle Members ────────────────────────────────────────────────────
  static final hilaOwner = CareCircleMember(
    name: 'Hila',
    avatarUrl: 'https://ui-avatars.com/api/?name=Hila&size=128&rounded=true&background=E8B4B8&color=5B2C3F',
    role: 'Owner',
  );

  static final drSmithVet = CareCircleMember(
    name: 'Dr. Smith',
    avatarUrl: 'https://ui-avatars.com/api/?name=Dr+Smith&size=128&rounded=true&background=5B2C3F&color=fff',
    role: 'Veterinarian',
  );

  static final sarahCaregiver = CareCircleMember(
    name: 'Sarah',
    avatarUrl: 'https://ui-avatars.com/api/?name=Sarah&size=128&rounded=true&background=7FBA7A&color=fff',
    role: 'Caregiver',
  );

  static final maxOwner = CareCircleMember(
    name: 'John',
    avatarUrl: 'https://ui-avatars.com/api/?name=John&size=128&rounded=true&background=5B9BD5&color=fff',
    role: 'Owner',
  );

  static final lunaOwner = CareCircleMember(
    name: 'Emily',
    avatarUrl: 'https://ui-avatars.com/api/?name=Emily&size=128&rounded=true&background=F39C12&color=fff',
    role: 'Owner',
  );

  static final rockyOwner = CareCircleMember(
    name: 'Mike',
    avatarUrl: 'https://ui-avatars.com/api/?name=Mike&size=128&rounded=true&background=9B59B6&color=fff',
    role: 'Owner',
  );

  // ── Clinical Notes ─────────────────────────────────────────────────────────
  static final princessNotes = [
    ClinicalNote(
      id: 'note-1',
      authorName: 'Dr. Smith',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Dr+Smith&size=128&rounded=true&background=5B2C3F&color=fff',
      content: 'Respiratory rate stable. Continue monitoring daily. Heart murmur grade 2/6 unchanged.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ClinicalNote(
      id: 'note-2',
      authorName: 'Dr. Smith',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Dr+Smith&size=128&rounded=true&background=5B2C3F&color=fff',
      content: 'Follow-up visit scheduled for next week. Owner reports good appetite and energy levels.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  static final maxNotes = [
    ClinicalNote(
      id: 'note-3',
      authorName: 'Dr. Smith',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Dr+Smith&size=128&rounded=true&background=5B2C3F&color=fff',
      content: 'Slight elevation in SRR. Recommend increasing measurement frequency to twice daily.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  // ── Measurement History ────────────────────────────────────────────────────
  static final princessMeasurements = [
    Measurement(bpm: 22, recordedAtLabel: '2 hours ago'),
    Measurement(bpm: 24, recordedAtLabel: 'Yesterday'),
    Measurement(bpm: 21, recordedAtLabel: '2 days ago'),
    Measurement(bpm: 23, recordedAtLabel: '3 days ago'),
    Measurement(bpm: 25, recordedAtLabel: '4 days ago'),
  ];

  // ── Pets ───────────────────────────────────────────────────────────────────
  
  // Princess - owned by Hila
  static final princess = Pet(
    name: 'Princess',
    breedAndAge: 'Cavalier King Charles • 5 years old',
    imageUrl: 'https://dog.ceo/api/breed/spaniel/cocker/images/random',
    statusLabel: 'Normal',
    statusColorHex: AppColors.successGreen.value,
    latestMeasurement: Measurement(bpm: 22, recordedAtLabel: '2 hours ago'),
    careCircle: [hilaOwner, drSmithVet, sarahCaregiver],
  );

  // Max - owned by John
  static final max = Pet(
    name: 'Max',
    breedAndAge: 'Golden Retriever • 8 years old',
    imageUrl: 'https://dog.ceo/api/breed/retriever/golden/images/random',
    statusLabel: 'Elevated',
    statusColorHex: AppColors.warningAmber.value,
    latestMeasurement: Measurement(bpm: 32, recordedAtLabel: '30 min ago'),
    careCircle: [maxOwner, drSmithVet],
  );

  // Luna - owned by Emily
  static final luna = Pet(
    name: 'Luna',
    breedAndAge: 'Labrador • 6 years old',
    imageUrl: 'https://dog.ceo/api/breed/labrador/images/random',
    statusLabel: 'Normal',
    statusColorHex: AppColors.successGreen.value,
    latestMeasurement: Measurement(bpm: 24, recordedAtLabel: '1 hour ago'),
    careCircle: [lunaOwner, drSmithVet],
  );

  // Rocky - owned by Mike
  static final rocky = Pet(
    name: 'Rocky',
    breedAndAge: 'German Shepherd • 10 years old',
    imageUrl: 'https://dog.ceo/api/breed/germanshepherd/images/random',
    statusLabel: 'Normal',
    statusColorHex: AppColors.successGreen.value,
    latestMeasurement: Measurement(bpm: 18, recordedAtLabel: '1 day ago'),
    careCircle: [rockyOwner, drSmithVet],
  );

  // ── Pet Lists by User Context ──────────────────────────────────────────────
  
  /// All pets visible to the vet (entire clinic)
  static final vetClinicPets = [princess, max, luna, rocky];

  /// Pets owned by Hila
  static final hilaPets = [princess];

  /// Legacy accessor for backward compatibility
  static final pets = vetClinicPets;
}
