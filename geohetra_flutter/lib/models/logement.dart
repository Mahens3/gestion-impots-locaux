class Logement {
  String? numlog; /* n° du logement */
  final int nbrres; /* nombre du resident */
  final String niveau; /* niveau où se trouve le logement */
  final String statut; /* statut du logement */
  final String typelog; /* type du logement */
  final String
      typeoccup; /* nature de l'occupant( propriétaire; locataire; ...) */

  final int
      vlmeprop; /* valeur locative mensuelle estimée si typeoccup=propriétaire */
  final int vve; /* valeur vénale estimée si typeoccup=propriétaire */
  final int lm; /* loyer mensuel si typeoccup=locataire */
  final int
      vlmeoc; /* valeur locative mensuelle estimée si typeoccup=occupant gratuit */

  final String confort; /*  confort de ce logement */
  final String phone; /* numero telephone de l'occupant */
  final int
      valrec; /* valeur locative mensuelle estimée par les agents recenseurs */
  final int nbrpp; /* nombre de pièce principales */
  final double? stpp; /* surface totale du pièce principales */
  final int nbrps; /* nombre de pièce secondaire */
  final int stps; /* surface totale du pièce secondaire */
  int idcons;

  final String? declarant;

  final String? lien;
  String? datetimes;

  Logement({
    this.numlog,
    required this.nbrres,
    required this.niveau,
    required this.statut,
    required this.typelog,
    this.lien,
    required this.typeoccup,
    required this.vlmeprop,
    required this.vve,
    required this.lm,
    required this.vlmeoc,
    required this.confort,
    required this.phone,
    required this.valrec,
    required this.nbrpp,
    required this.stpp,
    required this.nbrps,
    required this.stps,
    required this.idcons,
    this.declarant,
    this.datetimes,
  });

  Map<String, Object?> toJson() => {
        "numlog": numlog,
        "nbrres": nbrres,
        "niveau": niveau,
        "statut": statut,
        "typelog": typelog,
        "typeoccup": typeoccup,
        "vlmeprop": vlmeprop,
        "declarant": declarant,
        "lien": lien,
        "vve": vve,
        "lm": lm,
        "vlmeoc": vlmeoc,
        "confort": confort,
        "phone": phone,
        "valrec": valrec,
        "nbrpp": nbrpp,
        "stpp": stpp,
        "nbrps": nbrps,
        "stps": stps,
        "idcons": idcons,
        "datetimes": datetimes
      };

  static Logement fromJson(Map<String, Object?> json) => Logement(
      numlog: json["numlog"] as String?,
      nbrres: json["nbrres"] as int,
      niveau: json["niveau"] as String,
      statut: json["statut"] as String,
      typelog: json["typelog"] as String,
      typeoccup: json["typeoccup"] as String,
      vlmeprop: json["vlmeprop"] as int,
      vve: json["vve"] as int,
      lm: json["lm"] as int,
      declarant: json["declarant"] as String?,
      vlmeoc: json["vlmeoc"] as int,
      confort: json["confort"] as String,
      phone: json["phone"] as String,
      valrec: json["valrec"] as int,
      nbrpp: json["nbrpp"] as int,
      stpp: json["stpp"] as double?,
      nbrps: json["nbrps"] as int,
      stps: json["stps"] as int,
      idcons: json["idcons"] as int,
      lien: json["lien"] as String?,
      datetimes: json["datetimes"] as String?);

  static const cmd =
      "CREATE TABLE logement(numlog VARCHAR(30) PRIMARY KEY, nbrres smallint, niveau varchar(15), statut varchar(50), typelog varchar(50), typeoccup varchar(50), vlmeprop int, vve int, lm int, vlmeoc int, confort text, phone varchar(10), valrec int, nbrpp int, stpp double, nbrps int, stps int, idcons int, declarant varchar(100), lien varchar(20), datetimes varchar(20))";
}
