import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';

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
          Opacity(opacity: 0.4, child: Text(tr().emptyList)),
        ],
      ),
    );
  }
}
