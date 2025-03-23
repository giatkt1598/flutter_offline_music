import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:timeago/timeago.dart' as timeago;

class MusicFolderInfo extends StatelessWidget {
  const MusicFolderInfo({super.key, required this.folder});

  final MusicFolder folder;
  @override
  Widget build(BuildContext context) {
    var creationTime = File(folder.path).statSync().changed;
    return Table(
      columnWidths: {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      children: [
        createRow(label: tr().folderName, value: folder.name),
        createRow(label: tr().detail_filePath, value: folder.path),
        createRow(
          label: tr().detail_lastModificationDate,
          widgetValue: Opacity(
            opacity: 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creationTime.toString().substring(
                    0,
                    creationTime.toString().lastIndexOf('.'),
                  ),
                ),
                Text('(${timeago.format(creationTime)})'),
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
            padding: const EdgeInsets.only(bottom: 16.0),
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
