import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/components/song_list_sort_button.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';

class ReorderableMusicListPage extends StatefulWidget {
  const ReorderableMusicListPage({super.key, required this.musics});
  final List<Music> musics;
  @override
  State<ReorderableMusicListPage> createState() =>
      _ReorderableMusicListPageState();
}

class _ReorderableMusicListPageState extends State<ReorderableMusicListPage> {
  late List<Music> musics;

  @override
  void initState() {
    musics = widget.musics;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr().libraryMenu_sortItems, style: TextStyle(fontSize: 16)),
            Opacity(
              opacity: .4,
              child: Text(
                '(${tr().nSongs(musics.length)})',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        shadowColor: Colors.transparent,
        actions: [
          TextButton(
            child: Text(tr().doneTitle),
            onPressed: () {
              Navigator.of(context).pop(musics);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Spacer(),
              SongListSortButton(
                initialSortDirection: 'asc',
                initialSortField: '',
                onChanged: (sortField, sortDirection) {
                  setState(() {
                    musics.sort((a, b) {
                      if (sortField == 'title') {
                        return a.title.compareTo(b.title);
                      } else if (sortField == 'artist') {
                        return (a.artist ?? '').compareTo(b.artist ?? '');
                      } else if (sortField == 'duration') {
                        return a.duration.compareTo(b.duration);
                      } else if (sortField == 'creationTime') {
                        return a.creationTime.compareTo(b.creationTime);
                      }
                      return 0;
                    });
                    if (sortDirection == 'desc') {
                      musics = musics.reversed.toList();
                    }
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: ReorderableListView.builder(
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) {
                    return Material(
                      elevation: 6,
                      color: Colors.white.withValues(alpha: 0.4),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              padding: EdgeInsets.only(bottom: 100),
              itemBuilder: (context, index) {
                final music = musics[index];
                return ListTile(
                  key: ValueKey(music.id),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  horizontalTitleGap: 4,
                  visualDensity: VisualDensity(vertical: -4),
                  title: Text(
                    '${index + 1}. ${music.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  subtitle: Opacity(
                    opacity: 0.4,
                    child: Text(
                      music.artist ?? tr().music_unknownArtist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.drag_handle_rounded),
                          MusicThumbnail(thumbnailPath: music.thumbnail),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: musics.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final music = musics.removeAt(oldIndex);
                  musics.insert(newIndex, music);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
