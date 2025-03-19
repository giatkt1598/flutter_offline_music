import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/library_thumbnail.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';

class AddMusicItemToLibrary extends StatefulWidget {
  const AddMusicItemToLibrary({
    super.key,
    required this.music,
    this.scrollController,
  });

  final Music music;
  final ScrollController? scrollController;
  @override
  State<AddMusicItemToLibrary> createState() => _AddMusicItemToLibraryState();
}

class _AddMusicItemToLibraryState extends State<AddMusicItemToLibrary> {
  List<Library> libraries = [];
  final libraryService = LibraryService();
  @override
  void initState() {
    loadLibraries();
    super.initState();
  }

  loadLibraries() async {
    var rs = await libraryService.getListAsync(
      orderBy: 'lastModificationTime desc',
    );
    setState(() {
      libraries = rs;
    });
  }

  addToLibrary(Library library) async {
    await libraryService.addMusicToLibraryAsync(
      musicId: widget.music.id,
      libraryId: library.id,
    );

    ToastService.showSuccess(tr().message_addMusicToLibrarySuccess);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  tr().libraryMenu_addItem,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Opacity(opacity: 0.3, child: Divider()),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                for (var library in libraries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      onTap: () {
                        addToLibrary(library);
                      },
                      contentPadding: EdgeInsets.only(left: 16, right: 4),
                      leading: LibraryThumbnail(library: library),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            library.title,
                            style: TextStyle(fontWeight: FontWeight.normal),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          Row(
                            children: [
                              Opacity(
                                opacity: 0.4,
                                child: Text(
                                tr().nSongs(library.musics.length),
                                  style: TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (library.musics.any(
                                (x) => x.id == widget.music.id,
                              ))
                                Text(
                                  tr().library_musicExists,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                ),
                            ],
                          ),
                        ],
                      ),
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
