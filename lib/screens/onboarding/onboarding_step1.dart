import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  static const _breeds = [
    'Labrador Retriever',
    'German Shepherd',
    'Golden Retriever',
    'French Bulldog',
    'Bulldog',
    'Poodle',
    'Beagle',
    'Rottweiler',
    'German Shorthaired Pointer',
    'Dachshund',
    'Pembroke Welsh Corgi',
    'Australian Shepherd',
    'Yorkshire Terrier',
    'Boxer',
    'Cavalier King Charles Spaniel',
    'Doberman Pinscher',
    'Great Dane',
    'Miniature Schnauzer',
    'Siberian Husky',
    'Shih Tzu',
    'Boston Terrier',
    'Bernese Mountain Dog',
    'Pomeranian',
    'Havanese',
    'Shetland Sheepdog',
    'Brittany',
    'English Springer Spaniel',
    'Cocker Spaniel',
    'Border Collie',
    'Mastiff',
    'Chihuahua',
    'Vizsla',
    'Pug',
    'Maltese',
    'Weimaraner',
    'Collie',
    'Newfoundland',
    'Rhodesian Ridgeback',
    'Bichon Frise',
    'West Highland White Terrier',
  ];

  String? _selectedBreed;
  bool _breedDropdownOpen = false;
  Uint8List? _selectedImageBytes;
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Read bytes - works on all platforms including web
      final bytes = await image.readAsBytes();
      setState(() => _selectedImageBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Setup pet profile',
      stepLabel: 'Step 1 of 4',
      progress: 0.25,
      onNext: widget.onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about your pet', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.md),
          const LabeledTextField(label: "Pet's Name", hintText: 'e.g., Max'),
          const SizedBox(height: AppSpacing.md),
          // Breed dropdown
          Text(
            'Breed',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: _toggleBreedDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedBreed ?? 'Select breed',
                    style: AppTextStyles.body.copyWith(
                      color: _selectedBreed == null
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _breedDropdownOpen
                ? Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: _breeds.length,
                      itemBuilder: (context, index) {
                        final breed = _breeds[index];
                        final isSelected = breed == _selectedBreed;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBreed = breed;
                              _breedDropdownOpen = false;
                            });
                            _chevronController.reverse();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFE8A8)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              breed,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.md),
          const LabeledTextField(
            label: 'Age (years)',
            hintText: 'e.g., 8',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          // Photo upload
          Text(
            'Photo (Optional)',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.burgundy.withOpacity(0.2),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: _selectedImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: AppColors.burgundy.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload photo',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
