import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';
import 'package:pet_circle/theme/semantic/text_theme.dart';

/// Placeholder screen for the Diary tab.
///
/// Will be replaced with the full diary/notes UI in a future phase.
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final c = AppSemanticColors.of(context);
    final body = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book, size: 48, color: c.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Diary',
            style: AppSemanticTextStyles.title3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style:
                AppSemanticTextStyles.bodyMuted.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );

    if (!showScaffold) return body;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(child: body),
    );
  }
}
