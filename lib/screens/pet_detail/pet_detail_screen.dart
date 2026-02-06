import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/data/mock_data.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/theme/app_theme.dart';
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
  List<ClinicalNote> _notes = [];

  @override
  void initState() {
    super.initState();
    // Load mock notes based on pet
    if (widget.pet.name == 'Princess') {
      _notes = List.from(MockData.princessNotes);
    } else if (widget.pet.name == 'Max') {
      _notes = List.from(MockData.maxNotes);
    } else {
      _notes = [];
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addNote() {
    if (_noteController.text.trim().isEmpty) return;

    setState(() {
      _notes.insert(
        0,
        ClinicalNote(
          id: 'note-${DateTime.now().millisecondsSinceEpoch}',
          authorName: MockData.currentVetUser.name,
          authorAvatarUrl: MockData.currentVetUser.avatarUrl,
          content: _noteController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      _noteController.clear();
    });

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.clinicalNoteAdded),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
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
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.burgundy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            DogPhoto(endpoint: widget.pet.imageUrl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.burgundy.withOpacity(0.8),
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
                        label: widget.pet.statusLabel,
                        color: Color(widget.pet.statusColorHex),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.pet.name,
                    style: AppTextStyles.heading1.copyWith(color: AppColors.white),
                  ),
                  Text(
                    widget.pet.breedAndAge,
                    style: AppTextStyles.body.copyWith(color: AppColors.white.withOpacity(0.8)),
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
    return NeumorphicCard(
      radius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.latestReading,
            style: AppTextStyles.heading3.copyWith(color: AppColors.burgundy),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.favorite,
                  iconColor: AppColors.pink,
                  value: '${widget.pet.latestMeasurement.bpm}',
                  label: l10n.bpm,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoTile(
                  icon: Icons.access_time,
                  iconColor: AppColors.accentBlue,
                  value: widget.pet.latestMeasurement.recordedAtLabel,
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
    final measurements = widget.pet.name == 'Princess'
        ? MockData.princessMeasurements
        : [widget.pet.latestMeasurement];

    return NeumorphicCard(
      radius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.measurementHistory,
                style: AppTextStyles.heading3.copyWith(color: AppColors.burgundy),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.show_chart, size: 18),
                label: Text(l10n.viewGraph),
                style: TextButton.styleFrom(foregroundColor: AppColors.accentBlue),
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
                            color: isElevated ? AppColors.warningAmber : AppColors.successGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(20, 60),
                          decoration: BoxDecoration(
                            color: isElevated
                                ? AppColors.warningAmber.withOpacity(0.3)
                                : AppColors.successGreen.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isElevated ? AppColors.warningAmber : AppColors.successGreen,
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
                  m.recordedAtLabel.replaceAll(' ago', ''),
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
    return NeumorphicCard(
      radius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note_alt_outlined, color: AppColors.burgundy),
              const SizedBox(width: 8),
              Text(
                l10n.clinicalNotes,
                style: AppTextStyles.heading3.copyWith(color: AppColors.burgundy),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Add note input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.addClinicalNoteHint,
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _addNote,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addNote),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.burgundy,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_notes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            ..._notes.map((note) => _NoteCard(note: note)),
          ],
          if (_notes.isEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.notes, size: 40, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noClinicalNotesYet,
                    style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
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
    return NeumorphicCard(
      radius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group, color: AppColors.burgundy),
              const SizedBox(width: 8),
              Text(
                l10n.careCircle,
                style: AppTextStyles.heading3.copyWith(color: AppColors.burgundy),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.pet.careCircle.map(
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
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
                  style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
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
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
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
                  member.role,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          _RoleBadge(role: member.role),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  Color get _color {
    switch (role.toLowerCase()) {
      case 'owner':
        return AppColors.accentBlue;
      case 'veterinarian':
        return AppColors.burgundy;
      case 'caregiver':
        return AppColors.successGreen;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: AppTextStyles.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
