import 'dart:io';

import 'package:flutter_offline_music/utilities/file_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileHelper', () {
    test('createDirectoryIfNotExists creates nested directory', () async {
      final root = await Directory.systemTemp.createTemp('offline_music_test_');
      final nestedPath = '${root.path}${Platform.pathSeparator}a${Platform.pathSeparator}b';

      final created = await FileHelper.createDirectoryIfNotExists(nestedPath);

      expect(await created.exists(), isTrue);
      expect(created.path, nestedPath);

      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });
  });
}
