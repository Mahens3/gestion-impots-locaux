import 'package:flutter/material.dart';
import 'package:geohetra/api/server_web.dart';
import "../data/colors.dart" as color;

class Xendering extends StatefulWidget {
  const Xendering({Key? key}) : super(key: key);
  @override
  State<Xendering> createState() => _XenderingState();
}

class _XenderingState extends State<Xendering> {
  late TextEditingController ctrl = TextEditingController();
  late TextEditingController date = TextEditingController();
  late WebServer webServer = WebServer();
  late bool listened = false;

  final tables = [
    "Construction",
    "Proprietaire",
    "Logement",
    "IFPB",
    "Personne"
  ];
  String table = "";

  late bool alldata = true;
  late bool all = true;

  late bool error = false;

  void handleTables(value) {
    setState(() {
      table = value;
    });
  }

  void handleExport() {
    List<String> tables = table.split(", ");
    if (ctrl.text == "wolverine03") {
      if (tables.isNotEmpty) {}
      setState(() {
        error = false;
      });
    } else {
      setState(() {
        error = true;
      });
    }
  }

  Container export() {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF1E40AF),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    );
    return Container(
        margin: const EdgeInsets.all(20),
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          style: raisedButtonStyle,
          onPressed: () {
            if (listened == true) {
              webServer.stop();
            } else {
              webServer.listen();
            }
            setState(() {
              listened = !listened;
            });
          },
          child: const Text("Exporter"),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color.AppColor.backgroundColor,
        appBar: AppBar(
          title: const Text("Xendering des données"),
          backgroundColor: Colors.blue[900],
        ),
        body: Column(children: [export()]));
  }
}
