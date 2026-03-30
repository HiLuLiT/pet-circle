import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/app_routes.dart';
import 'package:pet_circle/stores/measurement_store.dart';
import 'package:pet_circle/stores/note_store.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/stores/user_store.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/models/measurement.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/app_theme.dart';
import 'package:pet_circle/widgets/breed_search_field.dart';
import 'package:pet_circle/widgets/dog_photo.dart';
import 'package:pet_circle/widgets/neumorphic_card.dart';
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
    final c = AppColorsTheme.of(context);
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
            color: c.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.editPet, style: AppTextStyles.heading3.copyWith(color: c.chocolate)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.petName,
                    filled: true, fillColor: c.offWhite,
                    border: OutlineInputBorder(borderRadius: const BorderRadius.all(AppRadii.small), borderSide: BorderSide.none),
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
                    filled: true, fillColor: c.offWhite,
                    border: OutlineInputBorder(borderRadius: const BorderRadius.all(AppRadii.small), borderSide: BorderSide.none),
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
                      style: TextButton.styleFrom(backgroundColor: c.lightBlue),
                      child: Text(l10n.save, style: TextStyle(color: c.chocolate)),
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
    final c = AppColorsTheme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.clinicalNoteAdded),
        backgroundColor: c.lightBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Scaffold(
      backgroundColor: c.white,
      body: ListenableBuilder(
        listenable: Listenable.merge([noteStore, measurementStore, petStore]),
        builder: (context, _) => CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoSection(),
                const SizedBox(height: 24),
                _buildMeasurementHistory(),
                const SizedBox(height: 24),
                _buildClinicalNotes(),
                const SizedBox(height: 24),
                _buildCareCircle(),
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
    final c = AppColorsTheme.of(context);
    final access = petStore.accessForPet(_pet);
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: c.chocolate,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: c.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (access.canEditPet)
          IconButton(
            icon: Icon(Icons.edit, color: c.white),
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
                    c.chocolate.withValues(alpha: 0.8),
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
                    style: AppTextStyles.heading1.copyWith(color: c.white),
                  ),
                  Text(
                    _pet.breedAndAge,
                    style: AppTextStyles.body.copyWith(
                      color: c.white.withValues(alpha: 0.8),
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

  Widget _buildInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final latestFromStore = measurementStore.latestForPet(_pet.id ?? '');
    final latest = latestFromStore ?? _pet.latestMeasurement;
    final hasMeasurement = latest.bpm > 0;
    return NeumorphicCard(
      radius: const BorderRadius.all(AppRadii.medium),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.latestReading,
            style: AppTextStyles.heading3.copyWith(color: c.chocolate),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.favorite,
                  iconColor: c.pink,
                  value: hasMeasurement ? '${latest.bpm}' : '--',
                  label: l10n.bpm,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoTile(
                  icon: Icons.access_time,
                  iconColor: c.lightBlue,
                  value: hasMeasurement ? latest.timeAgo : l10n.noMeasurementsYet,
                  label: l10n.lastMeasured,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementHistory() {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final storeMeasurements = measurementStore.getMeasurements(_pet.id ?? '');
    final List<Measurement> measurements = storeMeasurements.isNotEmpty
        ? storeMeasurements
        : (_pet.latestMeasurement.bpm > 0 ? [_pet.latestMeasurement] : <Measurement>[]);

    return NeumorphicCard(
      radius: const BorderRadius.all(AppRadii.medium),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.measurementHistory,
                style: AppTextStyles.heading3.copyWith(color: c.chocolate),
              ),
              TextButton.icon(
                onPressed: () {
                  petStore.setActivePet(_pet);
                  context.go(AppRoutes.shell(userStore.role, tab: 1));
                },
                icon: const Icon(Icons.show_chart, size: 18),
                label: Text(l10n.viewGraph),
                style: TextButton.styleFrom(foregroundColor: c.lightBlue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simple bar chart visualization
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: measurements.take(5).map((m) {
                final height = (m.bpm / 40) * 60;
                final isElevated = m.bpm > 30;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${m.bpm}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isElevated ? c.cherry : c.lightBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(20, 60),
                          decoration: BoxDecoration(
                            color: isElevated
                                ? c.cherry.withValues(alpha: 0.3)
                                : c.lightBlue.withValues(alpha: 0.3),
                            borderRadius: const BorderRadius.all(AppRadii.xs),
                            border: Border.all(
                              color: isElevated ? c.cherry : c.lightBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: measurements.take(5).map((m) {
              return Expanded(
                child: Text(
                  m.timeAgo.replaceAll(' ago', ''),
                  style: AppTextStyles.caption.copyWith(fontSize: 9),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalNotes() {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    final access = petStore.accessForPet(_pet);
    final notes = noteStore.getNotes(_pet.id ?? '');
    return NeumorphicCard(
      radius: const BorderRadius.all(AppRadii.medium),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_outlined, color: c.chocolate),
              const SizedBox(width: 8),
              Text(
                l10n.clinicalNotes,
                style: AppTextStyles.heading3.copyWith(color: c.chocolate),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Add note input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.offWhite,
              borderRadius: const BorderRadius.all(AppRadii.small),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  readOnly: !access.canAddNotes,
                  decoration: InputDecoration(
                    hintText: l10n.addClinicalNoteHint,
                    hintStyle: AppTextStyles.body.copyWith(color: c.chocolate),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: access.canAddNotes ? _addNote : null,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addNote),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.chocolate,
                      foregroundColor: c.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(AppRadii.large),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            ...notes.map((note) => _NoteCard(note: note)),
          ],
          if (notes.isEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notes,
                    size: 40,
                    color: c.chocolate.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noClinicalNotesYet,
                    style: AppTextStyles.body.copyWith(color: c.chocolate),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCareCircle() {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColorsTheme.of(context);
    return NeumorphicCard(
      radius: const BorderRadius.all(AppRadii.medium),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, color: c.chocolate),
              const SizedBox(width: 8),
              Text(
                l10n.careCircle,
                style: AppTextStyles.heading3.copyWith(color: c.chocolate),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._pet.careCircle.map(
            (member) => _MemberTile(member: member),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.offWhite,
        borderRadius: const BorderRadius.all(AppRadii.small),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.all(AppRadii.small),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.heading3.copyWith(color: c.chocolate),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final ClinicalNote note;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(note.authorAvatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      note.authorName,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      note.timeAgo,
                      style: AppTextStyles.caption.copyWith(color: c.chocolate),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(note.content, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final CareCircleMember member;

  @override
  Widget build(BuildContext context) {
    final c = AppColorsTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(member.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  member.roleLabel,
                  style: AppTextStyles.caption.copyWith(color: c.chocolate),
                ),
              ],
            ),
          ),
          _RoleBadge(role: member.role, label: member.roleLabel),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.label});

  final CareCircleRole role;
  final String label;

  Color _color(BuildContext context) {
    final c = AppColorsTheme.of(context);
    switch (role) {
      case CareCircleRole.admin:
        return c.chocolate;
      case CareCircleRole.member:
        return c.lightBlue;
      case CareCircleRole.viewer:
        return c.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.all(AppRadii.small),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
