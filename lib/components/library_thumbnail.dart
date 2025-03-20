import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/library.dart';

class LibraryThumbnail extends StatelessWidget {
  const LibraryThumbnail({
    super.key,
    required this.library,
    this.size = 60,
    this.radius = 6,
  });
  final Library library;

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    List<String> itemImages =
        library.musics
            .where((x) => x.thumbnail != null)
            .take(4)
            .map((x) => x.thumbnail!)
            .toList();

    if (itemImages.length == 4) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: GridView.count(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 2,
                  primary: false,
                  children: [
                    for (String imgPath in itemImages)
                      Image.file(File(imgPath), fit: BoxFit.cover),
                  ],
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: Center(
                    child: Image.asset(
                      'assets/audio-waves.png',
                      width: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (itemImages.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          image: DecorationImage(
            image: FileImage(File(itemImages.first)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Icons.library_music,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
