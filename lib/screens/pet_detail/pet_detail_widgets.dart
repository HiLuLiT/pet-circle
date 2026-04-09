import 'package:flutter/material.dart';
import 'package:pet_circle/models/care_circle_member.dart';
import 'package:pet_circle/models/clinical_note.dart';
import 'package:pet_circle/utils/formatters.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
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
    final c = AppSemanticColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacingTokens.sm + 2),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: AppSpacingTokens.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(label, style: AppSemanticTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note});

  final ClinicalNote note;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(note.authorAvatarUrl),
          ),
          SizedBox(width: AppSpacingTokens.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      note.authorName,
                      style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Text(
                      formatTimeAgo(note.createdAt),
                      style: AppSemanticTextStyles.caption.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                Text(note.content, style: AppSemanticTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MemberTile extends StatelessWidget {
  const MemberTile({super.key, required this.member});

  final CareCircleMember member;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacingTokens.sm + 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(member.avatarUrl),
          ),
          SizedBox(width: AppSpacingTokens.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppSemanticTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  member.roleLabel,
                  style: AppSemanticTextStyles.caption.copyWith(color: c.textPrimary),
                ),
              ],
            ),
          ),
          RoleBadge(role: member.role, label: member.roleLabel),
        ],
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role, required this.label});

  final CareCircleRole role;
  final String label;

  Color _color(BuildContext context) {
    final c = AppSemanticColors.of(context);
    switch (role) {
      case CareCircleRole.owner:
        return c.textPrimary;
      case CareCircleRole.member:
        return c.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm + 2, vertical: AppSpacingTokens.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadiiTokens.sm),
      ),
      child: Text(
        label,
        style: AppSemanticTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
