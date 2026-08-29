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
/// Shared between the owner home dashboard (long-press on the hero pet card)
/// and the pet detail screen (explicit "Delete pet" row) so both surfaces stay
/// in sync on copy and behavior.
///
/// Returns `true` only when the pet was actually deleted. The delete is
/// awaited and its failure caught here rather than fired and forgotten: the
/// store rolls its lists back and rethrows when Firestore rejects the write,
/// so reporting success without waiting would show "Pet deleted" for a pet
/// that then reappears.
Future<bool> confirmDeletePet(BuildContext context, Pet pet) async {
  final l10n = AppLocalizations.of(context)!;
  final c = AppSemanticColors.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final petId = pet.id;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadiiTokens.borderRadiusCard,
      ),
      title: Text(
        l10n.deletePet,
        style: AppSemanticTextStyles.headingH2.copyWith(color: c.textPrimary),
      ),
      content: Text(
        l10n.deletePetConfirmation(pet.name),
        style: AppSemanticTextStyles.pcBody.copyWith(color: c.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(backgroundColor: c.error),
          child: Text(
            l10n.deletePet,
            style: AppSemanticTextStyles.pcLabelBold.copyWith(color: c.onError),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true) return false;

  // A pet with no id was never persisted, so there is nothing the store can
  // key a delete on. Surface it as a failure rather than silently no-op.
  if (petId == null) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.petDeleteFailed), backgroundColor: c.error),
    );
    return false;
  }

  try {
    await petStore.removePetWithFirestore(petId);
    messenger.showSnackBar(SnackBar(content: Text(l10n.petDeleted)));
    return true;
  } catch (_) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.petDeleteFailed), backgroundColor: c.error),
    );
    return false;
  }
}
