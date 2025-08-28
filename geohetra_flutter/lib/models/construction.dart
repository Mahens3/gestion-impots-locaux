class Construction {
  int? id; /* N° construction */
  String? numcons; /* N° construction */
  final String? mur; /* mur de la construction */
  final String? ossature; /* ossature de la construction */
  final String? toiture; /* toiture de la construction */
  final String? fondation; /* fondation de la construction */
  final String? typehab; /* type de l'habitation */
  final String? etatmur; /* etat du mur de la construction */
  final String? access; /* accessibilité à la construction */
  final int? nbrhab; /* nombre d'habitation sur la construction */
  final int? nbrniv; /* nombre de niveau ou d'etage */
  final String? anconst; /* année de construction */
  final int? nbrcom; /* nombre de logement pour le commerce */
  final int? nbrbur; /* nombre de logement pour le bureau  */
  final int? nbrprop; /* nombre de propriétaire de la construction */
  final int? nbrloc; /* nombre de locataire sur construction */
  final int? nbrocgrat; /* nombre d'occupant gratuit de la construction */
  final double? surface; /* surface de la construction par rapport au sol */
  String? image;
  final String? adress;
  final String? typecons;
  final String? wc;
  final int? fktorigin;
  final String? boriboritany;
  double lat; /* coordonnées(latitude) */
  double lng; /* coordonnées(longitude) */
  String? numprop;
  int? idfoko;
  int? idagt;
  String? numifpb;
  String? datetimes;

  Construction(
      {this.id,
      this.numcons,
      this.mur,
      this.ossature,
      this.toiture,
      this.fondation,
      this.boriboritany,
      this.adress,
      this.typehab,
      this.idagt,
      this.etatmur,
      this.access,
      this.nbrhab,
      this.nbrniv,
      this.anconst,
      this.nbrcom,
      this.nbrbur,
      this.nbrprop,
      this.idfoko,
      this.nbrloc,
      this.datetimes,
      this.nbrocgrat,
      this.surface,
      this.wc,
      this.typecons,
      this.image,
      this.fktorigin,
      required this.lat,
      required this.lng,
      this.numprop,
      this.numifpb});

  Map<String, Object?> toJson() => {
        "id": id,
        "numcons": numcons,
        "mur": mur,
        "ossature": ossature,
        "toiture": toiture,
        "fondation": fondation,
        "typehab": typehab,
        "etatmur": etatmur,
        "access": access,
        "boriboritany": boriboritany,
        "nbrhab": nbrhab,
        "nbrniv": nbrniv,
        "anconst": anconst,
        "nbrcom": nbrcom,
        "nbrbur": nbrbur,
        "nbrprop": nbrprop,
        "nbrloc": nbrloc,
        "nbrocgrat": nbrocgrat,
        "surface": surface,
        "adress": adress,
        "typecons": typecons,
        "wc": wc,
        "image": image,
        "idfoko": idfoko,
        "idagt": idagt,
        "lat": lat,
        "lng": lng,
        "numprop": numprop,
        "numifpb": numifpb,
        "datetimes": datetimes,
        "fktorigin": fktorigin,
      };

  static Construction fromDynamic(Map<String, dynamic> json) {
    List<String> coords = json["coord"].toString().split(", ");
    return Construction(
        numcons: json["numcons"] as String?,
        mur: json["mur"] as String?,
        ossature: json["ossature"] as String?,
        toiture: json["toiture"] as String?,
        fondation: json["fondation"] as String?,
        typehab: json["typehab"] as String?,
        etatmur: json["etatmur"] as String?,
        access: json["access"] as String?,
        wc: json["wc"] as String?,
        typecons: json["typecons"] as String?,
        boriboritany: json["boriboritany"] as String?,
        anconst: json["anconst"] as String?,
        lat: double.parse(coords[0]),
        lng: double.parse(coords[1]),
        adress: json["adress"] as String?,
        numifpb: json["numifpb"] as String?,
        numprop: json["numprop"] as String?,
        datetimes: json["datetimes"] as String?,
        idagt: json["idagt"],
        fktorigin: json["fktorigin"],
        nbrhab: json["nbrhab"],
        idfoko: json["idfoko"],
        nbrniv: json["nbrniv"],
        nbrcom: json["nbrcom"],
        nbrbur: json["nbrbur"],
        nbrprop: json["nbrprop"],
        nbrloc: json["nbrloc"],
        nbrocgrat: json["nbrocgrat"]);
  }

  static Construction fromJson(Map<String, Object?> json) => Construction(
      id: json["id"] as int?,
      numcons: json["numcons"] as String?,
      mur: json["mur"] as String?,
      ossature: json["ossature"] as String?,
      toiture: json["toiture"] as String?,
      fondation: json["fondation"] as String?,
      typehab: json["typehab"] as String?,
      etatmur: json["etatmur"] as String?,
      access: json["access"] as String?,
      wc: json["wc"] as String?,
      typecons: json["typecons"] as String?,
      boriboritany: json["boriboritany"] as String?,
      anconst: json["anconst"] as String?,
      nbrhab: json["nbrhab"] as int?,
      idfoko: json["idfoko"] as int?,
      nbrniv: json["nbrniv"] as int?,
      idagt: json["idagt"] as int?,
      nbrcom: json["nbrcom"] as int?,
      nbrbur: json["nbrbur"] as int?,
      nbrprop: json["nbrprop"] as int?,
      nbrloc: json["nbrloc"] as int?,
      nbrocgrat: json["nbrocgrat"] as int?,
      datetimes: json["datetimes"] as String?,
      surface: json["surface"] as double?,
      lat: json["lat"] as double,
      lng: json["lng"] as double,
      image: json["image"] as String?,
      adress: json["adress"] as String?,
      numifpb: json["numifpb"] as String?,
      numprop: json["numprop"] as String?,
      fktorigin: json["fktorigin"] as int?);

  static const cmd =
      "CREATE TABLE construction(id INTEGER PRIMARY KEY AUTOINCREMENT, numcons VARCHAR(30), mur varchar(30), ossature varchar(30), toiture varchar(30), adress VARCHAR(40), fondation varchar(30), typehab varchar(30), etatmur varchar(30), access varchar(30), nbrhab smallint, nbrniv smallint, anconst varchar(4), nbrcom smallint, boriboritany varchar(70), nbrbur smallint, nbrprop smallint, nbrloc smallint, nbrocgrat smallint, surface double, lat double, lng double, numter integer, numprop VARCHAR(30), numifpb VARCHAR(30), image varchar(50), typequart varchar(50), rang smallint, idfoko int, idagt int, idcoord int, typecons varchar(50), wc varchar(3), fktorigin int, datetimes varchar(20))";
}
