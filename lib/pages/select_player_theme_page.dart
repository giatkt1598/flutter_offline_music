import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/app_button.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget.dart';
import 'package:flutter_offline_music/pages/player_pages/default_player_page.dart';
import 'package:flutter_offline_music/pages/player_pages/player_page.dart';
import 'package:flutter_offline_music/pages/player_pages/player_ver_one_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_offline_music/utilities/debug_helper.dart';
import 'package:provider/provider.dart';

class SelectPlayerThemePage extends StatefulWidget {
  const SelectPlayerThemePage({super.key, required this.music});

  final Music music;

  @override
  State<SelectPlayerThemePage> createState() => _SelectPlayerThemePageState();
}

class _SelectPlayerThemePageState extends State<SelectPlayerThemePage> {
  final PageController _pageController = PageController(viewportFraction: 0.6);
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final Map<String, BasePlayerWidget> playerWidgets = {
      'default': DefaultPlayerPage(music: widget.music),
      'one': PlayerVerOnePage(music: widget.music),
    };
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        //TODO: Workaround
        Future.delayed(Duration(milliseconds: 50)).then((_) {
          playerProvider.isShowMiniPlayer = false;
          playerProvider.notifyChanges();
          logDebug('select theme is pop');
        });
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Đổi giao diện Phát nhạc')),
        body: Column(
          children: [
            Expanded(
              child: SizedBox(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: playerWidgets.length, // Số lượng item
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    double scale = (1.2 - (_currentPage - index).abs()).clamp(
                      0.7,
                      1.2,
                    );

                    return Transform.scale(
                      scale: scale,
                      child: Transform.scale(
                        scale: 0.8,
                        child: FractionallySizedBox(
                          widthFactor: 1.2,
                          heightFactor: 0.85,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withValues(
                                              alpha: 0.2,
                                            )
                                            : Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: Offset.zero,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child:
                                    playerWidgets[playerWidgets.keys
                                        .toList()[index]],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 32, left: 32, bottom: 40),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppButton(
                        type: AppButtonType.primary,
                        onPressed: () {},
                        child: Text('Áp dụng'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
