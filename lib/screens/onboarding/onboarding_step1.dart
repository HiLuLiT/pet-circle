import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  String? _selectedBreed;
  bool _breedDropdownOpen = false;
  Uint8List? _selectedImageBytes;
  late AnimationController _chevronController;
  
  // Breed data
  List<_BreedItem> _allBreeds = [];
  List<_BreedItem> _filteredBreeds = [];
  bool _isLoadingBreeds = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fetchBreeds();
    _searchController.addListener(_filterBreeds);
  }

  @override
  void dispose() {
    _chevronController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBreeds() async {
    try {
      final response = await http.get(
        Uri.parse('https://dog.ceo/api/breeds/list/all'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'] as Map<String, dynamic>;
        
        final breeds = <_BreedItem>[];
        
        message.forEach((breed, subBreeds) {
          final subList = List<String>.from(subBreeds);
          if (subList.isEmpty) {
            // No sub-breeds, just add the main breed
            breeds.add(_BreedItem(
              displayName: _capitalize(breed),
              breed: breed,
            ));
          } else {
            // Add sub-breeds with format "SubBreed Breed" (e.g., "Golden Retriever")
            for (final sub in subList) {
              breeds.add(_BreedItem(
                displayName: '${_capitalize(sub)} ${_capitalize(breed)}',
                breed: breed,
                subBreed: sub,
              ));
            }
          }
        });
        
        // Sort alphabetically
        breeds.sort((a, b) => a.displayName.compareTo(b.displayName));
        
        setState(() {
          _allBreeds = breeds;
          _filteredBreeds = breeds;
          _isLoadingBreeds = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingBreeds = false);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void _filterBreeds() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBreeds = _allBreeds;
      } else {
        _filteredBreeds = _allBreeds.where((breed) {
          return breed.displayName.toLowerCase().contains(query) ||
              breed.breed.toLowerCase().contains(query) ||
              (breed.subBreed?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _toggleBreedDropdown() {
    setState(() {
      _breedDropdownOpen = !_breedDropdownOpen;
      if (_breedDropdownOpen) {
        _chevronController.forward();
      } else {
        _chevronController.reverse();
        _searchController.clear();
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
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
          // Breed dropdown with search
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
                  Expanded(
                    child: Text(
                      _selectedBreed ?? 'Select breed',
                      style: AppTextStyles.body.copyWith(
                        color: _selectedBreed == null
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_isLoadingBreeds)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.burgundy,
                      ),
                    )
                  else
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
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search field
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search breeds...',
                              hintStyle: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: AppColors.offWhite,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                            style: AppTextStyles.body,
                          ),
                        ),
                        // Breed list
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: _filteredBreeds.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'No breeds found',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    bottom: 8,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: _filteredBreeds.length,
                                  itemBuilder: (context, index) {
                                    final breed = _filteredBreeds[index];
                                    final isSelected =
                                        breed.displayName == _selectedBreed;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedBreed = breed.displayName;
                                          _breedDropdownOpen = false;
                                        });
                                        _chevronController.reverse();
                                        _searchController.clear();
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                breed.displayName,
                                                style:
                                                    AppTextStyles.body.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            if (breed.subBreed != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.burgundy
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _capitalize(breed.breed),
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                    color: AppColors.burgundy,
                                                    fontSize: 10,
                                                  ),
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
