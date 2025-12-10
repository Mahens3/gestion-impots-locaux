import 'package:flutter/material.dart';
import 'package:geohetra/api/excel.dart';
import 'package:geohetra/components/checkbox.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import "../data/colors.dart" as color;

class Exportation extends StatefulWidget {
  const Exportation({Key? key}) : super(key: key);
  @override
  State<Exportation> createState() => _ExportationState();
}

class _ExportationState extends State<Exportation> {
  late TextEditingController ctrl = TextEditingController();
  late TextEditingController date = TextEditingController();

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

  late bool image = false;

  late bool error = false;

  void handleTables(value) {
    setState(() {
      table = value;
    });
  }

  void handleExport() async {
    var storage = await Permission.storage.request();
    var external = await Permission.manageExternalStorage.request();
    if (storage.isGranted || external.isGranted) {
      List<String> tables = table.split(", ");
      if (ctrl.text == "intel") {
        if (tables.isNotEmpty) {
          exportToExcel(
              date: date.text, alldata: alldata, table: tables, image: image);
        }
        setState(() {
          error = false;
        });
      } else {
        setState(() {
          error = true;
        });
      }
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
            handleExport();
          },
          child: const Text("Exporter"),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color.AppColor.backgroundColor,
        appBar: AppBar(
          title: const Text("Exportation des données"),
          backgroundColor: Colors.blue[900],
        ),
        body: Column(children: [
          Expanded(
            child: ListView(
              children: [
                CheckboxListTile(
                    activeColor: const Color(0xFF1E40AF),
                    value: image,
                    title: const Text("Image"),
                    subtitle: const Text("Exporter avec image"),
                    onChanged: ((value) {
                      setState(() {
                        image = !image;
                      });
                    })),
                CheckBoxes(
                    options: tables,
                    value: table,
                    handleChange: handleTables,
                    title: "Données à exporter"),
                Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Option d'exportation",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          RadioListTile(
                              value: true,
                              groupValue: alldata,
                              activeColor: const Color(0xFF1E40AF),
                              title: const Text("Exporter tous"),
                              onChanged: ((value) {
                                setState(() {
                                  alldata = true;
                                });
                              })),
                          RadioListTile(
                              value: false,
                              groupValue: alldata,
                              activeColor: const Color(0xFF1E40AF),
                              title: const Text("Exporter selon une date"),
                              onChanged: ((value) {
                                setState(() {
                                  alldata = false;
                                });
                              })),
                          alldata == false
                              ? Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 1, 15, 1),
                                  margin:
                                      const EdgeInsets.fromLTRB(50, 0, 0, 7),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0, 0),
                                          blurRadius: 0.5,
                                        )
                                      ]),
                                  child: TextField(
                                    readOnly: true,
                                    controller: date,
                                    decoration: const InputDecoration(
                                        hintText: "YYYY-MM-DD",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                              context: context,
                                              locale: const Locale("fr", "FR"),
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2022),
                                              builder: ((BuildContext context,
                                                  Widget? child) {
                                                return Theme(
                                                    data: ThemeData.light(),
                                                    child: child!);
                                              }),
                                              lastDate: DateTime(2100));
                                      if (pickedDate != null) {
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(pickedDate);
                                        setState(() {
                                          date.text = formattedDate;
                                        });
                                      } else {}
                                    },
                                  ),
                                )
                              : const SizedBox()
                        ])),
                Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Les données de cette application sont confidentielles, donc il faut entrer le mot de passe de l'administateur pour effectuer une exportation",
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Mot de passe",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 1, 15, 1),
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 7),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 0),
                                    blurRadius: 0.5,
                                  )
                                ]),
                            child: TextField(
                                obscureText: true,
                                controller: ctrl,
                                decoration: const InputDecoration(
                                    border: InputBorder.none)),
                          ),
                          error
                              ? const Text(
                                  "Mot de passe incorrect",
                                  style: TextStyle(color: Colors.red),
                                )
                              : const SizedBox(),
                        ])),
                export()
              ],
            ),
          ),
        ]));
  }
}
