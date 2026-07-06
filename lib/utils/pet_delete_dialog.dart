import 'package:flutter/material.dart';
import 'package:pet_circle/l10n/app_localizations.dart';
import 'package:pet_circle/models/pet.dart';
import 'package:pet_circle/stores/pet_store.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';
import 'package:pet_circle/theme/tokens/spacing.dart';

/// Shows the "Delete pet" confirmation dialog and, once confirmed, removes
/// [pet] via [PetStore.removePetWithFirestore].
///
/// Shared between the owner home dashboard (long-press on the hero pet
/// card) and the pet detail edit sheet (explicit delete icon button) so
/// both surfaces stay in sync on copy and behavior.
void confirmDeletePet(BuildContext context, Pet pet) {
  final l10n = AppLocalizations.of(context)!;
  final c = AppSemanticColors.of(context);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadiiTokens.md),
      ),
      title: Text(l10n.deletePet,
          style: AppSemanticTextStyles.headingLg.copyWith(color: c.textPrimary)),
      content: Text(l10n.deletePetConfirmation(pet.name),
          style: AppSemanticTextStyles.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            petStore.removePetWithFirestore(pet.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.petDeleted)),
            );
          },
          style: TextButton.styleFrom(backgroundColor: c.error),
          child: Text(l10n.deletePet, style: TextStyle(color: c.background)),
        ),
      ],
    ),
  );
}
