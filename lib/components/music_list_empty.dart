import 'package:flutter/material.dart';

class MusicListEmpty extends StatelessWidget {
  const MusicListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.4,
            child: Icon(Icons.music_off_outlined, size: 32),
          ),
          Opacity(opacity: 0.4, child: Text('Danh sách trống!')),
        ],
      ),
    );
  }
}
