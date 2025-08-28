import 'dart:io';

import 'package:geohetra/database/database.dart';
import 'package:geohetra/filemanager/file_manager.dart';
import 'package:http/http.dart' as http;
import "dart:convert";

import 'package:path_provider/path_provider.dart';

Future<String> getServer() async {
  var root = await getApplicationSupportDirectory();
  var file = File(root.path + "/settings.json");

  var text = await file.readAsString();
  Map<String, dynamic> data = json.decode(text);
  return data["server"].toString();
}

class HttpServer {
  const HttpServer({required this.phone, required this.date});
  final String phone;
  final Map<String, Object?> date;

  // Verification si le serveur distant est atteignable (et allumé)
  static Future<Map<String, Object?>> checkConnectivity(String phone) async {
    var serverAddr = await getServer();
    try {
      final response = await http.post(
          Uri.parse(serverAddr + "/api/connectivity"),
          body: json.encode({"phone": phone}),
          headers: {"Content-type": "application/json"});

      return json.decode(response.body);
    } catch (e) {
      return {"connect": false};
    }
  }

  Future<http.MultipartFile?> getImage(String field, String path) async {
    try {
      return await http.MultipartFile.fromPath(field, path);
    } catch (e) {
      return null;
    }
  }

  Future<http.MultipartRequest> addImage(
      List<Map<String, Object?>> data, http.MultipartRequest request) async {
    for (var i = 0; i < data.length; i++) {
      var path = await FileManager.instance.directoryPath +
          "/" +
          data[i]["image"].toString();
      var filepath = await getImage(data[i]["image"].toString(), path);
      if (filepath != null) {
        request.files.add(filepath);
      }
      var headers = {'Content-Type': 'multipart/form-data'};
      request.headers.addAll(headers);
    }
    return request;
  }

  // Envoi des données au serveur distant
  Future send() async {
    var baseUrl = await getServer();
    List<Map<String, Object?>> proprietaires = await DB.instance.queryBuilder(
        "SELECT * FROM proprietaire WHERE datetimes>'" +
            date["proprietaire"].toString() +
            "'");
    List<Map<String, Object?>> ifpb = await DB.instance.queryBuilder(
        "SELECT * FROM ifpb WHERE datetimes>'" + date["ifpb"].toString() + "'");

    dynamic idagt =
        await DB.instance.queryBuilder("SELECT idagt FROM user WHERE active=1");
    idagt = idagt.first['idagt'];

    List<Map<String, Object?>> constructions = await DB.instance.queryBuilder(
        "SELECT * FROM construction WHERE datetimes>'" +
            date["construction"].toString() +
            "' AND idagt=" +
            idagt.toString());

    List<Map<String, Object?>> logements = await DB.instance.queryBuilder(
        "SELECT l.*, c.numcons FROM logement l, construction c WHERE l.idcons=c.id AND l.datetimes>'" +
            date["logement"].toString() +
            "'");

    List<Map<String, Object?>> personnes = await DB.instance.queryBuilder(
        "SELECT c.numcons, p.* FROM personne p, construction c WHERE c.id=p.idcons AND p.datetimes>'" +
            date["personne"].toString() +
            "'");

    var request =
        http.MultipartRequest('POST', Uri.parse(baseUrl + "/api/remote"));

    request.fields.addAll({
      "constructions": json.encode(constructions),
      "logements": json.encode(logements),
      "proprietaires": json.encode(proprietaires),
      "ifpbs": json.encode(ifpb),
      "personne": json.encode(personnes),
      "phone": phone
    });

    request = await addImage(constructions, request);

    try {
      await request.send().then((value) async {
        //print(await value.stream.bytesToString());
      });
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, Object?>>> getPropVide(List<dynamic> propvide) async {
    List<Map<String, Object?>> list = [];
    for (int i = 0; i < propvide.length; i++) {
      Map<String, Object?> elt = propvide[i] as Map<String, Object?>;
      var resp = await DB.instance.queryBuilder(
          "SELECT numprop FROM construction WHERE numcons='" +
              elt["numcons"].toString() +
              "'");
      if (resp.isNotEmpty) {
        Map<String, Object?> map = {};
        map["numcons"] = elt["numcons"].toString();
        map["numprop"] = elt["numprop"].toString();
        list.add(map);
      }
    }
    return list;
  }

  static Future<Map<String, bool>> getAgent(
      {required String phone, required String password}) async {
    var serverAddr = await getServer();

    try {
      var response = await http.post(Uri.parse(serverAddr + "/api/agent/auth"),
          body: {"phone": phone, "mdp": password});

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode != 200) {
        return {"server": true, "agent": false};
      }

      try {
        Map<String, dynamic> data = json.decode(response.body);

        if (data["authentificated"] == true) {
          // Créer les données de l'agent pour la table user
          Map<String, Object?> agent = {
            "phone": phone,
            "mdp": password,
            "active": 1,
          };

          print("Tentative d'insertion agent: $agent");
          await DB.instance.insertAgent(agent);
          print("Agent inséré avec succès");

          return {"server": true, "agent": true};
        } else {
          print("Authentification échouée côté serveur");
          return {"server": true, "agent": false};
        }
      } catch (e) {
        print("Erreur parsing JSON ou insertion DB: $e");
        return {"server": true, "agent": false};
      }
    } catch (e) {
      print("Erreur réseau: $e");
      return {"server": false, "agent": false};
    }
  }

  // static Future<Map<String, bool>> getAgent(
  //     {required String phone, required String password}) async {
  //   var serverAddr = await getServer();
  //   try {
  //     var response = await http.post(Uri.parse(serverAddr + "/api/agent/auth"),
  //         body: {"phone": phone, "mdp": password});
  //     print(response.body);

  //     try {
  //       Map<String, dynamic> data = json.decode(response.body);
  //       Map<String, Object?> agent = data.cast();
  //       await DB.instance.insertAgent(agent);
  //       return {"server": true, "agent": true};
  //     } catch (e) {
  //       return {"server": true, "agent": false};
  //     }
  //   } catch (e) {
  //     return {"server": false, "agent": false};
  //   }
  // }

  Future<List<Map<String, Object?>>> getIfpbVide(List<dynamic> ifpbvide) async {
    List<Map<String, Object?>> list = [];
    for (int i = 0; i < ifpbvide.length; i++) {
      Map<String, Object?> elt = ifpbvide[i] as Map<String, Object?>;
      var resp = await DB.instance.queryBuilder(
          "SELECT numifpb FROM construction WHERE numcons='" +
              elt["numcons"].toString() +
              "'");
      if (resp.isNotEmpty) {
        Map<String, Object?> map = {};
        map["numcons"] = elt["numcons"].toString();
        map["numifpb"] = elt["numifpb"].toString();
        list.add(map);
      }
    }
    return list;
  }
}
