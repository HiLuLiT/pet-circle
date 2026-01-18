import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Center(
        child: Text(
          'Trends coming soon',
          style: AppTextStyles.heading3.copyWith(color: AppColors.burgundy),
        ),
      ),
    );

    if (!showScaffold) {
      return Container(color: AppColors.white, child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: content,
    );
  }
}
