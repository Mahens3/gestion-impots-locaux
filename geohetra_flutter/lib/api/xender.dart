import 'dart:io';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Xender {
  void listen() async {
    //var server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);
    sendBroadcast();
    receiveBroadcast();
    /**
    server.forEach((request) async {
      request.response.write("Hello world");
    });
     */
  }

  void sendBroadcast() async {
    FBroadcast.instance().broadcast(
      "equipe",
      value: json.encode({"dera": "song", "ip": ""}),
    );
  }

  void receiveBroadcast() {
    FBroadcast.instance().register("equipe", (value, callback) {
      print(value);
      var data = json.decode(value);
    });
  }

  String broadcast() {
    var adress = InternetAddress.anyIPv4;
    var liste = adress.address.split(".");
    var addr = "";
    for (var i = 0; i < liste.length - 1; i++) {
      addr += liste[i] + ".";
    }
    return addr + "255";
  }
}
