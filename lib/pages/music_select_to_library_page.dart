import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/components/music_item_select.dart';
import 'package:flutter_offline_music/components/song_list_sort_button.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/music_service.dart';

class MusicSelectToLibraryPage extends StatefulWidget {
  const MusicSelectToLibraryPage({super.key, required this.libraryId});

  @override
  State<MusicSelectToLibraryPage> createState() =>
      _MusicSelectToLibraryPageState();

  final int libraryId;
}

class _MusicSelectToLibraryPageState extends State<MusicSelectToLibraryPage> {
  final GlobalKey _buttonSelectSourceKey = GlobalKey();
  final MusicService musicService = MusicService();
  final LibraryService libraryService = LibraryService();
  String sourceSelect = 'all';

  final ScrollController _scrollController = ScrollController();
  Map<String, String> menuOptions = {'all': 'Tất cả bài hát'};
  List<Music> musics = [];
  List<Music> selectedMusics = [];
  String sortField = 'creationTime';
  String sortDirection = 'desc';
  late Library library;
  @override
  void initState() {
    loadSelectedMusicList();
    loadMusicList();
    super.initState();
  }

  loadSelectedMusicList() async {
    var lib = await libraryService.getListAsync(id: widget.libraryId);
    setState(() {
      library = lib.first;
      selectedMusics = library.musics;
    });
  }

  loadMusicList() async {
    int? musicFolderId;
    if (sourceSelect.startsWith('Folder')) {
      musicFolderId = int.parse(
        sourceSelect.substring(sourceSelect.indexOf('/') + 1),
      );
    }
    var list = await musicService.getListMusicAsync(
      musicFolderId: musicFolderId,
      orderBy: '$sortField $sortDirection',
    );

    setState(() {
      musics = list;
    });
    _scrollController.jumpTo(0);
  }

  bool get isSelectAll =>
      musics.every((s) => selectedMusics.indexWhere((m) => m.id == s.id) > -1);

  @override
  Widget build(BuildContext context) {
    showMenuLibrarySource() async {
      final List<MusicFolder> musicFolders = await musicService
          .getMusicFolderListAsync(orderBy: 'name asc');
      List<Library> libraries = await libraryService.getListAsync(
        orderBy: 'title asc',
      );
      libraries = libraries.where((x) => x.id != widget.libraryId).toList();

      setState(() {
        for (var folder in musicFolders) {
          menuOptions['Folder/${folder.id}'] = 'Thư mục / ${folder.name}';
        }

        for (var lib in libraries) {
          menuOptions['Library/${lib.id}'] = 'Thư viện / ${lib.title}';
        }
      });

      final btnSelectSourcePosition = (_buttonSelectSourceKey.currentContext!
                  .findRenderObject()
              as RenderBox)
          .localToGlobal(Offset.zero);
      // if (!mounted) return;
      final menuResult = await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          btnSelectSourcePosition.dx,
          btnSelectSourcePosition.dy + 50,
          0,
          0,
        ),
        items: [
          ...menuOptions.keys.map(
            (val) => PopupMenuItem(
              value: val,
              child: Row(
                spacing: 4,
                children: [
                  val == 'all'
                      ? Icon(
                        Icons.all_inbox_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      : val.startsWith('Folder')
                      ? Icon(Icons.folder, color: Colors.amber)
                      : Icon(Icons.list),
                  Text(menuOptions[val]!),
                ],
              ),
            ),
          ),
        ],
      );
      if (menuResult != null) {
        setState(() {
          sourceSelect = menuResult;
        });
        loadMusicList();
      }
    }

    selectAll(bool? isSelect) {
      setState(() {
        selectedMusics.clear();
        if (isSelect == true) selectedMusics.addAll(musics);
      });
    }

    handleSave() async {
      try {
        EasyLoading.show(
          maskType: EasyLoadingMaskType.black,
          status: 'Đang lưu...',
          dismissOnTap: false,
        );

        await libraryService.removeMusicInLibraryAsync(
          libraryId: widget.libraryId,
        );
        for (var item in selectedMusics) {
          await libraryService.addMusicToLibraryAsync(
            musicId: item.id,
            libraryId: widget.libraryId,
          );
        }

        library.lastModificationTime = DateTime.now();
        await libraryService.updateAsync(library);
        Navigator.pop(context);
      } finally {
        EasyLoading.dismiss();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm bài hát'),
        actions: [
          TextButton(
            onPressed: handleSave,
            child: Text(
              'Xong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                key: _buttonSelectSourceKey,
                onPressed: showMenuLibrarySource,
                child: Row(
                  children: [
                    Text(
                      menuOptions[sourceSelect]!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              SongListSortButton(
                initialSortDirection: sortDirection,
                initialSortField: sortField,
                onChanged: (field, direction) {
                  setState(() {
                    sortDirection = direction;
                    sortField = field;
                  });
                  loadMusicList();
                },
              ),
            ],
          ),
          Transform.translate(
            offset: Offset(0, -6),
            child: SizedBox(
              height: 35,
              child: InkWell(
                onTap: () {
                  selectAll(!isSelectAll);
                },
                child: Row(
                  children: [
                    Checkbox(value: isSelectAll, onChanged: selectAll),
                    Text(
                      'Chọn tất cả',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Opacity(
                        opacity: 0.4,
                        child: Text('Đã chọn ${selectedMusics.length} bài hát'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 8),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: musics.length + 1,
                itemBuilder: (context, index) {
                  if (index == musics.length) {
                    return SizedBox(height: 90);
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: MusicItemSelect(
                      music: musics[index],
                      isSelected:
                          selectedMusics.indexWhere(
                            (x) => x.id == musics[index].id,
                          ) >
                          -1,
                      onChanged: (isSelect) {
                        setState(() {
                          if (isSelect == true) {
                            selectedMusics.add(musics[index]);
                          } else if (isSelect == false) {
                            selectedMusics.removeAt(
                              selectedMusics.indexWhere(
                                (x) => x.id == musics[index].id,
                              ),
                            );
                          }
                        });
                      },
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
