import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/language_flag_icon.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';

class LanguageListPage extends StatefulWidget {
  const LanguageListPage({super.key});

  @override
  State<LanguageListPage> createState() => _LanguageListPageState();
}

class _LanguageListPageState extends State<LanguageListPage> {
  List<String> languageCodes = ['auto', 'vi', 'en'];
  @override
  Widget build(BuildContext context) {
    final settingProvider = context.getSettingProvider();

    return Scaffold(
      appBar: AppBar(title: Text(tr().languageTitle)),
      body: SingleChildScrollView(
        child: ListView(
          shrinkWrap: true,
          children:
              languageCodes.map((langCode) {
                bool isSelected =
                    settingProvider.appSetting.languageCode == langCode;
                return ListTile(
                  tileColor:
                      !isSelected
                          ? null
                          : Theme.of(context).colorScheme.surfaceContainer,
                  leading: LanguageFlagIcon(languageCode: langCode),
                  title: Text(tr().langOptionDisplayName(langCode)),
                  onTap: () {
                    settingProvider.setting(languageCode: langCode);
                    Navigator.pop(context, langCode);
                  },
                  trailing:
                      isSelected
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                );
              }).toList(),
        ),
      ),
    );
  }
}
