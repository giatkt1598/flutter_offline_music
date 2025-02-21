import 'package:flutter/material.dart';
import 'package:flutter_offline_music/pages/load_music_page.dart';
import 'package:flutter_offline_music/pages/song_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('G-Player'),
          actions: [
            IconButton(onPressed: null, icon: Icon(Icons.search)),
            IconButton(onPressed: null, icon: Icon(Icons.settings)),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(child: Text('Bài hát')),
              Tab(child: Text('Danh sách phát')),
              Tab(child: Text('Thư mục')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SongListPage(),
            Center(child: Text("Tìm kiếm")),
            LoadMusicPage(),
          ],
        ),
      ),
    );
  }
}
