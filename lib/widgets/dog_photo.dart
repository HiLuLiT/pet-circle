import 'package:flutter/material.dart';
import 'package:pet_circle/theme/app_theme.dart';

class DogPhoto extends StatefulWidget {
  const DogPhoto({
    super.key,
    required this.endpoint,
    this.fit = BoxFit.cover,
  });

  final String endpoint;
  final BoxFit fit;

  @override
  State<DogPhoto> createState() => _DogPhotoState();
}

class _DogPhotoState extends State<DogPhoto> {
  @override
  Widget build(BuildContext context) {
    final source = widget.endpoint.trim();
    if (source.isEmpty) {
      return Container(
        color: AppColors.offWhite,
        alignment: Alignment.center,
        child: const Icon(Icons.pets, color: AppColors.chocolate),
      );
    }

    if (source.startsWith('http')) {
      return Image.network(source, fit: widget.fit);
    }

    return Image.asset(source, fit: widget.fit);
  }
}
