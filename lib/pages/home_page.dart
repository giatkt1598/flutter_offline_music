import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/mini_player.dart';
import 'package:flutter_offline_music/pages/library_list_page.dart';
import 'package:flutter_offline_music/pages/load_music_page.dart';
import 'package:flutter_offline_music/pages/search_page.dart';
import 'package:flutter_offline_music/pages/setting_page.dart';
import 'package:flutter_offline_music/pages/full_music_list_page.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_offline_music/utilities/app_background_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool initMiniPlayer = false;

  @override
  Widget build(BuildContext context) {
    SharedData.fullHeight = MediaQuery.of(context).size.height;
    SharedData.fullWidth = MediaQuery.of(context).size.width;
    SharedData.statusBarHeight = MediaQuery.of(context).padding.top;
    SharedData.rootContext = context;
    if (!initMiniPlayer) {
      setState(() {
        initMiniPlayer = true;
      });
      Future.delayed(
        Duration(seconds: 1),
      ).then((_) => MiniPlayer.showMiniPlayer(context));
    }
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
              IconButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => SearchPage()));
                },
                icon: Icon(Icons.search),
              ),
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
            children: [FullMusicListPage(), LibraryListPage(), LoadMusicPage()],
          ),
        ),
      ),
    );
  }
}
