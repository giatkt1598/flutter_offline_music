import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/highlighted_text.dart';
import 'package:flutter_offline_music/components/music_folder_item_menu.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/pages/music_in_folder_page.dart';

class MusicFolderItem extends StatelessWidget {
  final MusicFolder folder;
  final Function onRefresh;
  final String? keywordSearch;
  final bool showHiddenInfo;
  const MusicFolderItem({
    super.key,
    required this.folder,
    required this.onRefresh,
    this.keywordSearch,
    this.showHiddenInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalFile =
        showHiddenInfo
            ? folder.musics.length
            : folder.musics.where((x) => !x.isHidden).length;

    final totalHiddenFileInfolder =
        folder.musics.where((x) => x.isHidden).length;

    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicInFolderPage(musicFolder: folder),
          ),
        ).then((_) => onRefresh());
      },
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.all(Radius.circular(4)),
                ),
                child: Icon(
                  Icons.folder,
                  size: 50,
                  color: Colors.amber.withValues(
                    alpha: folder.isHidden ? 0.3 : 1,
                  ),
                ),
              ),
              if (folder.isHidden)
                Positioned(
                  bottom: 0,
                  right: 2,
                  child: Icon(Icons.visibility_off_rounded),
                ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    keywordSearch != null
                        ? HighlightedText(
                          fullText: folder.name,
                          highlightedText: keywordSearch!,
                        )
                        : Text(folder.name),
                    if (folder.isHidden)
                      Text(
                        ' (Thư mục ẩn)',
                        style: TextStyle(color: Colors.red),
                      ),
                    if (showHiddenInfo && totalHiddenFileInfolder > 0)
                      Text(
                        ' ($totalHiddenFileInfolder tệp ẩn)',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    '$totalFile bài hát ・ ${folder.path}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          MusicFolderItemMenu(
            musicFolder: folder,
            onRefresh: onRefresh,
            afterHideFolder: onRefresh,
          ),
        ],
      ),
    );
  }
}
