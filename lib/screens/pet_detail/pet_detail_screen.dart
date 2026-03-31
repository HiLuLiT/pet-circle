import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/screens/pet_detail/pet_detail_sections.dart';
import 'package:pet_circle/stores/note_store.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';
import 'package:pet_circle/widgets/breed_search_field.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/status_badge.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key, required this.pet});

  final Pet pet;

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final _noteController = TextEditingController();
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showEditSheet() {
    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    final nameCtrl = TextEditingController(text: _pet.name);
    final imageCtrl = TextEditingController(text: _pet.imageUrl);
    String selectedBreed = _pet.breedAndAge;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.editPet, style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.petName,
                    filled: true, fillColor: c.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadiiTokens.sm), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                BreedSearchField(
                  label: l10n.breed,
                  initialValue: _pet.breedAndAge,
                  onChanged: (breed) => selectedBreed = breed,
                  maxHeight: 150,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.photoUrl,
                    filled: true, fillColor: c.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadiiTokens.sm), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        final navigator = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        final updated = _pet.copyWith(
                          name: nameCtrl.text.isNotEmpty ? nameCtrl.text : _pet.name,
                          breedAndAge: selectedBreed.isNotEmpty
                              ? selectedBreed
                              : _pet.breedAndAge,
                          imageUrl: imageCtrl.text.isNotEmpty
                              ? imageCtrl.text
                              : _pet.imageUrl,
                        );
                        petStore.updatePetWithFirestore(updated);
                        setState(() => _pet = updated);
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.petUpdated)),
                        );
                      },
                      style: TextButton.styleFrom(backgroundColor: c.primaryLight),
                      child: Text(l10n.save, style: TextStyle(color: c.textPrimary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addNote() {
    final access = petStore.accessForPet(_pet);
    if (!access.canAddNotes || _noteController.text.trim().isEmpty) return;

    final petId = _pet.id;
    if (petId == null || petId.isEmpty) return;
    final user = userStore.currentUser;
    noteStore.addNote(
      petId,
      ClinicalNote(
        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
        authorUid: userStore.currentUserUid,
        authorName: user?.name ?? 'Unknown',
        authorAvatarUrl: user?.avatarUrl ?? '',
        content: _noteController.text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    _noteController.clear();

    final l10n = AppLocalizations.of(context)!;
    final c = AppSemanticColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.clinicalNoteAdded),
        backgroundColor: c.primaryLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: ListenableBuilder(
        listenable: Listenable.merge([noteStore, measurementStore, petStore]),
        builder: (context, _) => CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  PetInfoSection(pet: _pet),
                  const SizedBox(height: 24),
                  PetMeasurementHistory(pet: _pet),
                  const SizedBox(height: 24),
                  PetClinicalNotes(
                    pet: _pet,
                    noteController: _noteController,
                    onAddNote: _addNote,
                  ),
                  const SizedBox(height: 24),
                  PetCareCircle(pet: _pet),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final c = AppSemanticColors.of(context);
    final access = petStore.accessForPet(_pet);
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: c.textPrimary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: c.background),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (access.canEditPet)
          IconButton(
            icon: Icon(Icons.edit, color: c.background),
            onPressed: _showEditSheet,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            DogPhoto(endpoint: _pet.imageUrl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    c.textPrimary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(
                        label: _pet.statusLabel,
                        color: Color(_pet.statusColorHex),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pet.name,
                    style: AppSemanticTextStyles.title2.copyWith(color: c.background),
                  ),
                  Text(
                    _pet.breedAndAge,
                    style: AppSemanticTextStyles.body.copyWith(
                      color: c.background.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
