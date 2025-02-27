import 'package:flutter/material.dart';
import 'package:flutter_offline_music/providers/music_folder_provider.dart';
import 'package:provider/provider.dart';

class HiddenMusicFolderInfo extends StatelessWidget {
  const HiddenMusicFolderInfo({
    super.key,
    this.totalHiddenFolder,
    this.totalHiddenFile,
  });

  final int? totalHiddenFolder;
  final int? totalHiddenFile;

  @override
  Widget build(BuildContext context) {
    final musicFolderProvider = Provider.of<MusicFolderProvider>(context);
    String message =
        '${[totalHiddenFolder != null ? '$totalHiddenFolder thư mục' : null, totalHiddenFile != null ? '$totalHiddenFile tệp' : null].where((x) => x != null).join(' và ')} bị ẩn';

    return Column(
      children: [
        SizedBox(width: 30, child: Divider()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(opacity: 0.4, child: Row(children: [Text(message)])),
          ],
        ),
        InkWell(
          onTap: () {
            musicFolderProvider.setShowAllMusicFolder(
              !musicFolderProvider.isShowAllMusicFolder,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
            child: Text(
              !musicFolderProvider.isShowAllMusicFolder
                  ? 'Xem tệp bị ẩn'
                  : 'Không hiển thị tệp ẩn',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
