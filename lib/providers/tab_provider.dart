import 'package:flutter/material.dart';
import 'package:flutter_offline_music/pages/dashboard_page.dart';
import 'package:flutter_offline_music/pages/full_music_list_page.dart';
import 'package:flutter_offline_music/pages/library_list_page.dart';
import 'package:flutter_offline_music/pages/load_music_page.dart';
import 'package:provider/provider.dart';

class TabProvider extends ChangeNotifier {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  TabController? _tabController;
  TabController get tabController => _tabController!;
  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  final List<TabData> tabDataList = [
    TabData(title: 'Đề xuất', widget: DashboardPage()),
    TabData(
      title: 'Bài hát',
      widget: FullMusicListPage(key: PageStorageKey(1)),
    ),
    TabData(title: 'Thư viện', widget: LibraryListPage()),
    TabData(title: 'Thư mục', widget: LoadMusicPage()),
  ];

  TabProvider();

  initTabController({required TickerProvider vsync}) {
    _tabController ??= TabController(length: tabDataList.length, vsync: vsync);
  }

  setTabIndex(int value) {
    tabDataList[_tabController!.previousIndex].scrollOffset =
        _scrollController.offset;
    _tabIndex = value;
    _tabController?.animateTo(value);
    // _scrollController.jumpTo(0);
    notifyListeners();
  }

  int indexOf<T>() {
    int index = tabDataList.indexWhere(
      (x) => x.widget.runtimeType.toString() == T.toString(),
    );
    return index;
  }
}

class TabData {
  final String title;
  final Widget widget;
  double scrollOffset = 0;

  TabData({required this.title, required this.widget});
}

mixin TabProviderListenerMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    tabProvider.addListener(_onListen);
    super.initState();
  }

  @override
  void dispose() {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    tabProvider.removeListener(_onListen);
    super.dispose();
  }

  void _onListen() {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    if (tabProvider.tabIndex == tabProvider.indexOf<T>()) {
      onTabActive();
    }
  }

  @protected
  void onTabActive();
}
