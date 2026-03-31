import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/colors.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class BreedItem {
  const BreedItem({
    required this.displayName,
    required this.breed,
    this.subBreed,
  });

  final String displayName;
  final String breed;
  final String? subBreed;
}

const allBreeds = [
  BreedItem(displayName: 'Affenpinscher', breed: 'affenpinscher'),
  BreedItem(displayName: 'Afghan Hound', breed: 'hound', subBreed: 'afghan'),
  BreedItem(displayName: 'Airedale', breed: 'airedale'),
  BreedItem(displayName: 'Akita', breed: 'akita'),
  BreedItem(displayName: 'American Terrier', breed: 'terrier', subBreed: 'american'),
  BreedItem(displayName: 'Appenzeller', breed: 'appenzeller'),
  BreedItem(displayName: 'Australian Cattledog', breed: 'cattledog', subBreed: 'australian'),
  BreedItem(displayName: 'Australian Shepherd', breed: 'australian', subBreed: 'shepherd'),
  BreedItem(displayName: 'Australian Terrier', breed: 'terrier', subBreed: 'australian'),
  BreedItem(displayName: 'Basenji', breed: 'basenji'),
  BreedItem(displayName: 'Basset Hound', breed: 'hound', subBreed: 'basset'),
  BreedItem(displayName: 'Beagle', breed: 'beagle'),
  BreedItem(displayName: 'Bedlington Terrier', breed: 'terrier', subBreed: 'bedlington'),
  BreedItem(displayName: 'Bernese Mountain', breed: 'mountain', subBreed: 'bernese'),
  BreedItem(displayName: 'Bichon Frise', breed: 'frise', subBreed: 'bichon'),
  BreedItem(displayName: 'Blenheim Spaniel', breed: 'spaniel', subBreed: 'blenheim'),
  BreedItem(displayName: 'Blood Hound', breed: 'hound', subBreed: 'blood'),
  BreedItem(displayName: 'Bluetick', breed: 'bluetick'),
  BreedItem(displayName: 'Border Collie', breed: 'collie', subBreed: 'border'),
  BreedItem(displayName: 'Border Terrier', breed: 'terrier', subBreed: 'border'),
  BreedItem(displayName: 'Borzoi', breed: 'borzoi'),
  BreedItem(displayName: 'Boston Bulldog', breed: 'bulldog', subBreed: 'boston'),
  BreedItem(displayName: 'Boston Terrier', breed: 'terrier', subBreed: 'boston'),
  BreedItem(displayName: 'Bouvier', breed: 'bouvier'),
  BreedItem(displayName: 'Boxer', breed: 'boxer'),
  BreedItem(displayName: 'Brabancon', breed: 'brabancon'),
  BreedItem(displayName: 'Briard', breed: 'briard'),
  BreedItem(displayName: 'Brittany Spaniel', breed: 'spaniel', subBreed: 'brittany'),
  BreedItem(displayName: 'Bull Mastiff', breed: 'mastiff', subBreed: 'bull'),
  BreedItem(displayName: 'Cairn Terrier', breed: 'terrier', subBreed: 'cairn'),
  BreedItem(displayName: 'Cardigan Corgi', breed: 'corgi', subBreed: 'cardigan'),
  BreedItem(displayName: 'Caucasian Ovcharka', breed: 'ovcharka', subBreed: 'caucasian'),
  BreedItem(displayName: 'Cavalier King Charles Spaniel', breed: 'spaniel', subBreed: 'cocker'),
  BreedItem(displayName: 'Cavapoo', breed: 'cavapoo'),
  BreedItem(displayName: 'Chesapeake Retriever', breed: 'retriever', subBreed: 'chesapeake'),
  BreedItem(displayName: 'Chihuahua', breed: 'chihuahua'),
  BreedItem(displayName: 'Chow', breed: 'chow'),
  BreedItem(displayName: 'Clumber', breed: 'clumber'),
  BreedItem(displayName: 'Cockapoo', breed: 'cockapoo'),
  BreedItem(displayName: 'Cocker Spaniel', breed: 'spaniel', subBreed: 'cocker'),
  BreedItem(displayName: 'Coonhound', breed: 'coonhound'),
  BreedItem(displayName: 'Corgi', breed: 'corgi'),
  BreedItem(displayName: 'Coton de Tulear', breed: 'cotondetulear'),
  BreedItem(displayName: 'Curly Retriever', breed: 'retriever', subBreed: 'curly'),
  BreedItem(displayName: 'Dachshund', breed: 'dachshund'),
  BreedItem(displayName: 'Dalmatian', breed: 'dalmatian'),
  BreedItem(displayName: 'Dandie Terrier', breed: 'terrier', subBreed: 'dandie'),
  BreedItem(displayName: 'Doberman', breed: 'doberman'),
  BreedItem(displayName: 'English Bulldog', breed: 'bulldog', subBreed: 'english'),
  BreedItem(displayName: 'English Hound', breed: 'hound', subBreed: 'english'),
  BreedItem(displayName: 'English Mastiff', breed: 'mastiff', subBreed: 'english'),
  BreedItem(displayName: 'English Setter', breed: 'setter', subBreed: 'english'),
  BreedItem(displayName: 'English Sheepdog', breed: 'sheepdog', subBreed: 'english'),
  BreedItem(displayName: 'English Springer', breed: 'springer', subBreed: 'english'),
  BreedItem(displayName: 'Entlebucher', breed: 'entlebucher'),
  BreedItem(displayName: 'Eskimo', breed: 'eskimo'),
  BreedItem(displayName: 'Flatcoated Retriever', breed: 'retriever', subBreed: 'flatcoated'),
  BreedItem(displayName: 'Fox Terrier', breed: 'terrier', subBreed: 'fox'),
  BreedItem(displayName: 'French Bulldog', breed: 'bulldog', subBreed: 'french'),
  BreedItem(displayName: 'German Pointer', breed: 'pointer', subBreed: 'german'),
  BreedItem(displayName: 'German Shepherd', breed: 'german', subBreed: 'shepherd'),
  BreedItem(displayName: 'Giant Schnauzer', breed: 'schnauzer', subBreed: 'giant'),
  BreedItem(displayName: 'Golden Retriever', breed: 'retriever', subBreed: 'golden'),
  BreedItem(displayName: 'Gordon Setter', breed: 'setter', subBreed: 'gordon'),
  BreedItem(displayName: 'Great Dane', breed: 'dane', subBreed: 'great'),
  BreedItem(displayName: 'Greyhound', breed: 'greyhound'),
  BreedItem(displayName: 'Groenendael', breed: 'groenendael'),
  BreedItem(displayName: 'Havanese', breed: 'havanese'),
  BreedItem(displayName: 'Husky', breed: 'husky'),
  BreedItem(displayName: 'Ibizan Hound', breed: 'hound', subBreed: 'ibizan'),
  BreedItem(displayName: 'Irish Setter', breed: 'setter', subBreed: 'irish'),
  BreedItem(displayName: 'Irish Spaniel', breed: 'spaniel', subBreed: 'irish'),
  BreedItem(displayName: 'Irish Terrier', breed: 'terrier', subBreed: 'irish'),
  BreedItem(displayName: 'Irish Wolfhound', breed: 'wolfhound', subBreed: 'irish'),
  BreedItem(displayName: 'Italian Greyhound', breed: 'greyhound', subBreed: 'italian'),
  BreedItem(displayName: 'Japanese Spaniel', breed: 'spaniel', subBreed: 'japanese'),
  BreedItem(displayName: 'Japanese Spitz', breed: 'spitz', subBreed: 'japanese'),
  BreedItem(displayName: 'Keeshond', breed: 'keeshond'),
  BreedItem(displayName: 'Kelpie', breed: 'kelpie'),
  BreedItem(displayName: 'Kerry Blue Terrier', breed: 'terrier', subBreed: 'kerryblue'),
  BreedItem(displayName: 'Komondor', breed: 'komondor'),
  BreedItem(displayName: 'Kuvasz', breed: 'kuvasz'),
  BreedItem(displayName: 'Labradoodle', breed: 'labradoodle'),
  BreedItem(displayName: 'Labrador', breed: 'labrador'),
  BreedItem(displayName: 'Lakeland Terrier', breed: 'terrier', subBreed: 'lakeland'),
  BreedItem(displayName: 'Leonberg', breed: 'leonberg'),
  BreedItem(displayName: 'Lhasa Apso', breed: 'lhasa'),
  BreedItem(displayName: 'Malamute', breed: 'malamute'),
  BreedItem(displayName: 'Malinois', breed: 'malinois'),
  BreedItem(displayName: 'Maltese', breed: 'maltese'),
  BreedItem(displayName: 'Medium Poodle', breed: 'poodle', subBreed: 'medium'),
  BreedItem(displayName: 'Mexican Hairless', breed: 'mexicanhairless'),
  BreedItem(displayName: 'Miniature Pinscher', breed: 'pinscher', subBreed: 'miniature'),
  BreedItem(displayName: 'Miniature Poodle', breed: 'poodle', subBreed: 'miniature'),
  BreedItem(displayName: 'Miniature Schnauzer', breed: 'schnauzer', subBreed: 'miniature'),
  BreedItem(displayName: 'Mixed Breed', breed: 'mix'),
  BreedItem(displayName: 'Newfoundland', breed: 'newfoundland'),
  BreedItem(displayName: 'Norfolk Terrier', breed: 'terrier', subBreed: 'norfolk'),
  BreedItem(displayName: 'Norwegian Buhund', breed: 'buhund', subBreed: 'norwegian'),
  BreedItem(displayName: 'Norwegian Elkhound', breed: 'elkhound', subBreed: 'norwegian'),
  BreedItem(displayName: 'Norwich Terrier', breed: 'terrier', subBreed: 'norwich'),
  BreedItem(displayName: 'Otterhound', breed: 'otterhound'),
  BreedItem(displayName: 'Papillon', breed: 'papillon'),
  BreedItem(displayName: 'Patterdale Terrier', breed: 'terrier', subBreed: 'patterdale'),
  BreedItem(displayName: 'Pekinese', breed: 'pekinese'),
  BreedItem(displayName: 'Pembroke Corgi', breed: 'corgi', subBreed: 'pembroke'),
  BreedItem(displayName: 'Pitbull', breed: 'pitbull'),
  BreedItem(displayName: 'Plott Hound', breed: 'hound', subBreed: 'plott'),
  BreedItem(displayName: 'Pomeranian', breed: 'pomeranian'),
  BreedItem(displayName: 'Pug', breed: 'pug'),
  BreedItem(displayName: 'Puggle', breed: 'puggle'),
  BreedItem(displayName: 'Pyrenees', breed: 'pyrenees'),
  BreedItem(displayName: 'Redbone', breed: 'redbone'),
  BreedItem(displayName: 'Rhodesian Ridgeback', breed: 'ridgeback', subBreed: 'rhodesian'),
  BreedItem(displayName: 'Rottweiler', breed: 'rottweiler'),
  BreedItem(displayName: 'Russell Terrier', breed: 'terrier', subBreed: 'russell'),
  BreedItem(displayName: 'Saluki', breed: 'saluki'),
  BreedItem(displayName: 'Samoyed', breed: 'samoyed'),
  BreedItem(displayName: 'Schipperke', breed: 'schipperke'),
  BreedItem(displayName: 'Scottish Deerhound', breed: 'deerhound', subBreed: 'scottish'),
  BreedItem(displayName: 'Scottish Terrier', breed: 'terrier', subBreed: 'scottish'),
  BreedItem(displayName: 'Sealyham Terrier', breed: 'terrier', subBreed: 'sealyham'),
  BreedItem(displayName: 'Shar Pei', breed: 'sharpei'),
  BreedItem(displayName: 'Shetland Sheepdog', breed: 'sheepdog', subBreed: 'shetland'),
  BreedItem(displayName: 'Shiba Inu', breed: 'shiba'),
  BreedItem(displayName: 'Shih Tzu', breed: 'shihtzu'),
  BreedItem(displayName: 'Silky Terrier', breed: 'terrier', subBreed: 'silky'),
  BreedItem(displayName: 'Spanish Waterdog', breed: 'waterdog', subBreed: 'spanish'),
  BreedItem(displayName: 'St. Bernard', breed: 'stbernard'),
  BreedItem(displayName: 'Staffordshire Bull Terrier', breed: 'bullterrier', subBreed: 'staffordshire'),
  BreedItem(displayName: 'Standard Poodle', breed: 'poodle', subBreed: 'standard'),
  BreedItem(displayName: 'Sussex Spaniel', breed: 'spaniel', subBreed: 'sussex'),
  BreedItem(displayName: 'Swiss Mountain', breed: 'mountain', subBreed: 'swiss'),
  BreedItem(displayName: 'Tervuren', breed: 'tervuren'),
  BreedItem(displayName: 'Tibetan Mastiff', breed: 'mastiff', subBreed: 'tibetan'),
  BreedItem(displayName: 'Tibetan Terrier', breed: 'terrier', subBreed: 'tibetan'),
  BreedItem(displayName: 'Toy Poodle', breed: 'poodle', subBreed: 'toy'),
  BreedItem(displayName: 'Toy Terrier', breed: 'terrier', subBreed: 'toy'),
  BreedItem(displayName: 'Vizsla', breed: 'vizsla'),
  BreedItem(displayName: 'Walker Hound', breed: 'hound', subBreed: 'walker'),
  BreedItem(displayName: 'Weimaraner', breed: 'weimaraner'),
  BreedItem(displayName: 'Welsh Spaniel', breed: 'spaniel', subBreed: 'welsh'),
  BreedItem(displayName: 'Welsh Terrier', breed: 'terrier', subBreed: 'welsh'),
  BreedItem(displayName: 'West Highland Terrier', breed: 'terrier', subBreed: 'westhighland'),
  BreedItem(displayName: 'Wheaten Terrier', breed: 'terrier', subBreed: 'wheaten'),
  BreedItem(displayName: 'Whippet', breed: 'whippet'),
  BreedItem(displayName: 'Yorkshire Terrier', breed: 'terrier', subBreed: 'yorkshire'),
];

/// Searchable breed dropdown. Displays as a tap-to-open chip; when open,
/// shows a search field and a filtered scrollable list.
class BreedSearchField extends StatefulWidget {
  const BreedSearchField({
    super.key,
    required this.label,
    this.initialValue,
    this.onChanged,
    this.maxHeight = 200,
  });

  final String label;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final double maxHeight;

  @override
  State<BreedSearchField> createState() => _BreedSearchFieldState();
}

class _BreedSearchFieldState extends State<BreedSearchField>
    with SingleTickerProviderStateMixin {
  String? _selected;
  bool _isOpen = false;
  final _searchController = TextEditingController();
  String _query = '';
  late AnimationController _chevronController;

  List<BreedItem> get _filtered {
    if (_query.isEmpty) return allBreeds;
    final q = _query.toLowerCase();
    return allBreeds.where((b) => b.displayName.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue?.isNotEmpty == true ? widget.initialValue : null;
    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chevronController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _chevronController.forward();
      } else {
        _chevronController.reverse();
        _searchController.clear();
      }
    });
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppSemanticTextStyles.labelSm,
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppPrimitives.skyLighter,
              borderRadius: AppRadiiTokens.borderRadiusLg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selected ?? 'e.g., Golden Retriever',
                    style: AppSemanticTextStyles.body.copyWith(
                      color: _selected == null ? AppPrimitives.skyDark : c.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(
                    CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
                  ),
                  child: Icon(Icons.keyboard_arrow_down, color: c.textSecondary, size: 18),
                ),
              ],
            ),
          ),
        ),
        if (_isOpen)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppPrimitives.skyWhite,
              borderRadius: AppRadiiTokens.borderRadiusLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: l10n.searchBreeds,
                        hintStyle: AppSemanticTextStyles.body.copyWith(
                          color: AppPrimitives.skyDark,
                        ),
                        prefixIcon: Icon(Icons.search, size: 18, color: c.textTertiary),
                        prefixIconConstraints: const BoxConstraints(minWidth: 36),
                        filled: true,
                        fillColor: AppPrimitives.skyLightest,
                        border: OutlineInputBorder(
                          borderRadius: AppRadiiTokens.borderRadiusLg,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      style: AppSemanticTextStyles.body.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight),
                  child: _filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.noBreedsFound,
                            style: AppSemanticTextStyles.body.copyWith(
                              color: c.textTertiary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 8),
                          shrinkWrap: true,
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final breed = _filtered[index];
                            final isSelected = breed.displayName == _selected;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selected = breed.displayName;
                                  _isOpen = false;
                                });
                                _searchController.clear();
                                _chevronController.reverse();
                                widget.onChanged?.call(breed.displayName);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? c.primaryLightest : Colors.transparent,
                                  borderRadius: AppRadiiTokens.borderRadiusLg,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        breed.displayName,
                                        style: AppSemanticTextStyles.body.copyWith(
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (breed.subBreed != null)
                                      Text(
                                        _capitalize(breed.breed),
                                        style: AppSemanticTextStyles.caption.copyWith(
                                          color: c.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
