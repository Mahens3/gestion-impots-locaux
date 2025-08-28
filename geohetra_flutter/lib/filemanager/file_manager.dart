import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class FileManager {
  static FileManager instance = FileManager.init();
  FileManager.init();

  Future<String> get directoryPath async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> writeImage(String filename, List<int> bytes) async {
    final directory = await instance.directoryPath;
    final file = await File(directory + "/" + filename)
        .writeAsBytes(bytes, mode: FileMode.writeOnly);

    return file;
  }

  Future<Uint8List?> readImage(String filename) async {
    final directory = await instance.directoryPath;
    try {
      final file = await File(directory + "/" + filename).readAsBytes();
      return file;
    } catch (e) {
      return null;
    }
  }

  Future deleteImage(String filename) async {
    final directory = await instance.directoryPath;
    try {
      await File(directory + filename).delete();
      // ignore: empty_catches
    } catch (e) {}
  }
}
