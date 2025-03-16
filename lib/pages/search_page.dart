import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_folder_item.dart';
import 'package:flutter_offline_music/components/library_list_item.dart';
import 'package:flutter_offline_music/components/music_list_item.dart';
import 'package:flutter_offline_music/components/search_field.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/music_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _musicService = MusicService();
  final _libraryService = LibraryService();
  List<Music> _musics = [];
  List<MusicFolder> _folders = [];
  List<Library> _libraries = [];
  String? keyword;

  bool get hasResult =>
      _musics.length + _folders.length + _libraries.length > 0;

  Future<void> handleSearch(String keyword) async {
    this.keyword = keyword;
    var musics = await _musicService.searchMusics(keyword);
    var folders = await _musicService.searchFolders(keyword);
    var libraries = await _libraryService.searchLibraries(keyword);
    setState(() {
      _musics = musics;
      _folders = folders;
      _libraries = libraries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchField(
          autoFocus: true,
          onChanged: (value) {
            handleSearch(value);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_musics.isNotEmpty) _SearchResultGroupTitle(title: 'Bài hát'),
            for (var music in _musics)
              MusicListItem(
                music: music,
                keywordSearch: keyword,
                afterHideItem: () {
                  handleSearch(keyword!);
                },
              ),

            if (_libraries.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 4),
                child: _SearchResultGroupTitle(title: 'Thư viện'),
              ),
            for (var library in _libraries)
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LibraryListItem(
                  keywordSearch: keyword,
                  library: library,
                  onRefresh: () {
                    handleSearch(keyword!);
                  },
                ),
              ),
            if (_folders.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 4),
                child: _SearchResultGroupTitle(title: 'Thư mục'),
              ),
            for (var folder in _folders)
              MusicFolderItem(
                showHiddenInfo: true,
                keywordSearch: keyword,
                folder: folder,
                onRefresh: () => handleSearch(keyword!),
              ),
            if (hasResult)
              SizedBox(height: 90)
            else if (keyword?.isNotEmpty == true)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('Không có kết quả'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultGroupTitle extends StatelessWidget {
  final String title;
  const _SearchResultGroupTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16),
      child: Row(
        children: [Text(title, style: Theme.of(context).textTheme.labelLarge)],
      ),
    );
  }
}
