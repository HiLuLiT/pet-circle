import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/measurement.dart';

class Pet {
  const Pet({
    required this.name,
    required this.breedAndAge,
    required this.imageUrl,
    required this.statusLabel,
    required this.statusColorHex,
    required this.latestMeasurement,
    required this.careCircle,
  });

  final String name;
  final String breedAndAge;
  final String imageUrl;
  final String statusLabel;
  final int statusColorHex;
  final Measurement latestMeasurement;
  final List<CareCircleMember> careCircle;
}
