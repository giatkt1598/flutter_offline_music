import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:timeago/timeago.dart' as timeago;

class MusicInfo extends StatelessWidget {
  const MusicInfo({super.key, required this.music});

  final Music music;
  @override
  Widget build(BuildContext context) {
    double size = File(music.path).lengthSync() / 1024 / 1024;
    return Table(
      columnWidths: {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      children: [
        createRow(label: tr().detail_title, value: music.title),
        createRow(label: tr().detail_album, value: ''),
        createRow(label: tr().detail_artist, value: music.artist),
        createRow(label: tr().detail_genre, value: music.genre),
        createRow(
          label: tr().detail_length,
          value: fDurationHHMMSS(music.duration, short: true),
        ),
        createRow(
          label: tr().detail_size,
          value: '${double.parse(size.toStringAsFixed(2))} MB',
        ),
        createRow(label: tr().detail_filePath, value: music.path),
        createRow(
          label: tr().detail_creationDate,
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
                Text('(${timeago.format(music.creationTime)})'),
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
                    value?.isNotEmpty == true ? value! : tr().detail_empty,
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
