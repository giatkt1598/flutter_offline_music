import 'dart:io';

class FileHelper {
  FileHelper._();

  static Future<Directory> createDirectoryIfNotExists(
    String directoryPath,
  ) async {
    Directory folder = Directory(directoryPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder;
  }
}
