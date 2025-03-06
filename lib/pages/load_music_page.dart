import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/components/folder_list_item.dart';
import 'package:flutter_offline_music/components/hidden_music_folder_info.dart';
import 'package:flutter_offline_music/components/no_data.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/providers/music_folder_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/permission_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/utilities/debug_helper.dart';
import 'package:provider/provider.dart';

class LoadMusicPage extends StatefulWidget {
  const LoadMusicPage({super.key});

  @override
  State<LoadMusicPage> createState() => _LoadMusicPageState();
}

class _LoadMusicPageState extends State<LoadMusicPage> {
  final MusicService _musicService = MusicService();
  final PermissionService _permissionService = PermissionService();
  List<MusicFolder> _musicFolders = [];
  int totalHiddenFolder = 0;
  int totalHiddenFile = 0;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() {
    _musicService.getMusicFolderListAsync(isHidden: null).then((rs) {
      setState(() {
        _musicFolders = rs;
        totalHiddenFolder = 0;
        totalHiddenFile = 0;
        for (final mf in _musicFolders) {
          totalHiddenFolder += mf.isHidden ? 1 : 0;
          totalHiddenFile +=
              mf.musics.where((x) => mf.isHidden || x.isHidden).length;
        }

        //#region for debugging
        // _musicFolders.addAll(
        //   List.generate(
        //     20,
        //     (idx) => MusicFolder(id: idx, path: 'path', name: 'name $idx'),
        //   ),
        // );
        //#endregion
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final musicFolderProvider = Provider.of<MusicFolderProvider>(context);
    Future<void> scanMusic() async {
      EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        status: 'Đang quét nhạc...',
        dismissOnTap: false,
      );
      if (await _permissionService.requestStoragePermissionAsync()) {
        var list = await _musicService.scanMusicAsync(
          onCompleted: (totalNewFile, totalDeletedFile) {
            ToastService.showSuccess(
              [
                'Quét thành công',
                totalNewFile == 0
                    ? 'không có tệp mới'
                    : 'đã thêm $totalNewFile bài hát',
                totalDeletedFile > 0
                    ? 'gỡ bỏ $totalDeletedFile bài hát vì không tìm thấy tệp trên thiết bị'
                    : null,
              ].where((x) => x != null).join(', '),
              duration: Duration(seconds: 5),
            );
          },
        );
        // _musicService.fetchSkipSilentDurations();
        setState(() {
          _musicFolders = list;
        });
      } else {
        logDebug("Permission Denied");
      }
      EasyLoading.dismiss();
    }

    return Scaffold(
      body: Column(
        spacing: 4,
        children: [
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: OutlinedButton(
              onPressed: scanMusic,
              child: Text('Quét nhạc'),
            ),
          ),
          if (totalHiddenFolder == 0 && _musicFolders.isEmpty)
            Padding(padding: const EdgeInsets.only(top: 24), child: NoData())
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: _musicFolders.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _musicFolders.length) {
                      if (totalHiddenFile == 0 && totalHiddenFolder == 0) {
                        return Container();
                      }
                      return HiddenMusicFolderInfo(
                        totalHiddenFile: totalHiddenFile,
                        totalHiddenFolder: totalHiddenFolder,
                      );
                    }

                    final folder = _musicFolders[index];

                    return Visibility(
                      visible:
                          musicFolderProvider.isShowAllMusicFolder ||
                          !folder.isHidden,
                      child: FolderListItem(
                        folder: folder,
                        onRefresh: loadData,
                        showHiddenInfo:
                            musicFolderProvider.isShowAllMusicFolder,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
