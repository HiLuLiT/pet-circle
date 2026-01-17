import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = _fetchDogImage();
  }

  Future<String> _fetchDogImage() async {
    final uri = Uri.parse(widget.endpoint);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Dog API error ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['message'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.network(snapshot.data!, fit: widget.fit);
        }
        if (snapshot.hasError) {
          return Container(
            color: AppColors.offWhite,
            alignment: Alignment.center,
            child: const Icon(Icons.pets, color: AppColors.textMuted),
          );
        }
        return const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
