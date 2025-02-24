import 'package:flutter/material.dart';
import 'package:flutter_offline_music/pages/load_music_page.dart';
import 'package:flutter_offline_music/pages/setting_page.dart';
import 'package:flutter_offline_music/pages/song_list_page.dart';
import 'package:flutter_offline_music/utilities/app_background_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        AppBackgroundHelper.moveAppToBackground();
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('G-Player'),
            actions: [
              IconButton(onPressed: null, icon: Icon(Icons.search)),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingPage(),
                    ),
                  );
                },
                icon: Icon(Icons.settings),
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(child: Text('Bài hát')),
                Tab(child: Text('Thư viện')),
                Tab(child: Text('Thư mục')),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              SongListPage(),
              Center(child: Text("Thư viện")),
              LoadMusicPage(),
            ],
          ),
        ),
      ),
    );
  }
}
