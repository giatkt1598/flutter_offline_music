import 'package:flutter/material.dart';
import 'package:flutter_offline_music/pages/dashboard_page.dart';
import 'package:flutter_offline_music/pages/full_music_list_page.dart';
import 'package:flutter_offline_music/pages/library_list_page.dart';
import 'package:flutter_offline_music/pages/load_music_page.dart';
import 'package:provider/provider.dart';

class TabData {
  final String title;
  final Widget widget;
  double scrollOffset = 0;

  TabData({required this.title, required this.widget});
}

class TabProvider extends ChangeNotifier {
  int _tabIndex = 0;
  TabController? _tabController;
  PageController? _pageController;
  final List<TabData> tabDataList = [
    TabData(title: 'recommended', widget: DashboardPage()),
    TabData(title: 'songs', widget: FullMusicListPage()),
    TabData(title: 'libraries', widget: LibraryListPage()),
    TabData(title: 'folders', widget: LoadMusicPage()),
  ];
  TabProvider();
  PageController get pageController => _pageController!;

  TabController get tabController => _tabController!;

  int get tabIndex => _tabIndex;

  void animateToPage(int value) {
    bool isSide = value + 1 == _tabIndex || value - 1 == _tabIndex;
    if (isSide) {
      _pageController?.animateToPage(
        value,
        duration: isSide ? Duration(milliseconds: 300) : Duration.zero,
        curve: Curves.ease,
      );
    } else {
      _pageController?.jumpToPage(value);
    }
    _setTabIndex(value);
  }

  void animateToTab(int value) {
    _tabController?.animateTo(value);
    _setTabIndex(value);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  int indexOf<T>() {
    int index = tabDataList.indexWhere(
      (x) => x.widget.runtimeType.toString() == T.toString(),
    );
    return index;
  }

  void initTabController({required TickerProvider vsync}) {
    _tabController ??= TabController(length: tabDataList.length, vsync: vsync);
    _pageController ??= PageController();
  }

  void _setTabIndex(int value) {
    bool isNotify = value != _tabIndex;
    _tabIndex = value;
    if (isNotify) notifyListeners();
  }
}

mixin TabProviderListenerMixin<T extends StatefulWidget> on State<T> {
  late TabProvider _tabProvider;
  @override
  void dispose() {
    _tabProvider.removeListener(_onListen);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabProvider = Provider.of<TabProvider>(context, listen: false);
    _tabProvider.addListener(_onListen);
  }

  @protected
  void onTabActive();

  @protected
  void onTabDeactivate() {}

  void _onListen() {
    int currentTabIndex = _tabProvider.indexOf<T>();
    if (_tabProvider.tabIndex == currentTabIndex) {
      onTabActive();
    } else if (_tabProvider._tabController?.previousIndex == currentTabIndex) {
      onTabDeactivate();
    }
  }
}
