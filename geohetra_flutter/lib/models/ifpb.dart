class Ifpb {
  String? numif; /* n° d'enregisrement de l'ifpb */
  final String exon; /* exoneration de l'ifpb */
  final String cause;
  String? datetimes;
  final String dernanne; /* dernière année concernant l'avis reçu */
  final int? montantins; /* montant inscrit concernant cette dernière année */
  final int? montantpay;
  final int? article;
  final int? role;
  Ifpb(
      {this.numif,
      required this.exon,
      required this.dernanne,
      required this.montantins,
      required this.montantpay,
      required this.cause,
      this.datetimes,
      this.article,
      this.role});

  Map<String, Object?> toJson() => {
        "numif": numif,
        "exon": exon,
        "dernanne": montantins,
        "montantpay": montantpay,
        "montantins": montantins,
        "datetimes": datetimes,
        "cause": cause,
        "article": article,
        "role": role,
      };

  static Ifpb fromJson(Map<String, Object?> json) => Ifpb(
      numif: json["numif"] as String?,
      exon: json["exon"] as String,
      dernanne: json["dernanne"] as String,
      cause: json["cause"] as String,
      montantins: json["montantins"] as int?,
      montantpay: json["montantpay"] as int?,
      article: json["article"] as int?,
      datetimes: json["datetimes"] as String?,
      role: json["role"] as int?);

  static const cmd =
      "CREATE TABLE ifpb(numif VARCHAR(30) PRIMARY KEY, exon char(3), dernanne char(4), montantins int, montantpay int, cause text, role int, datetimes varchar(20), article int)";
}
