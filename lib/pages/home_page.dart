import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/mini_player.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/pages/search_page.dart';
import 'package:flutter_offline_music/pages/setting_page.dart';
import 'package:flutter_offline_music/providers/tab_provider.dart';
import 'package:flutter_offline_music/services/permission_service.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_offline_music/utilities/app_background_helper.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool initMiniPlayer = false;
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2)).then(
      (_) => PermissionService().requestNotificationPermissionAsync(context),
    );
    super.initState();
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    tabProvider.initTabController(vsync: this);
  }

  void setLocaleForTimeAgo() {
    String langCode = Localizations.localeOf(context).languageCode;
    timeago.setDefaultLocale(langCode);
  }

  @override
  void didChangeDependencies() {
    setLocaleForTimeAgo();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SharedData.fullHeight = MediaQuery.of(context).size.height;
    SharedData.fullWidth = MediaQuery.of(context).size.width;
    SharedData.statusBarHeight = MediaQuery.of(context).padding.top;
    if (!initMiniPlayer) {
      setState(() {
        initMiniPlayer = true;
      });
      Future.delayed(
        Duration(seconds: 1),
      ).then((_) => MiniPlayer.showMiniPlayer(context));
    }

    final tabProvider = Provider.of<TabProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        AppBackgroundHelper.moveAppToBackground();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  pinned: true, // Luôn hiển thị AppBar khi cuộn
                  floating: true, // Không tự động hiện khi cuộn lên
                  expandedHeight: 90, // Chiều cao mở rộng
                  title: Text(tr().applicationName),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  // forceMaterialTransparency: true,
                  elevation: 0,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => SearchPage()),
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
                    controller: tabProvider.tabController,
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
                          color: Theme.of(context).colorScheme.primaryContainer,
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
                    onTap: (value) {
                      tabProvider.animateToPage(value);
                    },
                    tabs: [
                      for (var tabData in tabProvider.tabDataList)
                        _buildTabTitle(tabData.title),
                    ],
                  ),
                ),
              ],
          body: PageView(
            controller: tabProvider.pageController,
            onPageChanged: (value) {
              tabProvider.animateToTab(value);
            },
            children: [
              for (var tabData in tabProvider.tabDataList) tabData.widget,
            ],
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
          children: [
            Text(tr().home_tab(tabTitle), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
