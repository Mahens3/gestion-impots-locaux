class Personne {
  static const cmd =
      "CREATE TABLE personne(numpers VARCHAR(30) PRIMARY KEY, age double, sexe varchar(7), profession varchar(50), lieu varchar(80),idcons int, datetimes varchar(20))";

  String? numpers;
  double? age;
  final String sexe;
  final String profession;
  final String lieu;
  int? idcons;
  String? datetimes;

  Personne(
      {this.numpers,
      this.age,
      this.idcons,
      required this.sexe,
      required this.profession,
      required this.lieu,
      this.datetimes});

  Map<String, Object?> toJson() => {
        "numpers": numpers,
        "age": age,
        "sexe": sexe,
        "profession": profession,
        "lieu": lieu,
        "idcons": idcons,
        "datetimes": datetimes,
      };

  static Personne fromJson(Map<String, Object?> json) => Personne(
        numpers: json["numpers"] as String,
        age: json["age"] as double?,
        sexe: json["sexe"] as String,
        profession: json["profession"] as String,
        idcons: json["idcons"] as int?,
        lieu: json["lieu"] as String,
        datetimes: json["datetimes"] as String?,
      );
}
