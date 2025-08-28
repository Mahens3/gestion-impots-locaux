class Proprietaire {
  static const cmd =
      "CREATE TABLE proprietaire(numprop VARCHAR(30) PRIMARY KEY, nomprop varchar(50), prenomprop varchar(70), adress varchar(100), typeprop varchar(3),datetimes varchar(20))";

  String? numprop; /* n° propriétaire */
  final String nomprop; /* nom du propriétaire */
  final String prenomprop; /* prenom du propriétaire */
  final String adress;
  final String? typeprop;
  String? datetimes;

  Proprietaire(
      {this.numprop,
      required this.nomprop,
      this.typeprop,
      required this.prenomprop,
      required this.adress,
      this.datetimes});

  Map<String, Object?> toJson() => {
        "numprop": numprop,
        "nomprop": nomprop,
        "prenomprop": prenomprop,
        "typeprop": typeprop,
        "adress": adress,
        "datetimes": datetimes,
      };

  static Proprietaire fromJson(Map<String, Object?> json) => Proprietaire(
        numprop: json["numprop"] as String,
        nomprop: json["nomprop"] as String,
        prenomprop: json["prenomprop"] as String,
        typeprop: json["typeprop"] as String,
        adress: json["adress"] as String,
        datetimes: json["datetimes"] as String?,
      );
}
