import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_list_item.dart';
import 'package:flutter_offline_music/components/no_data.dart';
import 'package:flutter_offline_music/models/music.dart';

class MusicList extends StatefulWidget {
  const MusicList({
    super.key,
    required this.musics,
    this.onChanged,
    this.leadingItem,
    this.trailingItem,
    this.removeInvisibleItem = true,
  });

  final List<Music> musics;
  final ValueChanged<List<Music>>? onChanged;
  final Widget? leadingItem;
  final Widget? trailingItem;
  final bool removeInvisibleItem;

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  List<Music> get musics => widget.musics;

  @override
  Widget build(BuildContext context) {
    if (musics.isEmpty) {
      return Column(
        children: [
          widget.leadingItem ?? Container(),
          NoData(),
          widget.trailingItem ?? Container(),
        ],
      );
    }

    return ListView.builder(
      itemCount: musics.length + 3,
      itemBuilder: (context, index) {
        if (index == 0) {
          return widget.leadingItem ?? Container();
        }

        if (index == musics.length + 1) {
          return widget.trailingItem ?? Container();
        }

        if (index == musics.length + 2) {
          return SizedBox(height: 90);
        }

        final item = musics[index - 1];
        return MusicListItem(
          music: item,
          afterHideItem: () {
            if (widget.removeInvisibleItem && item.isHidden) {
              musics.remove(item);
            }
            if (widget.onChanged != null) widget.onChanged!(musics);
          },
        );
      },
    );
  }
}
