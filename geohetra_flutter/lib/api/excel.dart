import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:geohetra/database/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

List<String> getKeys(Map<String, Object?> data) {
  List<String> keys = [];
  data.map((key, value) {
    keys.add(key);
    return MapEntry(key, value);
  });
  return keys;
}

Future<File?> exportImage(String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  var support = await FileManager.getStorageList();

  try {
    final file = File(directory.path + "/" + filename);
    final copied =
        await file.copy(support.first.path + "/Geohetra/images/" + filename);
    return copied;
  } catch (e) {
    return null;
  }
}

void exportToExcel(
    {required List<String> table,
    required bool alldata,
    required bool image,
    required String date}) async {
  const name = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "AA",
    "AB",
    "AC",
    "AD",
    "AE",
    "AF",
    "AG",
    "AH",
    "AI",
    "AJ",
    "AK",
    "AL",
  ];
  final Workbook workbook = Workbook();
  for (var sheetIndex = 0; sheetIndex < table.length - 1; sheetIndex++) {
    Worksheet sheet;
    try {
      sheet = workbook.worksheets[sheetIndex];
    } catch (e) {
      sheet = workbook.worksheets.add();
    }
    sheet.name = table[sheetIndex];

    var query = "";
    if (alldata == false) {
      query += " WHERE datetimes>='" + date + " 00:00'";
      if (table[sheetIndex] == "Construction") {
        query += " AND numcons!='' AND numcons is not null ";
      }
    } else {
      if (table[sheetIndex] == "Construction") {
        query += " WHERE numcons!='' AND numcons is not null ";
      }
    }
    if (table[sheetIndex] == "Logement") {
      query =
          "SELECT l.*, c.numcons FROM logement l, construction c WHERE c.id=l.idcons";
    } else if (table[sheetIndex] == "Personne") {
      query =
          "SELECT p.*, c.numcons FROM personne p, construction c WHERE c.id=p.idcons";
    } else {
      query = "SELECT * FROM " +
          table[sheetIndex].toLowerCase() +
          query +
          " ORDER BY datetimes ASC";
    }

    var data = await DB.instance.queryBuilder(query);

    try {
      var keys = getKeys(data.first);
      for (var i = 0; i < keys.length; i++) {
        sheet.getRangeByName(name[i] + "1").setText(keys[i]);
      }

      for (var i = 0; i < data.length; i++) {
        if (image == true) {
          await exportImage(data[i]["image"].toString());
        }
        var index = 0;
        data[i].map((key, value) {
          sheet
              .getRangeByName(name[index] + (i + 2).toString())
              .setText(value.toString());
          index += 1;
          return MapEntry(key, value);
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  final storage = await FileManager.getStorageList();
  final path = storage.first.path + "/Geohetra/data/donnees.xlsx";
  final file = await File(path).create(recursive: true);
  file.writeAsBytes(bytes, flush: true);
}
