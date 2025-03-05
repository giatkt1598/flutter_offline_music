import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MusicInfo extends StatelessWidget {
  const MusicInfo({super.key, required this.music});

  final Music music;
  @override
  Widget build(BuildContext context) {
    double size = File(music.path).lengthSync() / 1024 / 1024;
    final setting = Provider.of<SettingProvider>(context).appSetting;
    return Table(
      columnWidths: {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      children: [
        createRow(label: 'Tiêu đề', value: music.title),
        createRow(label: 'Album', value: ''),
        createRow(label: 'Nghệ sĩ', value: music.artist),
        createRow(label: 'Thể loại', value: music.genre),
        createRow(
          label: 'Thời lượng',
          value: fDurationHHMMSS(music.duration, short: true),
        ),
        createRow(
          label: 'Kích thước',
          value: '${double.parse(size.toStringAsFixed(2))} MB',
        ),
        createRow(label: 'Vị trí', value: music.path),
        createRow(
          label: 'Ngày tạo',
          widgetValue: Opacity(
            opacity: 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  music.creationTime.toString().substring(
                    0,
                    music.creationTime.toString().lastIndexOf('.'),
                  ),
                ),
                Text(
                  '(${timeago.format(music.creationTime, locale: setting.languageCode)})',
                ),
              ],
            ),
          ),
          value: null,
        ),
      ],
    );
  }

  TableRow createRow({
    required String label,
    required String? value,
    Widget? widgetValue,
  }) {
    return TableRow(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child:
                widgetValue ??
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    value?.isNotEmpty == true ? value! : '<trống>',
                    style: TextStyle(
                      fontStyle:
                          value?.isNotEmpty != true ? FontStyle.italic : null,
                    ),
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
