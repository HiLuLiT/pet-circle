import 'package:pet_circle/widgets/mascot.dart';

/// Maps a pet's breed-and-age string (e.g. "Coton de Tulear · 3 yrs") to a
/// [MascotBreed] silhouette.
///
/// Keyword-matches common breed families first; anything unmatched falls
/// back to a deterministic pseudo-random pick derived from the input's
/// [String.hashCode] so the same pet always renders the same mascot across
/// rebuilds.
MascotBreed mascotBreedFor(String breedAndAge) {
  final String lower = breedAndAge.toLowerCase();

  const List<String> floppyKeywords = [
    'retriever',
    'labrador',
    'spaniel',
  ];
  const List<String> perkyKeywords = [
    'shepherd',
    'husky',
    'collie',
  ];
  const List<String> fluffyKeywords = [
    'poodle',
    'bichon',
    'coton',
    'maltese',
    'pomeranian',
  ];
  const List<String> snoutKeywords = [
    'terrier',
    'greyhound',
    'whippet',
    'dachshund',
  ];
  const List<String> whiskersKeywords = [
    'cat',
    'persian',
    'siamese',
  ];

  if (floppyKeywords.any(lower.contains)) return MascotBreed.floppy;
  if (perkyKeywords.any(lower.contains)) return MascotBreed.perky;
  if (fluffyKeywords.any(lower.contains)) return MascotBreed.fluffy;
  if (snoutKeywords.any(lower.contains)) return MascotBreed.snout;
  if (whiskersKeywords.any(lower.contains)) return MascotBreed.whiskers;

  final int index = breedAndAge.hashCode.abs() % MascotBreed.values.length;
  return MascotBreed.values[index];
}
