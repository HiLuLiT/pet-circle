import 'package:flutter/material.dart';
import 'package:pet_circle/theme/semantic/color_scheme.dart';

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
    final c = AppSemanticColors.of(context);
    final source = widget.endpoint.trim();
    if (source.isEmpty) {
      return Container(
        color: c.surface,
        alignment: Alignment.center,
        child: Icon(Icons.pets, color: c.textTertiary),
      );
    }

    if (source.startsWith('http')) {
      return Image.network(source, fit: widget.fit);
    }

    return Image.asset(source, fit: widget.fit);
  }
}
