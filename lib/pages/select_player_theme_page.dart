import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/app_button.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget.dart';
import 'package:flutter_offline_music/pages/player_pages/default_player_page.dart';
import 'package:flutter_offline_music/pages/player_pages/player_ver_one_page.dart';
import 'package:flutter_offline_music/pages/player_pages/player_ver_two_page.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:provider/provider.dart';

class SelectPlayerThemePage extends StatefulWidget {
  const SelectPlayerThemePage({super.key, required this.music});

  final Music music;

  @override
  State<SelectPlayerThemePage> createState() => _SelectPlayerThemePageState();
}

class _SelectPlayerThemePageState extends State<SelectPlayerThemePage> {
  late PageController _pageController;
  late double _currentPage;
  final List<String> themeIds = ['default', 'one', 'two'];

  @override
  void initState() {
    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: themeIds.indexOf(
        SettingProvider.staticAppSetting.playerTheme,
      ),
    );
    _currentPage = _pageController.initialPage.toDouble();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<SettingProvider>(context);
    final currentThemeId = settingProvider.appSetting.playerTheme;
    final Map<String, BasePlayerWidget> playerWidgets = {
      themeIds[0]: DefaultPlayerPage(),
      themeIds[1]: PlayerVerOnePage(),
      themeIds[2]: PlayerVerTwoPage(),
    };

    final isApplied =
        playerWidgets.keys.toList()[_currentPage.toInt()] == currentThemeId;

    handleApply() {
      final themeId = playerWidgets.keys.toList()[_currentPage.round()];
      settingProvider.setting(playerTheme: themeId);
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr().changePlayerThemeTitle)),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              child: PageView.builder(
                controller: _pageController,
                itemCount: playerWidgets.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  double scale = (1.2 - (_currentPage - index).abs()).clamp(
                    0.7,
                    1.2,
                  );
                  String themeId = playerWidgets.keys.toList()[index];
                  return GestureDetector(
                    onTap: handleApply,
                    child: Transform.scale(
                      scale: scale,
                      child: Transform.scale(
                        scale: 0.6,
                        child: FractionallySizedBox(
                          widthFactor: 1.5,
                          heightFactor: 1.1,
                          child: AbsorbPointer(
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
                                child: playerWidgets[themeId],
                              ),
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
                      onPressed:
                          isApplied || _currentPage.toInt() != _currentPage
                              ? null
                              : handleApply,
                      child: Text(
                        isApplied ? tr().themeIsUsed : tr().themeApply,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
