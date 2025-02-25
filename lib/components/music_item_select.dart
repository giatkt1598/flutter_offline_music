import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class MusicItemSelect extends StatelessWidget {
  const MusicItemSelect({
    super.key,
    required this.music,
    required this.isSelected,
    required this.onChanged,
  });

  final Music music;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<PlayerProvider>(context).audioHandler;

    getThumbnail() async {
      return await audioHandler.getPictureFile(music.path);
    }

    return InkWell(
      onTap: () {
        onChanged(!isSelected);
      },
      child: Row(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(value: isSelected, onChanged: onChanged),
          FutureBuilder(
            future: getThumbnail(),
            builder: (context, snapshot) {
              var thumbnail = snapshot.data;
              return SizedBox(
                width: 40,
                height: 40,
                child:
                    thumbnail != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(thumbnail),
                        )
                        : Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.music_note_rounded),
                        ),
              );
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text(
                    music.title,
                    style: TextStyle(fontWeight: FontWeight.normal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Opacity(
                  opacity: 0.4,
                  child: Text(
                    music.artist ?? '<Không rõ tác giả>',
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
