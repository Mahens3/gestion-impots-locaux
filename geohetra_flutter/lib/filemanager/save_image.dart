import 'dart:io';

import 'package:file_manager/file_manager.dart';

void saveImage(String filename, List<int> bytes) async {
  try {
    var sdcard = await FileManager.getStorageList();

    await File(sdcard.last.path + "/Geohetra/images/" + filename)
        .writeAsBytes(bytes, mode: FileMode.writeOnly);
  } catch (e) {}
}
