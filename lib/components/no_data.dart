import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';

class NoData extends StatelessWidget {
  const NoData({super.key, this.title});

  final String? title;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/no_data.png',
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          Text(title ?? tr().noData),
        ],
      ),
    );
  }
}
