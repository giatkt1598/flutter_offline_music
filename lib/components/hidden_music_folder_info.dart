import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
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
        '${[(totalHiddenFolder ?? 0) > 0 ? tr().nFolders(totalHiddenFolder!) : null, (totalHiddenFile ?? 0) > 0 ? tr().nFiles(totalHiddenFile!) : null].where((x) => x != null).join(' ${tr().and} ')} ${tr().nBeHidden((totalHiddenFolder ?? 0) + (totalHiddenFile ?? 0))}';

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
                  ? tr().viewHiddenFiles
                  : tr().hideHiddenFiles,
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
