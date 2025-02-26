import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/library.dart';

class LibraryThumbnail extends StatelessWidget {
  const LibraryThumbnail({super.key, required this.library});
  final Library library;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.library_music,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
