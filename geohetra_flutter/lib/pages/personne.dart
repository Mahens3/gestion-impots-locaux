import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/models/personne.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geohetra/database/database.dart';
import "package:geohetra/data/colors.dart" as color;
import "package:geohetra/components/components.dart";
import 'package:geohetra/components/button.dart';

class DropdownOption {
  final List<dynamic> options;
  List<DropdownMenuItem<String>> dropdown = [];

  DropdownOption({required this.options}) {
    dropDownItems();
  }

  void dropDownItems() {
    dropdown.clear();
    for (var i = 0; i < options.length; i++) {
      dropdown.add(DropdownMenuItem(
          value: options[i].toString(), child: Text(options[i].toString())));
    }
  }
}

class FormPersonne extends StatefulWidget {
  final int numcons;
  final Personne? personne;
  final Function refresh;
  const FormPersonne(
      {Key? key, this.personne, required this.refresh, required this.numcons})
      : super(key: key);
  @override
  State<FormPersonne> createState() => _FormPersonneState();
}

class _FormPersonneState extends State<FormPersonne> {
  Personne? personne;

  late DropdownOption profOption = DropdownOption(options: []);
  late DropdownOption lieuOption = DropdownOption(options: []);

  late Map<String, dynamic> options = {};

  late String sexe = personne != null ? personne!.sexe : "Homme";
  late String profession = personne != null ? personne!.profession : "";
  late String lieu = personne != null ? personne!.lieu : "";
  late FocusNode ageFocus = FocusNode();

  late String selectedLieu = "";

  late TextEditingController age = TextEditingController(
      text: personne != null ? personne!.age.toString() : "");

  @override
  void initState() {
    super.initState();
    getParametre();
    selectedLieu = getType();
    personne = widget.personne;
  }

  late Map<String, dynamic> items = {};

  String getType() {
    if (widget.personne != null) {
      var prof = widget.personne!.profession;
      if (prof.contains("primaire")) {
        return "primaire";
      } else if (prof.contains("secondaire")) {
        return "secondaire";
      } else if (prof.contains("lycée")) {
        return "lycée";
      } else {
        return "";
      }
    } else {
      return "";
    }
  }

  void getParametre() async {
    var root = await getApplicationSupportDirectory();
    var file = File(root.path + "/parampers.json");
    bool exist = await file.exists();
    if (!exist) {
      var data = {
        "profession": [
          "Aucun",
          "Elève primaire",
          "Elève secondaire",
          "Elève au lycée",
          "Etudiant(e)",
          "Docteur",
          "Menagère",
          "Chauffeur",
          "Instituteur(trice)",
          "Cultivateur(trice)",
          "Vendeur(se)",
          "Menusier",
          "Charpentier",
        ],
        "primaire": [
          "AMJ",
          "Bambins",
          "ESPA",
          "Ecole saint Vincent de Paul",
          "EPP Alatsinainy",
          "EPP Soamanandray",
          "EPP Teteza",
          "EPP Ankondromalaza",
          "EPP Atsonga",
          "EPP Ambalamahasoa Sud",
          "EPP Ampanaovantsavony",
          "EPP Avaramanda",
          "EPP Mandamako",
          "EPP Teloambinifolo",
          "EPP Alatsinainy Fonenantsoa",
          "EPP Ambalamahasoa Nord",
          "EPP Tsaranoro",
          "EPP Maroparasy",
          "EPP Sahamasy",
          "EPP Vatofotsy",
          "EPP Vondrokely",
          "EPP Ambohimadera",
          "EPP Ambohimahasoa Namongo",
        ],
        "secondaire": [
          "ESPA",
          "AMJ",
          "CEG Ambohijafy",
          "CEG Tsaranoro",
          "Lovasoa",
          "Ecole saint Vincent de Paul"
        ],
        "lycée": [
          "Joel Sylvain",
          "LTP Teloambinifolo",
          "FJKM Lovasoa",
          "Anne Marie Javouhey",
          "Saint Joseph",
          "Saint Jean",
          "FANILO",
          "L PRIM",
          "Les Lisérons"
        ],
      };

      file = await file.writeAsString(json.encode(data));
      extract(file);
    } else {
      extract(file);
    }
  }

  Map<String, dynamic> handleParam(Map<String, dynamic> data) {
    List<dynamic> profession = data["profession"];
    profession.add("Autre");

    List<dynamic> lycee = data["lycée"];
    lycee.add("Autre");

    List<dynamic> secondaire = data["secondaire"];
    secondaire.add("Autre");

    List<dynamic> primaire = data["primaire"];
    primaire.add("Autre");

    return {
      "profession": profession,
      "lycée": lycee,
      "secondaire": secondaire,
      "primaire": primaire
    };
  }

  void saveFile(Map<String, dynamic> data) async {
    var root = await getApplicationSupportDirectory();
    var file = File(root.path + "/parampers.json");
    await file.writeAsString(json.encode(data), flush: true);
  }

  void extract(File file) async {
    var content = await file.readAsString();
    var content1 = json.decode(content);
    var content2 = json.decode(content);
    setState(() {
      items = content1;
    });
    setState(() {
      options = handleParam(content2);
      var opt = options["profession"];

      profession =
          widget.personne == null ? opt[0] : widget.personne!.profession;
      profOption = DropdownOption(options: opt);
      if (selectedLieu == "") {
        opt = options["primaire"];
      } else {
        opt = options[selectedLieu];
      }
      lieu = widget.personne == null ? opt[0] : widget.personne!.lieu;
      lieuOption = DropdownOption(options: opt);
    });
  }

  Personne getPersonne() {
    Personne personne = Personne(
        sexe: sexe,
        profession: profession,
        lieu: profession.contains("Elève") ? lieu : "");
    Map<String, dynamic> liste = items;

    List<dynamic> list = [];
    if (selectedLieu != "") {
      list = liste[selectedLieu];
      if (!list.contains(lieu)) {
        var newList = [];
        for (var i = 0; i < list.length; i++) {
          newList.add(list[i]);
        }
        newList.add(lieu);
        liste[selectedLieu] = newList;
      }
    }

    list = liste["profession"];
    var newList = [];
    if (!list.contains(profession) && selectedLieu == "") {
      for (var i = 0; i < list.length; i++) {
        newList.add(list[i]);
      }
      newList.add(profession);
      liste["profession"] = newList;
    }
    saveFile(liste);
    try {
      personne.age = double.parse(age.text);
      // ignore: empty_catches
    } catch (e) {}
    return personne;
  }

  Widget getLieuWidget() {
    MyDropdown drop = MyDropdown(
        label: "Lieu",
        value: lieu,
        items: lieuOption.dropdown,
        setState: changeValueOf);
    return profession.contains("Elève") ? drop : const SizedBox();
  }

  Widget myRadioButton() {
    List<Widget> buttonRadioList = [];
    buttonRadioList.add(const Text("Sexe"));
    buttonRadioList.add(RadioListTile(
      value: "Homme",
      groupValue: sexe,
      title: const Text("Homme"),
      activeColor: Colors.blue,
      onChanged: (value) {
        setState(() {
          sexe = value as String;
        });
      },
    ));

    buttonRadioList.add(RadioListTile(
      value: "Femme",
      title: const Text("Femme"),
      groupValue: sexe,
      activeColor: Colors.blue,
      onChanged: (value) {
        setState(() {
          sexe = value as String;
        });
      },
    ));
    return Container(
        margin: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width - 20,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buttonRadioList));
  }

  void handleUpdate() async {
    Personne personne = getPersonne();
    personne.numpers = widget.personne!.numpers;
    if (age.text.isEmpty) {
      ageFocus.requestFocus();
    } else {
      await DB.instance.updatePersonne(personne).then((value) {
        widget.refresh();
        Navigator.of(context).pop();
      });
    }
  }

  void handleSave() async {
    Personne personne = getPersonne();
    personne.numpers = await identity();
    personne.datetimes = now();
    personne.idcons = widget.numcons;
    if (age.text.isEmpty) {
      ageFocus.requestFocus();
    } else {
      await DB.instance.insertPersonne(personne).then((value) {
        widget.refresh();
        Navigator.of(context).pop();
      });
    }
  }

  void changeValueOf(String varToChange, String valueOf) {
    setState(() {
      switch (varToChange) {
        case ("Profession"):
          profession = valueOf;
          lieuOption.dropDownItems();
          if (valueOf.contains("primaire")) {
            lieu = options["primaire"][0];
            lieuOption = DropdownOption(options: options["primaire"]);
            selectedLieu = "primaire";
          } else if (valueOf.contains("secondaire")) {
            lieu = options["secondaire"][0];
            selectedLieu = "secondaire";
            lieuOption = DropdownOption(options: options["secondaire"]);
          } else if (valueOf.contains("lycée")) {
            lieu = options["lycée"][0];
            selectedLieu = "lycée";
            lieuOption = DropdownOption(options: options["lycée"]);
          } else {
            lieu = "";
            selectedLieu = "";
          }
          break;
        case ("Lieu"):
          lieu = valueOf;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    profOption.dropDownItems();
    lieuOption.dropDownItems();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Formulaire personne"),
          backgroundColor: Colors.blue[900],
        ),
        backgroundColor: color.AppColor.backgroundColor,
        body: Column(children: [
          Expanded(
            child: ListView(
              children: [
                myRadioButton(),
                myTextField(age, "Age", number: true, focusNode: ageFocus, validator: (value) => null),
                profOption.options.isNotEmpty
                    ? MyDropdown(
                        value: profession,
                        label: "Profession",
                        items: profOption.dropdown,
                        setState: changeValueOf)
                    : const SizedBox(),
                lieuOption.options.isNotEmpty
                    ? profession.contains("Elève")
                        ? MyDropdown(
                            value: lieu,
                            label: "Lieu",
                            items: lieuOption.dropdown,
                            setState: changeValueOf)
                        : const SizedBox()
                    : const SizedBox(),
                saveButton(widget.personne == null ? handleSave : handleUpdate)
              ],
            ),
          ),
        ]));
  }
}
