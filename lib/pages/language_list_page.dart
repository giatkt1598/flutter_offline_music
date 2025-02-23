import 'package:flutter/material.dart';

class LanguageListPage extends StatefulWidget {
  const LanguageListPage({super.key});

  @override
  State<LanguageListPage> createState() => _LanguageListPageState();
}

class _LanguageListPageState extends State<LanguageListPage> {
  final List<String> languages = ['Tiếng Việt', 'English', '日本語'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ngôn ngữ')),
      body: SingleChildScrollView(
        child: ListView(
          shrinkWrap: true,
          children:
              languages
                  .map(
                    (e) => ListTile(
                      title: Text(e),
                      onTap: () {
                        Navigator.pop(context, e);
                      },
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
