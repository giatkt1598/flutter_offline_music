import 'dart:io';

import 'package:flutter/material.dart';

class MusicThumbnail extends StatelessWidget {
  const MusicThumbnail({
    super.key,
    required this.thumbnailPath,
    this.size,
    this.boxShape,
    this.borderRadius,
    this.fallbackWidget,
  });

  final String? thumbnailPath;
  final double? size;
  final BoxShape? boxShape;
  final BorderRadiusGeometry? borderRadius;
  final Widget? fallbackWidget;

  @override
  Widget build(BuildContext context) {
    var currentBorderRadius =
        borderRadius ?? BorderRadius.all(Radius.circular(8));

    return SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child:
          thumbnailPath == null
              ? fallbackWidget ??
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: boxShape ?? BoxShape.circle,
                      borderRadius:
                          boxShape == BoxShape.rectangle
                              ? currentBorderRadius
                              : null,
                    ),
                    child: Icon(Icons.music_note_rounded),
                  )
              : (boxShape == BoxShape.rectangle)
              ? ClipRRect(
                borderRadius: currentBorderRadius,
                child: Image.file(File(thumbnailPath!), fit: BoxFit.cover),
              )
              : ClipOval(
                child: Image.file(File(thumbnailPath!), fit: BoxFit.cover),
              ),
    );
  }
}
