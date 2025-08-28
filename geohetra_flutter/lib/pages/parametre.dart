import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geohetra/components/components.dart';
import 'package:geohetra/database/database.dart';
import 'package:path_provider/path_provider.dart';
import "package:geohetra/data/colors.dart" as color;

class Parametre extends StatefulWidget {
  const Parametre({Key? key}) : super(key: key);
  @override
  State<Parametre> createState() => _ParametreState();
}

class _ParametreState extends State<Parametre> {
  late TextEditingController ctrl = TextEditingController();
  late TextEditingController date = TextEditingController();
  late bool reset = true;

  @override
  void initState() {
    super.initState();
    openSetting();
  }

  void openSetting() async {
    var root = await getApplicationSupportDirectory();
    var file = File(root.path + "/settings.json");
    var text = await file.readAsString();
    Map<String, dynamic> data = json.decode(text);
    setState(() {
      ctrl = TextEditingController(text: data["server"].toString());
      try {
        reset = data["reset"] as bool;
        // ignore: empty_catches
      } catch (e) {}
    });
  }

  void handleSave() async {
    var root = await getApplicationSupportDirectory();
    var file = File(root.path + "/settings.json");
    var text = await file.readAsString();
    Map<String, dynamic> data = json.decode(text);
    data["server"] = ctrl.text;
    await file.writeAsString(json.encode(data));
  }

  Widget col(TextEditingController ctrl) {
    return TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(border: InputBorder.none));
  }

  Container save() {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green,
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
            handleSave();
          },
          child: const Text("Enregistrer"),
        ));
  }

  void resetFunc() async {
    await DB.instance.reset().then((value) async {
      var root = await getApplicationSupportDirectory();
      var file = File(root.path + "/settings.json");
      var text = await file.readAsString();
      Map<String, dynamic> data = json.decode(text);
      data["reset"] = false;
      await file.writeAsString(json.encode(data));
    });
  }

  Container resetbtn() {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 10, 218, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    );
    return Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          style: raisedButtonStyle,
          onPressed: () {
            resetFunc();
          },
          child: const Text("Reinitialiser"),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color.AppColor.backgroundColor,
        appBar: AppBar(
          title: const Text("Parametre"),
          backgroundColor: Colors.green[900],
        ),
        body: Column(children: [
          Expanded(
            child: ListView(
              children: [myTextField(ctrl, "Adresse du serveur"), save()],
            ),
          ),
        ]));
  }
}
