import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/labeled_text_field.dart';
import 'package:pet_circle/widgets/onboarding_shell.dart';

class OnboardingStep1 extends StatefulWidget {
  const OnboardingStep1({super.key, this.onNext});

  final VoidCallback? onNext;

  @override
  State<OnboardingStep1> createState() => _OnboardingStep1State();
}

class _OnboardingStep1State extends State<OnboardingStep1>
    with SingleTickerProviderStateMixin {
  // Hardcoded breed list from Dog CEO API
  static const _allBreeds = [
    _BreedItem(displayName: 'Affenpinscher', breed: 'affenpinscher'),
    _BreedItem(displayName: 'Afghan Hound', breed: 'hound', subBreed: 'afghan'),
    _BreedItem(displayName: 'Airedale', breed: 'airedale'),
    _BreedItem(displayName: 'Akita', breed: 'akita'),
    _BreedItem(displayName: 'American Terrier', breed: 'terrier', subBreed: 'american'),
    _BreedItem(displayName: 'Appenzeller', breed: 'appenzeller'),
    _BreedItem(displayName: 'Australian Cattledog', breed: 'cattledog', subBreed: 'australian'),
    _BreedItem(displayName: 'Australian Shepherd', breed: 'australian', subBreed: 'shepherd'),
    _BreedItem(displayName: 'Australian Terrier', breed: 'terrier', subBreed: 'australian'),
    _BreedItem(displayName: 'Basenji', breed: 'basenji'),
    _BreedItem(displayName: 'Basset Hound', breed: 'hound', subBreed: 'basset'),
    _BreedItem(displayName: 'Beagle', breed: 'beagle'),
    _BreedItem(displayName: 'Bedlington Terrier', breed: 'terrier', subBreed: 'bedlington'),
    _BreedItem(displayName: 'Bernese Mountain', breed: 'mountain', subBreed: 'bernese'),
    _BreedItem(displayName: 'Bichon Frise', breed: 'frise', subBreed: 'bichon'),
    _BreedItem(displayName: 'Blenheim Spaniel', breed: 'spaniel', subBreed: 'blenheim'),
    _BreedItem(displayName: 'Blood Hound', breed: 'hound', subBreed: 'blood'),
    _BreedItem(displayName: 'Bluetick', breed: 'bluetick'),
    _BreedItem(displayName: 'Border Collie', breed: 'collie', subBreed: 'border'),
    _BreedItem(displayName: 'Border Terrier', breed: 'terrier', subBreed: 'border'),
    _BreedItem(displayName: 'Borzoi', breed: 'borzoi'),
    _BreedItem(displayName: 'Boston Bulldog', breed: 'bulldog', subBreed: 'boston'),
    _BreedItem(displayName: 'Boston Terrier', breed: 'terrier', subBreed: 'boston'),
    _BreedItem(displayName: 'Bouvier', breed: 'bouvier'),
    _BreedItem(displayName: 'Boxer', breed: 'boxer'),
    _BreedItem(displayName: 'Brabancon', breed: 'brabancon'),
    _BreedItem(displayName: 'Briard', breed: 'briard'),
    _BreedItem(displayName: 'Brittany Spaniel', breed: 'spaniel', subBreed: 'brittany'),
    _BreedItem(displayName: 'Bull Mastiff', breed: 'mastiff', subBreed: 'bull'),
    _BreedItem(displayName: 'Cairn Terrier', breed: 'terrier', subBreed: 'cairn'),
    _BreedItem(displayName: 'Cardigan Corgi', breed: 'corgi', subBreed: 'cardigan'),
    _BreedItem(displayName: 'Caucasian Ovcharka', breed: 'ovcharka', subBreed: 'caucasian'),
    _BreedItem(displayName: 'Cavalier King Charles Spaniel', breed: 'spaniel', subBreed: 'cocker'),
    _BreedItem(displayName: 'Cavapoo', breed: 'cavapoo'),
    _BreedItem(displayName: 'Chesapeake Retriever', breed: 'retriever', subBreed: 'chesapeake'),
    _BreedItem(displayName: 'Chihuahua', breed: 'chihuahua'),
    _BreedItem(displayName: 'Chow', breed: 'chow'),
    _BreedItem(displayName: 'Clumber', breed: 'clumber'),
    _BreedItem(displayName: 'Cockapoo', breed: 'cockapoo'),
    _BreedItem(displayName: 'Cocker Spaniel', breed: 'spaniel', subBreed: 'cocker'),
    _BreedItem(displayName: 'Coonhound', breed: 'coonhound'),
    _BreedItem(displayName: 'Corgi', breed: 'corgi'),
    _BreedItem(displayName: 'Coton de Tulear', breed: 'cotondetulear'),
    _BreedItem(displayName: 'Curly Retriever', breed: 'retriever', subBreed: 'curly'),
    _BreedItem(displayName: 'Dachshund', breed: 'dachshund'),
    _BreedItem(displayName: 'Dalmatian', breed: 'dalmatian'),
    _BreedItem(displayName: 'Dandie Terrier', breed: 'terrier', subBreed: 'dandie'),
    _BreedItem(displayName: 'Doberman', breed: 'doberman'),
    _BreedItem(displayName: 'English Bulldog', breed: 'bulldog', subBreed: 'english'),
    _BreedItem(displayName: 'English Hound', breed: 'hound', subBreed: 'english'),
    _BreedItem(displayName: 'English Mastiff', breed: 'mastiff', subBreed: 'english'),
    _BreedItem(displayName: 'English Setter', breed: 'setter', subBreed: 'english'),
    _BreedItem(displayName: 'English Sheepdog', breed: 'sheepdog', subBreed: 'english'),
    _BreedItem(displayName: 'English Springer', breed: 'springer', subBreed: 'english'),
    _BreedItem(displayName: 'Entlebucher', breed: 'entlebucher'),
    _BreedItem(displayName: 'Eskimo', breed: 'eskimo'),
    _BreedItem(displayName: 'Flatcoated Retriever', breed: 'retriever', subBreed: 'flatcoated'),
    _BreedItem(displayName: 'Fox Terrier', breed: 'terrier', subBreed: 'fox'),
    _BreedItem(displayName: 'French Bulldog', breed: 'bulldog', subBreed: 'french'),
    _BreedItem(displayName: 'German Pointer', breed: 'pointer', subBreed: 'german'),
    _BreedItem(displayName: 'German Shepherd', breed: 'german', subBreed: 'shepherd'),
    _BreedItem(displayName: 'Giant Schnauzer', breed: 'schnauzer', subBreed: 'giant'),
    _BreedItem(displayName: 'Golden Retriever', breed: 'retriever', subBreed: 'golden'),
    _BreedItem(displayName: 'Gordon Setter', breed: 'setter', subBreed: 'gordon'),
    _BreedItem(displayName: 'Great Dane', breed: 'dane', subBreed: 'great'),
    _BreedItem(displayName: 'Greyhound', breed: 'greyhound'),
    _BreedItem(displayName: 'Groenendael', breed: 'groenendael'),
    _BreedItem(displayName: 'Havanese', breed: 'havanese'),
    _BreedItem(displayName: 'Husky', breed: 'husky'),
    _BreedItem(displayName: 'Ibizan Hound', breed: 'hound', subBreed: 'ibizan'),
    _BreedItem(displayName: 'Irish Setter', breed: 'setter', subBreed: 'irish'),
    _BreedItem(displayName: 'Irish Spaniel', breed: 'spaniel', subBreed: 'irish'),
    _BreedItem(displayName: 'Irish Terrier', breed: 'terrier', subBreed: 'irish'),
    _BreedItem(displayName: 'Irish Wolfhound', breed: 'wolfhound', subBreed: 'irish'),
    _BreedItem(displayName: 'Italian Greyhound', breed: 'greyhound', subBreed: 'italian'),
    _BreedItem(displayName: 'Japanese Spaniel', breed: 'spaniel', subBreed: 'japanese'),
    _BreedItem(displayName: 'Japanese Spitz', breed: 'spitz', subBreed: 'japanese'),
    _BreedItem(displayName: 'Keeshond', breed: 'keeshond'),
    _BreedItem(displayName: 'Kelpie', breed: 'kelpie'),
    _BreedItem(displayName: 'Kerry Blue Terrier', breed: 'terrier', subBreed: 'kerryblue'),
    _BreedItem(displayName: 'Komondor', breed: 'komondor'),
    _BreedItem(displayName: 'Kuvasz', breed: 'kuvasz'),
    _BreedItem(displayName: 'Labradoodle', breed: 'labradoodle'),
    _BreedItem(displayName: 'Labrador', breed: 'labrador'),
    _BreedItem(displayName: 'Lakeland Terrier', breed: 'terrier', subBreed: 'lakeland'),
    _BreedItem(displayName: 'Leonberg', breed: 'leonberg'),
    _BreedItem(displayName: 'Lhasa Apso', breed: 'lhasa'),
    _BreedItem(displayName: 'Malamute', breed: 'malamute'),
    _BreedItem(displayName: 'Malinois', breed: 'malinois'),
    _BreedItem(displayName: 'Maltese', breed: 'maltese'),
    _BreedItem(displayName: 'Medium Poodle', breed: 'poodle', subBreed: 'medium'),
    _BreedItem(displayName: 'Mexican Hairless', breed: 'mexicanhairless'),
    _BreedItem(displayName: 'Miniature Pinscher', breed: 'pinscher', subBreed: 'miniature'),
    _BreedItem(displayName: 'Miniature Poodle', breed: 'poodle', subBreed: 'miniature'),
    _BreedItem(displayName: 'Miniature Schnauzer', breed: 'schnauzer', subBreed: 'miniature'),
    _BreedItem(displayName: 'Mixed Breed', breed: 'mix'),
    _BreedItem(displayName: 'Newfoundland', breed: 'newfoundland'),
    _BreedItem(displayName: 'Norfolk Terrier', breed: 'terrier', subBreed: 'norfolk'),
    _BreedItem(displayName: 'Norwegian Buhund', breed: 'buhund', subBreed: 'norwegian'),
    _BreedItem(displayName: 'Norwegian Elkhound', breed: 'elkhound', subBreed: 'norwegian'),
    _BreedItem(displayName: 'Norwich Terrier', breed: 'terrier', subBreed: 'norwich'),
    _BreedItem(displayName: 'Otterhound', breed: 'otterhound'),
    _BreedItem(displayName: 'Papillon', breed: 'papillon'),
    _BreedItem(displayName: 'Patterdale Terrier', breed: 'terrier', subBreed: 'patterdale'),
    _BreedItem(displayName: 'Pekinese', breed: 'pekinese'),
    _BreedItem(displayName: 'Pembroke Corgi', breed: 'corgi', subBreed: 'pembroke'),
    _BreedItem(displayName: 'Pitbull', breed: 'pitbull'),
    _BreedItem(displayName: 'Plott Hound', breed: 'hound', subBreed: 'plott'),
    _BreedItem(displayName: 'Pomeranian', breed: 'pomeranian'),
    _BreedItem(displayName: 'Pug', breed: 'pug'),
    _BreedItem(displayName: 'Puggle', breed: 'puggle'),
    _BreedItem(displayName: 'Pyrenees', breed: 'pyrenees'),
    _BreedItem(displayName: 'Redbone', breed: 'redbone'),
    _BreedItem(displayName: 'Rhodesian Ridgeback', breed: 'ridgeback', subBreed: 'rhodesian'),
    _BreedItem(displayName: 'Rottweiler', breed: 'rottweiler'),
    _BreedItem(displayName: 'Russell Terrier', breed: 'terrier', subBreed: 'russell'),
    _BreedItem(displayName: 'Saluki', breed: 'saluki'),
    _BreedItem(displayName: 'Samoyed', breed: 'samoyed'),
    _BreedItem(displayName: 'Schipperke', breed: 'schipperke'),
    _BreedItem(displayName: 'Scottish Deerhound', breed: 'deerhound', subBreed: 'scottish'),
    _BreedItem(displayName: 'Scottish Terrier', breed: 'terrier', subBreed: 'scottish'),
    _BreedItem(displayName: 'Sealyham Terrier', breed: 'terrier', subBreed: 'sealyham'),
    _BreedItem(displayName: 'Shar Pei', breed: 'sharpei'),
    _BreedItem(displayName: 'Shetland Sheepdog', breed: 'sheepdog', subBreed: 'shetland'),
    _BreedItem(displayName: 'Shiba Inu', breed: 'shiba'),
    _BreedItem(displayName: 'Shih Tzu', breed: 'shihtzu'),
    _BreedItem(displayName: 'Silky Terrier', breed: 'terrier', subBreed: 'silky'),
    _BreedItem(displayName: 'Spanish Waterdog', breed: 'waterdog', subBreed: 'spanish'),
    _BreedItem(displayName: 'St. Bernard', breed: 'stbernard'),
    _BreedItem(displayName: 'Staffordshire Bull Terrier', breed: 'bullterrier', subBreed: 'staffordshire'),
    _BreedItem(displayName: 'Standard Poodle', breed: 'poodle', subBreed: 'standard'),
    _BreedItem(displayName: 'Sussex Spaniel', breed: 'spaniel', subBreed: 'sussex'),
    _BreedItem(displayName: 'Swiss Mountain', breed: 'mountain', subBreed: 'swiss'),
    _BreedItem(displayName: 'Tervuren', breed: 'tervuren'),
    _BreedItem(displayName: 'Tibetan Mastiff', breed: 'mastiff', subBreed: 'tibetan'),
    _BreedItem(displayName: 'Tibetan Terrier', breed: 'terrier', subBreed: 'tibetan'),
    _BreedItem(displayName: 'Toy Poodle', breed: 'poodle', subBreed: 'toy'),
    _BreedItem(displayName: 'Toy Terrier', breed: 'terrier', subBreed: 'toy'),
    _BreedItem(displayName: 'Vizsla', breed: 'vizsla'),
    _BreedItem(displayName: 'Walker Hound', breed: 'hound', subBreed: 'walker'),
    _BreedItem(displayName: 'Weimaraner', breed: 'weimaraner'),
    _BreedItem(displayName: 'Welsh Spaniel', breed: 'spaniel', subBreed: 'welsh'),
    _BreedItem(displayName: 'Welsh Terrier', breed: 'terrier', subBreed: 'welsh'),
    _BreedItem(displayName: 'West Highland Terrier', breed: 'terrier', subBreed: 'westhighland'),
    _BreedItem(displayName: 'Wheaten Terrier', breed: 'terrier', subBreed: 'wheaten'),
    _BreedItem(displayName: 'Whippet', breed: 'whippet'),
    _BreedItem(displayName: 'Yorkshire Terrier', breed: 'terrier', subBreed: 'yorkshire'),
  ];

  String? _selectedBreed;
  bool _breedDropdownOpen = false;
  late AnimationController _chevronController;

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

  void _toggleBreedDropdown() {
    setState(() {
      _breedDropdownOpen = !_breedDropdownOpen;
      if (_breedDropdownOpen) {
        _chevronController.forward();
      } else {
        _chevronController.reverse();
      }
    });
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OnboardingShell(
      title: l10n.setupPetProfile,
      stepLabel: l10n.onboardingStep(1, 4),
      progress: 0.25,
      onNext: widget.onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tellUsAboutYourPet, style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.md),
          LabeledTextField(label: l10n.petName, hintText: 'e.g., Max'),
          const SizedBox(height: AppSpacing.md),
          // Breed dropdown
          Text(
            l10n.breed,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: _toggleBreedDropdown,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedBreed ?? 'e.g., Golden Retriever',
                      style: AppTextStyles.body.copyWith(
                        color: _selectedBreed == null
                            ? AppColors.burgundy.withOpacity(0.3)
                            : AppColors.burgundy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(
                      CurvedAnimation(
                        parent: _chevronController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.burgundy,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_breedDropdownOpen)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: _allBreeds.length,
                  itemBuilder: (context, index) {
                    final breed = _allBreeds[index];
                    final isSelected = breed.displayName == _selectedBreed;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBreed = breed.displayName;
                          _breedDropdownOpen = false;
                        });
                        _chevronController.reverse();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.lightYellow
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                breed.displayName,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (breed.subBreed != null)
                              Text(
                                _capitalize(breed.breed),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.burgundy,
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
            ),
          const SizedBox(height: AppSpacing.md),
          LabeledTextField(
            label: l10n.ageYears,
            hintText: 'e.g., 8',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledTextField(
            label: l10n.photoUrl,
            hintText: 'https://...',
          ),
        ],
      ),
    );
  }
}

class _BreedItem {
  const _BreedItem({
    required this.displayName,
    required this.breed,
    this.subBreed,
  });

  final String displayName;
  final String breed;
  final String? subBreed;
}
