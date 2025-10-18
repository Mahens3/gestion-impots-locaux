import 'package:geohetra/models/construction.dart';
import 'package:geohetra/models/ifpb.dart';
import 'package:geohetra/models/logement.dart';
import 'package:geohetra/models/personne.dart';
import 'package:geohetra/models/proprietaire.dart';
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";

class DB {
  static DB instance = DB.init();
  static Database? _database;
  DB.init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB("impotdb.db");
    return _database!;
  }

  Future<String> getUser() async {
    final db = await instance.database;
    final actif = await db.query("user", where: "active=?", whereArgs: ["1"]);
    return actif.first['phone'].toString();
  }

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    final db = await openDatabase(path, version: 1, onCreate: _createDB);
    return db;
  }

  Future _createDB(Database db, int version) async {
    await db.execute(Proprietaire.cmd);
    await db.execute(Construction.cmd);
    await db.execute(Logement.cmd);
    await db.execute(Ifpb.cmd);
    await db.execute(Personne.cmd);
    await db.execute(
        "CREATE TABLE fokontany(id  INTEGER PRIMARY KEY AUTOINCREMENT, nomfokontany varchar(20), rang int)");
    await db.execute(
        "CREATE TABLE user(phone varchar(50) PRIMARY KEY, pseudo varchar(20), mdp varchar(20),numequip int, type varchar(10), active int, idagt smallint)");
  }

  Future addFkt() async {
    final db = await instance.database;
    var fokontany = [
      {"nomfokontany": "Androka", "rang": "4"},
      {"nomfokontany": "Ezaka", "rang": "8"},
      {"nomfokontany": "Antsinanamanda", "rang": "9"},
      {"nomfokontany": "Sahamasy", "rang": "5"},
      {"nomfokontany": "Ambohijafy", "rang": "6"},
      {"nomfokontany": "Ambalamahasoa Nord", "rang": "14"},
      {"nomfokontany": "Soamanandray", "rang": "17"},
      {"nomfokontany": "Alatsinainy Fonenantsoa", "rang": "16"},
      {"nomfokontany": "Ambalalova Nord", "rang": "13"},
      {"nomfokontany": "Teloambinifolo", "rang": "15"},
      {"nomfokontany": "Ampanaovantsavony", "rang": "7"},
      {"nomfokontany": "Tsaranoro", "rang": "20"},
      {"nomfokontany": "Ambohitsoa", "rang": "12"},
      {"nomfokontany": "Bemahalanja", "rang": "1"},
      {"nomfokontany": "Antsenanomby", "rang": "3"},
      {"nomfokontany": "Vondrokely", "rang": "2"},
      {"nomfokontany": "Alatsinainy", "rang": "10"},
      {"nomfokontany": "Ankofika", "rang": "11"},
      {"nomfokontany": "Ambalamahasoa Sud", "rang": "18"},
      {"nomfokontany": "Maroparasy", "rang": "19"},
      {"nomfokontany": "Vatofotsy", "rang": "21"}
    ];

    for (var i = 0; i < fokontany.length; i++) {
      await db.insert("fokontany", fokontany[i]);
    }
  }

  Future verifFktOr() async {
    final db = await instance.database;
    try {
      await db.rawQuery("SELECT fktorigin FROM construction");
    } catch (e) {
      await db.execute("ALTER TABLE construction ADD COLUMN fktorigin int");
    }
  }

  Future<int> updateQuery(String sql) async {
    final db = await instance.database;
    final id = await db.rawUpdate(sql);
    return id;
  }

  Future alter() async {
    final db = await instance.database;
    await db.rawUpdate("UPDATE construction SET origin='server'");
  }

  /// Table propriétaire */
  Future<List<Proprietaire>> findProprietaire(String? id) async {
    final db = await instance.database;
    var query = [];
    if (id == null) {
      query = await db.query("proprietaire", orderBy: "numprop DESC");
    } else {
      query =
          await db.query("proprietaire", where: "numprop=?", whereArgs: [id]);
    }

    final json = query.map((json) => Proprietaire.fromJson(json));
    return json.toList();
  }

  Future<int> rawQuery(String suite) async {
    final db = await instance.database;
    var id = db.rawInsert(
        "INSERT INTO construction(lat,lng,idagt,typequart,rang,idfoko,idcoord) VALUES" +
            suite);
    return id;
  }

  Future insertPersonne(Personne personne) async {
    final db = await instance.database;
    await db.insert("personne", personne.toJson());
  }

  Future updatePersonne(Personne personne) async {
    final db = await instance.database;
    var data = {
      "profession": personne.profession,
      "age": personne.age,
      "lieu": personne.lieu,
      "sexe": personne.sexe
    };

    await db.update("personne", data,
        where: 'numpers=?', whereArgs: [personne.numpers]);
  }

  Future reset() async {
    final db = await instance.database;
    await db.rawUpdate(
        "UPDATE construction SET numcons=null, mur=null, ossature=null, toiture=null, adress=null, fondation=null, typehab=null, etatmur=null, access=null, nbrhab=null, nbrniv=null, anconst=null, nbrcom=null, nbrbur=null, nbrprop=null, nbrloc=null, nbrocgrat=null, surface=null, numter=null, numprop=null, numifpb=null, image=null, datetimes=null");
    await db.delete("logement");
    await db.delete("ifpb");
    await db.delete("proprietaire");
  }

  Future<Map<String, String>> getTache() async {
    final db = await instance.database;
    var date = DateTime.now();

    dynamic idagt = await db.rawQuery("SELECT idagt FROM user WHERE active=1");
    idagt = idagt.first['idagt'];

    final total = await db.rawQuery(
        "SELECT numcons FROM construction WHERE idagt=${idagt.toString()}");
    final fini = await db.rawQuery(
        "SELECT numcons FROM construction WHERE numcons is not null AND idagt=" +
            idagt.toString());

    final quota = await db.rawQuery(
        "SELECT * FROM construction WHERE date(datetimes)=date('${date.toString().substring(0, 11)}')");

    final cree = await db
        .rawQuery("SELECT numcons FROM construction WHERE idagt is not null");

    // int pourcent = ((fini.length * 100) / total.length).ceil();
    int pourcent =
        total.length > 0 ? ((fini.length * 100) / total.length).ceil() : 0;

    return {
      "pourcentage": pourcent.toString(),
      "tache": fini.length.toString() + "/" + total.length.toString(),
      "cree": cree.length.toString(),
      "quota": quota.length.toString(),
      "reste": (total.length - fini.length).toString()
    };
  }

  Future<int> insertProprietaire(
      Proprietaire proprietaire, String numcons) async {
    final db = await instance.database;

    print("🟦 [insertProprietaire] Début de l'insertion...");
    print("➡️ Données du propriétaire : ${proprietaire.toJson()}");
    print("➡️ Numéro de construction associé : $numcons");

    try {
      // Insertion du propriétaire
      final id = await db.insert("proprietaire", proprietaire.toJson());
      print("✅ Insertion réussie dans 'proprietaire' avec ID = $id");

      // Mise à jour de la table construction
      final updated = await db.rawUpdate(
        "UPDATE construction SET numprop=? WHERE numcons=?",
        [proprietaire.numprop, numcons],
      );
      print(
          "🟩 Mise à jour 'construction' réussie : $updated ligne(s) affectée(s)");

      return updated + id;
    } catch (e) {
      print("❌ Erreur lors de insertProprietaire : $e");
      return 0;
    }
  }

  Future<Map<String, dynamic>?> updateProprietaire(
      Proprietaire proprietaire) async {
    final db = await instance.database;

    print("🟦 [updateProprietaire] Début de la mise à jour...");
    print("➡️ Propriétaire : ${proprietaire.toJson()}");

    try {
      final count = await db.update(
        "proprietaire",
        proprietaire.toJson(),
        where: 'numprop = ?',
        whereArgs: [proprietaire.numprop],
      );

      if (count == 0) {
        print(
            "⚠️ Aucun propriétaire trouvé avec numprop = ${proprietaire.numprop}");
      } else {
        print("✅ Mise à jour réussie : $count ligne(s) affectée(s)");
      }

      return {"updatedCount": count, "proprietaire": proprietaire.toJson()};
    } catch (e) {
      print("❌ Erreur lors de updateProprietaire : $e");
      return null;
    }
  }

  Future<List<Map<String, Object?>>> queryBuilder(String query) async {
    final db = await instance.database;
    final results = await db.rawQuery(query);
    return results;
  }

  Future<int> queryUpdate(String query) async {
    final db = await instance.database;
    final results = await db.rawUpdate(query);
    return results;
  }

  Future<List<Map<String, Object?>>> getFkt({bool all = false}) async {
    final db = await instance.database;

    dynamic idagt = await db.rawQuery("SELECT idagt FROM user WHERE active=1");
    idagt = idagt.first['idagt'];
    if (all == true) {
      var fkt = await db.rawQuery("SELECT * FROM fokontany");
      return fkt;
    } else {
      var fkt = await db.rawQuery(
          "SELECT f.id, f.nomfokontany, c.rang, c.idfoko FROM construction c, fokontany f WHERE f.id=c.idfoko AND c.idagt=${idagt.toString()} GROUP BY f.nomfokontany ORDER BY c.rang ASC");

      return fkt;
    }
  }

  /// Table construction */
  Future<List<Construction>> findConstruction({int? idfkt, int? limit}) async {
    final db = await instance.database;
    dynamic idagt = await db.rawQuery("SELECT idagt FROM user WHERE active=1");
    idagt = idagt.first['idagt'];

    var whereList = [];
    var where = "";
    if (idfkt != null) {
      whereList.add("idfoko=" + idfkt.toString());
    }

    whereList.add("datetimes is null");
    whereList.add("idagt=" + idagt.toString());

    if (whereList.length > 1) {
      where = whereList.join(" and ");
    } else if (whereList.length == 1) {
      where = whereList.first;
    }

    var result = await db.query("construction",
        orderBy: "rang ASC", where: where, limit: limit);

    final json = result.map((json) => Construction.fromJson(json));
    return json.toList();
  }

  Future<List<Construction>> findAmbiny() async {
    final db = await instance.database;
    dynamic idagt = await db.rawQuery("SELECT idagt FROM user WHERE active=1");
    idagt = idagt.first['idagt'];

    var result = await db.rawQuery(
        "SELECT * FROM construction WHERE typecons='Imposable' AND id not in (SELECT idcons FROM logement GROUP BY idcons)");

    final json = result.map((json) => Construction.fromJson(json));
    return json.toList();
  }

  Future<List<Construction>> findAchieve({int? idfkt}) async {
    final db = await instance.database;
    dynamic idagt = await db.rawQuery("SELECT idagt FROM user WHERE active=1");
    idagt = idagt.first['idagt'];

    var result = await db.query("construction",
        where: "idfoko=? and datetimes is not null and idagt=?",
        whereArgs: [idfkt, idagt]);

    final json = result.map((json) => Construction.fromJson(json));
    return json.toList();
  }

  Future<List<Construction>> findVoisin({int? idfkt}) async {
    final db = await instance.database;
    dynamic idagt = await db.rawQuery("SELECT idagt FROM user WHERE active=1");
    idagt = idagt.first['idagt'];

    var result = await db.query("construction",
        where: "idfoko=? and idagt!=?", whereArgs: [idfkt, idagt]);
    final json = result.map((json) => Construction.fromJson(json));
    return json.toList();
  }

  /// Table construction */
  Future<int> setImageConstruction(String filename, int construction) async {
    final db = await instance.database;
    final id = await db.update("construction", {"image": filename},
        where: "id=?", whereArgs: [construction]);
    return id;
  }

  Future<int> insertConstruction(Construction construction) async {
    final db = await instance.database;
    final id = await db.insert("construction", construction.toJson());
    return id;
  }

  Future updateConstruction(Construction construction) async {
    final db = await instance.database;
    final id = await db.update("construction", construction.toJson(),
        where: 'id=?', whereArgs: [construction.id]);
    return id;
  }

  /// Table logement */
  Future<List<Logement>> findLogement(int? idcons) async {
    final db = await instance.database;
    var query = [];
    if (idcons == null) {
      query = await db.query("logement", orderBy: "numlog DESC");
    } else {
      query =
          await db.query("logement", where: "idcons=?", whereArgs: [idcons]);
    }
    final json = query.map((json) => Logement.fromJson(json));
    return json.toList();
  }

  /// Table personne */
  Future<List<Personne>> findPersonne(int? idcons) async {
    final db = await instance.database;
    var query = [];
    if (idcons == null) {
      query = await db.query("personne", orderBy: "numpers DESC");
    } else {
      query = await db.query("personne",
          where: "idcons=?", whereArgs: [idcons], orderBy: "numpers DESC");
    }
    final json = query.map((json) => Personne.fromJson(json));
    return json.toList();
  }

  Future<int> insertLogement(Logement logement) async {
    final db = await instance.database;
    final id = await db.insert("logement", logement.toJson());
    return id;
  }

  Future insertAgent(Map<String, Object?> agent) async {
    final db = await instance.database;
    await db.insert("user", agent);
  }

  Future updateLogement(Logement logement) async {
    final db = await instance.database;
    final id = await db.update("logement", logement.toJson(),
        where: 'numlog=?', whereArgs: [logement.numlog]);
    return id;
  }

  /// Table terrain */
  Future<List<Ifpb>> findIfpb(String? id) async {
    final db = await instance.database;
    var query = [];
    if (id == null) {
      query = await db.query("ifpb", orderBy: "numif DESC");
    } else {
      query = await db.query("ifpb", where: "numif=?", whereArgs: [id]);
    }
    final json = query.map((json) => Ifpb.fromJson(json));
    return json.toList();
  }

  Future<int> insertIfpb(Ifpb ifpb, String numcons) async {
    final db = await instance.database;

    print("🟦 [insertIfpb] Début de l'insertion...");
    print("➡️ Données Ifpb : ${ifpb.toJson()}");
    print("➡️ Numéro de construction associé : $numcons");

    try {
      // Insertion de l'IFPB
      final id = await db.insert("ifpb", ifpb.toJson());
      print("✅ Insertion réussie dans 'ifpb' avec ID = $id");

      // Mise à jour de la table construction
      final updated = await db.rawUpdate(
        "UPDATE construction SET numifpb=? WHERE numcons=?",
        [ifpb.numif, numcons],
      );
      print(
          "🟩 Mise à jour 'construction' réussie : $updated ligne(s) affectée(s)");

      return updated + id;
    } catch (e) {
      print("❌ Erreur lors de insertIfpb : $e");
      return 0;
    }
  }

  Future updateIfpb(Ifpb ifpb) async {
    final db = await instance.database;
    final id = await db.update("ifpb", ifpb.toJson(),
        where: 'numif=?', whereArgs: [ifpb.numif]);
    return id;
  }

  Future delete(String table, int ident, int args) async {
    final db = await instance.database;
    await db.delete(table, where: '$ident=?', whereArgs: [args]);
  }
}
