import 'package:flutter/material.dart';

class SimpleTab extends StatefulWidget {
  const SimpleTab({
    super.key,
    required this.tabViews,
    this.onTabChanged,
    this.initialIndex = 0,
    this.showTabBar = true,
  });

  final int initialIndex;
  final List<Widget> tabViews;
  final ValueChanged<int>? onTabChanged;
  final bool showTabBar;

  @override
  State<SimpleTab> createState() => SimpleTabState();
}

class SimpleTabState extends State<SimpleTab> with TickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;
  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.animation?.addListener(() {
      final newIndex = _tabController.animation!.value.round();
      if (newIndex != _tabIndex) {
        setState(() {
          _tabIndex = newIndex;
        });
        if (widget.onTabChanged != null) widget.onTabChanged!(_tabIndex);
      }
    });
    super.initState();
  }

  activeTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showTabBar)
          TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.center,
            labelPadding: EdgeInsets.symmetric(horizontal: 1),
            indicatorWeight: 0,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withValues(alpha: 0.6),
            ),
            unselectedLabelColor: Colors.white.withValues(alpha: .3),
            onTap: (value) {
              _tabController.animateTo(value);
            },
            tabs: List.generate(
              widget.tabViews.length,
              (_) => Container(
                width: 12,
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabViews,
          ),
        ),
      ],
    );
  }
}
