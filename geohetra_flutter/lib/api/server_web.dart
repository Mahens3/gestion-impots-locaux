import 'dart:io';
import 'package:file_manager/file_manager.dart';
import 'package:geohetra/database/database.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class WebServer {
  late HttpServer server;
  void listen() async {
    server = await HttpServer.bind(InternetAddress.anyIPv4, 4042);

    var proprietaires =
        await DB.instance.queryBuilder("SELECT * FROM proprietaire");

    var ifpbs = await DB.instance.queryBuilder("SELECT * FROM ifpb");

    var constructions = await DB.instance
        .queryBuilder("SELECT * FROM construction WHERE etatmur is not null");

    var logements = await DB.instance.queryBuilder("SELECT * FROM logement");

    var personnes = await DB.instance.queryBuilder("SELECT * FROM personne");

    var body = {"constructions": prepCons(constructions)};

    print("server is listening");
    await for (HttpRequest request in server) {
      request.response.headers.add("Content-type", 'application/json');
      request.response.write(json.encode(body));
      request.response.close();
    }
  }

  void stop() {
    server.close();
  }

  Future<String?> toBase64(String? filename) async {
    final directory = await getApplicationDocumentsDirectory();
    try {
      final file = File(directory.path + "/$filename");
      List<int> bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, Object?>> prepCons(List<Map<String, Object?>> data) {
    List<Map<String, Object?>> newData = [];
    for (var i = 0; i < data.length; i++) {
      Map<String, Object?> elt = data[i];
      elt["base64"] = toBase64(elt["image"] as String?);
    }
    return newData;
  }
}
