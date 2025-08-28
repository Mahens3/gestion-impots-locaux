import 'package:geohetra/database/database.dart';

String now() {
  var d = DateTime.now();
  try {
    return d.toString().substring(0, 24);
  } catch (e) {
    return d.toString().substring(0, 20);
  }
}

Future<String> identity() async {
  var phone = await DB.instance.getUser();
  var ident = now();
  ident = ident.replaceAll('-', "");
  ident = ident.replaceAll(':', "");
  ident = ident.replaceAll(' ', "");
  ident = ident.replaceAll('.', "");
  return ident + phone;
}

String format(String date) {
  List<String> split = date.split(" ");
  return monthString(split[0]) + " " + split[1];
}

String monthString(String data) {
  List<String> split = data.split("-");
  List<String> months = [
    "",
    "janv",
    "fev",
    "mars",
    'avr',
    'mai',
    'juin',
    'juil',
    'août',
    'sept',
    'oct',
    'nov',
    'dec'
  ];
  split[1] = months[int.parse(split[1])];
  return split[2] + "." + split[1] + "." + split[0];
}
