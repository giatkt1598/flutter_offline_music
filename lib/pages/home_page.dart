import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/mini_player.dart';
import 'package:flutter_offline_music/pages/dashboard_page.dart';
import 'package:flutter_offline_music/pages/library_list_page.dart';
import 'package:flutter_offline_music/pages/load_music_page.dart';
import 'package:flutter_offline_music/pages/search_page.dart';
import 'package:flutter_offline_music/pages/setting_page.dart';
import 'package:flutter_offline_music/pages/full_music_list_page.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_offline_music/utilities/app_background_helper.dart';
import 'package:flutter_offline_music/utilities/theme_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool initMiniPlayer = false;

  final tabControls = ['Đề xuất', 'Bài hát', 'Thư viện', 'Thư mục'];

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
        length: 4,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    pinned: true, // Luôn hiển thị AppBar khi cuộn
                    floating: true, // Không tự động hiện khi cuộn lên
                    expandedHeight: 90, // Chiều cao mở rộng
                    title: Text('Trình phát nhạc'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    shadowColor: isDarkMode() ? Colors.white12 : Colors.black26,
                    // forceMaterialTransparency: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    surfaceTintColor: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SearchPage(),
                            ),
                          );
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
                    flexibleSpace: FlexibleSpaceBar(background: Container()),
                    bottom: TabBar(
                      physics: AlwaysScrollableScrollPhysics(),
                      dragStartBehavior: DragStartBehavior.start,
                      tabAlignment: TabAlignment.start,
                      labelPadding: EdgeInsets.symmetric(horizontal: 0),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      isScrollable: true,
                      // indicatorPadding: EdgeInsets.only(bottom: 8, top: 8),
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      automaticIndicatorColorAdjustment: false,
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            blurRadius: 10,
                            spreadRadius: -6,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      labelColor: Theme.of(context).textTheme.bodyMedium!.color,
                      splashBorderRadius: BorderRadius.circular(9999),
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: [
                        _buildTabTitle('Đề xuất'),
                        _buildTabTitle('Bài hát'),
                        _buildTabTitle('Thư viện'),
                        _buildTabTitle('Thư mục'),
                      ],
                    ),
                  ),
                ],
            body: TabBarView(
              children: [
                DashboardPage(),
                FullMusicListPage(),
                LibraryListPage(),
                LoadMusicPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Tab _buildTabTitle(String tabTitle) {
    return Tab(
      height: 30,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          spacing: 4,
          children: [Text(tabTitle, overflow: TextOverflow.ellipsis)],
        ),
      ),
    );
  }
}
