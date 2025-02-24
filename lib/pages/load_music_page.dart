import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/pages/music_in_folder_page.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class LoadMusicPage extends StatefulWidget {
  const LoadMusicPage({super.key});

  @override
  State<LoadMusicPage> createState() => _LoadMusicPageState();
}

class _LoadMusicPageState extends State<LoadMusicPage> {
  final MusicService _musicService = MusicService();
  List<String> musicFormats = [
    '.mp3', // MP3 - Phổ biến nhất
    '.m4a', // MPEG-4 Audio
    '.wma', // Windows Media Audio
    '.flac', // Free Lossless Audio Codec (Không mất dữ liệu)
    '.wav', // Waveform Audio File Format
    '.aac', // Advanced Audio Codec
    '.ogg', // Ogg Vorbis
    '.opus', // Opus - Hiệu suất cao
    '.aiff', // Audio Interchange File Format
    '.alac', // Apple Lossless Audio Codec
    '.dsd', // Direct Stream Digital
    '.pcm', // Pulse Code Modulation
    '.amr', // Adaptive Multi-Rate (dùng cho ghi âm)
    '.mid', // MIDI (dùng cho nhạc cụ điện tử)
    '.mp2', // MPEG Layer II (dùng trong phát sóng)
  ];
  List<MusicFolder> _musicFolders = [];

  @override
  void initState() {
    _musicService.getMusicFolderListAsync().then((rs) {
      setState(() {
        _musicFolders = rs;

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
    super.initState();
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<List<String>> getMusicFolders({
    String folderPath = '/storage/emulated/0',
  }) async {
    List<String> result = [];
    List<String> blacklist = ['/storage/emulated/0/Android'];
    if (blacklist.contains(folderPath)) return result;
    Directory directory = Directory(folderPath);
    if (await directory.exists()) {
      for (var element in directory.listSync()) {
        var type = await FileSystemEntity.type(element.path);
        bool isMusicFile =
            type == FileSystemEntityType.file &&
            musicFormats.any(
              (x) => element.path.toLowerCase().endsWith(x.toLowerCase()),
            );
        if (isMusicFile) {
          result.add(element.parent.path);
        } else if (type == FileSystemEntityType.directory) {
          result.addAll(await getMusicFolders(folderPath: element.path));
        }
      }
      return result.toSet().toList(); // Lists all files and folders
    } else {
      throw Exception("Folder does not exist");
    }
  }

  List<String> getMusicFiles(String filePath) {
    var dir = Directory(filePath);
    var files = dir.listSync();

    return files
        .where((x) => musicFormats.any((f) => x.path.endsWith(f)))
        .map((x) => x.path)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    void scanMusic() async {
      EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        status: 'Đang quét nhạc...',
        dismissOnTap: false,
      );
      if (await requestStoragePermission()) {
        await _musicService.deleteAllMusicFolderAsync();
        await _musicService.deleteAllMusicAsync(); //TODO: delete not exists
        List<String> musicFolderPaths = await getMusicFolders();
        for (String musicFolderPath in musicFolderPaths) {
          String dirName = musicFolderPath.substring(
            musicFolderPath.lastIndexOf('/') + 1,
          );
          int musicFolderId = await _musicService.insertMusicFolderAsync(
            MusicFolder(id: 0, path: musicFolderPath, name: dirName),
          );

          var musicPaths = getMusicFiles(musicFolderPath);
          for (String musicPath in musicPaths) {
            String fileName = musicPath.substring(
              musicPath.lastIndexOf('/') + 1,
              musicPath.lastIndexOf('.'),
            );

            final metadata = readMetadata(File(musicPath));
            await _musicService.insertMusicAsync(
              Music(
                id: 0,
                musicFolderId: musicFolderId,
                title: metadata.title ?? fileName,
                path: musicPath,
                artist: metadata.artist,
                genre: metadata.genres.join(', '),
                lengthInSecond: metadata.duration?.inSeconds ?? 0,
                creationTime: (await File(musicPath).stat()).changed,
              ),
            );
          }
        }
        var list = await _musicService.getMusicFolderListAsync();
        setState(() {
          _musicFolders = list;
        });
        print(list);
      } else {
        print("Permission Denied");
      }
      EasyLoading.dismiss();
    }

    return SingleChildScrollView(
      child: Column(
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 0,
              children:
                  _musicFolders
                      .map(
                        (mf) => TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        MusicInFolderPage(musicFolder: mf),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusDirectional.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                child: Icon(
                                  Icons.folder,
                                  size: 50,
                                  color: Colors.amber,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(mf.name),
                                    Opacity(
                                      opacity: 0.5,
                                      child: Text(
                                        '${mf.musics.length} bài hát ・ ${mf.path}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
