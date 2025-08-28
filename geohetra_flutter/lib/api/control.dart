// ignore_for_file: empty_catches

import 'package:geohetra/database/database.dart';

Future controlData() async {
  var constructionsProp = await DB.instance.queryBuilder(
      "SELECT * FROM construction WHERE numprop is null AND numcons is not null AND typecons='Imposable' ORDER BY datetimes ASC");
  if (constructionsProp.isNotEmpty) {
    var proprietaire = await DB.instance.queryBuilder(
        "SELECT * FROM proprietaire WHERE numprop not in (SELECT numprop FROM construction WHERE numprop is not null) ORDER BY datetimes ASC");

    var idprop = 0;

    var response = await Future.doWhile(() async {
      var id = 0;
      for (var i = 0; i < constructionsProp.length - 1; i++) {
        try {
          Map<String, Object> operation = getPropriete(idprop, proprietaire,
              constructionsProp[i], constructionsProp[i + 1]);
          if (operation["find"] == true) {
            idprop = operation["index"] as int;
            id = await DB.instance.updateQuery(
                "UPDATE construction SET numprop='${proprietaire[idprop]["numprop"]}' WHERE id=${constructionsProp[i]["id"]}");
          }

          // ignore: empty_catches
        } catch (e) {}
      }
      return false;
    });
  }

  var constructionsIfpb = await DB.instance.queryBuilder(
      "SELECT * FROM construction WHERE numifpb is null AND numcons is not null AND typecons='Imposable' ORDER BY datetimes ASC");
  if (constructionsIfpb.isNotEmpty) {
    var ifpb = await DB.instance.queryBuilder(
        "SELECT * FROM ifpb WHERE numif not in (SELECT numifpb as numif FROM construction WHERE numifpb is not null) ORDER BY datetimes");
    var idifpb = 0;

    var response = await Future.doWhile(() async {
      for (var i = 0; i < constructionsIfpb.length - 1; i++) {
        try {
          Map<String, Object> operation = getPropriete(
              idifpb, ifpb, constructionsIfpb[i], constructionsIfpb[i + 1]);
          if (operation["find"] == true) {
            idifpb = operation["index"] as int;
            var id = await DB.instance.updateQuery(
                "UPDATE construction SET numifpb='${ifpb[idifpb]["numif"]}' WHERE id=${constructionsIfpb[i]["id"]}");
          }
        } catch (e) {}
      }
      return false;
    });
  }
  return true;
}

Map<String, Object> getPropriete(int index, List<Map<String, Object?>> datas,
    Map<String, Object?> constr1, Map<String, Object?> constr2) {
  var id = index;
  DateTime dateConstr1 = DateTime.parse(constr1["datetimes"].toString());
  DateTime dateConstr2 = DateTime.parse(constr2["datetimes"].toString());
  Map<String, Object> response = {"find": false, "index": index};
  for (var i = id; i < datas.length; i++) {
    DateTime dateProp = DateTime.parse(datas[i]["datetimes"].toString());
    if (dateProp.isAfter(dateConstr1)) {
      if (dateProp.isBefore(dateConstr2)) {
        response = {"find": true, "index": i};
        break;
      } else {
        response = {"find": false, "index": i};
        break;
      }
    }
  }

  return response;
}

String format(String date) {
  return date.substring(0, 4) +
      "-" +
      date.substring(4, 6) +
      "-" +
      date.substring(6, 8) +
      " " +
      date.substring(8, 10) +
      ":" +
      date.substring(10, 12) +
      ":" +
      date.substring(12) +
      ".0000";
}

Future formatDate() async {
  var constructions = await DB.instance.queryBuilder(
      "SELECT * FROM construction WHERE datetimes NOT LIKE '% %' ");
  var id = 0;
  for (var i = 0; i < constructions.length; i++) {
    id = await DB.instance.updateQuery(
        "UPDATE construction SET datetimes='${format(constructions[i]["datetimes"].toString())}' WHERE id=${constructions[i]["id"]}");
  }

  var proprietaire = await DB.instance.queryBuilder(
      "SELECT * FROM proprietaire WHERE datetimes NOT LIKE '% %' ");
  for (var i = 0; i < proprietaire.length; i++) {
    id = await DB.instance.updateQuery(
        "UPDATE proprietaire SET datetimes='${format(proprietaire[i]["datetimes"].toString())}' WHERE numprop='${proprietaire[i]["numprop"]}'");
  }

  var ifpb = await DB.instance
      .queryBuilder("SELECT * FROM ifpb WHERE datetimes NOT LIKE '% %' ");
  for (var i = 0; i < ifpb.length; i++) {
    id = await DB.instance.updateQuery(
        "UPDATE ifpb SET datetimes='${format(ifpb[i]["datetimes"].toString())}' WHERE numif='${ifpb[i]["numif"]}'");
  }

  var logement = await DB.instance
      .queryBuilder("SELECT * FROM logement WHERE datetimes NOT LIKE '% %' ");
  for (var i = 0; i < logement.length; i++) {
    id = await DB.instance.updateQuery(
        "UPDATE logement SET datetimes='${format(logement[i]["datetimes"].toString())}' WHERE numlog='${logement[i]["numlog"]}'");
  }

  var personne = await DB.instance
      .queryBuilder("SELECT * FROM personne WHERE datetimes NOT LIKE '% %' ");
  for (var i = 0; i < personne.length; i++) {
    id = await DB.instance.updateQuery(
        "UPDATE personne SET datetimes='${format(personne[i]["datetimes"].toString())}' WHERE numpers='${personne[i]["numpers"]}'");
  }
  return id;
}
