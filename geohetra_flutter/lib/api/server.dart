// ignore_for_file: avoid_print

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

  Future<void> send() async {
  var baseUrl = await getServer();
  print("🌐 Envoi des données vers : $baseUrl");

  // 🔹 Récupération des données locales modifiées depuis la dernière synchro
  List<Map<String, Object?>> proprietaires = await DB.instance.queryBuilder(
      "SELECT * FROM proprietaire WHERE datetimes > '${date["proprietaire"]}'");

  List<Map<String, Object?>> ifpbs = await DB.instance
      .queryBuilder("SELECT * FROM ifpb WHERE datetimes > '${date["ifpb"]}'");

  dynamic idagt =
      await DB.instance.queryBuilder("SELECT idagt FROM user WHERE active=1");
  idagt = idagt.first['idagt'];

  List<Map<String, Object?>> constructions = await DB.instance.queryBuilder(
      "SELECT * FROM construction WHERE datetimes > '${date["construction"]}' AND idagt = $idagt");

  List<Map<String, Object?>> logements = await DB.instance.queryBuilder(
      "SELECT l.*, c.numcons FROM logement l JOIN construction c ON l.idcons = c.id WHERE l.datetimes > '${date["logement"]}'");

  List<Map<String, Object?>> personnes = await DB.instance.queryBuilder(
      "SELECT c.numcons, p.* FROM personne p JOIN construction c ON p.idcons = c.id WHERE p.datetimes > '${date["personne"]}'");

  print("📦 Données à envoyer :");
  print("  ➤ ${constructions.length} constructions");
  print("  ➤ ${logements.length} logements");
  print("  ➤ ${personnes.length} personnes");
  print("  ➤ ${proprietaires.length} propriétaires");
  print("  ➤ ${ifpbs.length} ifpb");

  // 🔹 Récupérer les infos utilisateur locales (téléphone + mot de passe)
  List<Map<String, Object?>> user =
      await DB.instance.queryBuilder("SELECT phone, mdp FROM user WHERE active=1");
  String phone = user.first['phone'].toString();
  String mdp = user.first['mdp'].toString();

  print("📱 Envoi des données pour : $phone / mdp=$mdp");

  // 🔹 Préparer la requête HTTP multipart
  var request =
      http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload'));

  request.fields.addAll({
    "constructions": json.encode(constructions),
    "logements": json.encode(logements),
    "proprietaires": json.encode(proprietaires),
    "ifpbs": json.encode(ifpbs),
    "personnes": json.encode(personnes),
    "phone": phone,
    "mdp": mdp,
  });

  print(ifpbs);
  print("Logements: $logements");

  // 🔹 Ajouter les images si disponibles
  request = await addImage(constructions, request);

  try {
    var response = await request.send();
    var body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("✅ Envoi réussi : $body");
    } else {
      print("❌ Erreur serveur [${response.statusCode}] : $body");
    }
  } catch (e) {
    print("🚨 Erreur lors de l’envoi : $e");
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
      print("Data : ${json.decode(response.body)}");

      if (response.statusCode != 200) {
        return {"server": true, "agent": false};
      }

      try {
        Map<String, dynamic> data = json.decode(response.body);

        if (data["authentificated"] == true) {
          // Créer les données de l'agent pour la table user
          Map<String, Object?> agent = {
            "phone": phone,
            "pseudo": data["pseudo"],
            "mdp": password,
            "numequip": data["numequip"],
            "type": data["type"],
            "active": 1,
            "idagt": data["idagt"],
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
