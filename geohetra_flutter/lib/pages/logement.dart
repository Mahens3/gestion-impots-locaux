import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/components/checkbox.dart';
import 'package:geohetra/models/logement.dart';
import '../database/database.dart';
import "../data/logement.dart" as data;
import "../data/colors.dart" as color;
import "../components/components.dart";
import '../components/button.dart';

// ignore: prefer_const_literals_to_create_immutables
class FormLogement extends StatefulWidget {
  final Logement? logement;
  final Function? refresh;
  final int numcons;
  const FormLogement(
      {Key? key, this.logement, this.refresh, required this.numcons})
      : super(key: key);
  @override
  State<FormLogement> createState() => _FormLogementState();
}

class _FormLogementState extends State<FormLogement> {
  Logement? logement;

  @override
  void initState() {
    super.initState();
    logement = widget.logement;
  }

  late String statut =
      logement != null ? logement!.statut : data.Logement.statut[0];
  late String typelog =
      logement != null ? logement!.typelog : data.Logement.typelog[0];
  late String typeoccup =
      logement != null ? logement!.typeoccup : data.Logement.typeoccup[0];
  late String niveau =
      logement != null ? logement!.niveau : data.Logement.niveau[0];

  late String? lien = logement != null ? logement!.lien : data.Logement.lien[0];

  late TextEditingController declarant = TextEditingController(
      text: logement != null ? logement!.declarant.toString() : "");
  late FocusNode declarantFocus = FocusNode();

  late TextEditingController nbrres = TextEditingController(
      text: logement != null ? logement!.nbrres.toString() : "0");

  late TextEditingController valrec = TextEditingController(
      text: logement != null ? logement!.valrec.toString() : "0");
  late TextEditingController nbrpp = TextEditingController(
      text: logement != null ? logement!.nbrpp.toString() : "0");
  late TextEditingController nbrps = TextEditingController(
      text: logement != null ? logement!.nbrps.toString() : "0");
  late TextEditingController stpp = TextEditingController(
      text: logement != null ? logement!.stpp.toString() : "0");
  late TextEditingController stps = TextEditingController(
      text: logement != null ? logement!.stps.toString() : "0");
  late TextEditingController phone = TextEditingController(
      text: logement != null ? logement!.phone.toString() : "");
  late TextEditingController vlmeprop = TextEditingController(
      text: logement != null ? logement!.vlmeprop.toString() : "0");
  late TextEditingController vve =
      TextEditingController(text: logement != null ? vve.toString() : "0");
  late TextEditingController lm = TextEditingController(
      text: logement != null ? logement!.lm.toString() : "0");
  late TextEditingController vlmeoc = TextEditingController(
      text: logement != null ? logement!.vlmeoc.toString() : "0");

  late String confort = logement != null ? logement!.confort : "";
  void handleConfort(String value) {
    setState(() {
      confort = value;
    });
  }

  void handleSave() async {
    Logement logement = getLogement();
    logement.datetimes = now();
    logement.numlog = await identity();
    if (declarant.text.isNotEmpty) {
      await DB.instance.insertLogement(logement).then((value) {
        widget.refresh!();
        Navigator.of(context).pop();
      });
    } else {
      declarantFocus.requestFocus();
    }
  }

  Logement getLogement() {
    return Logement(
        nbrres: int.parse(nbrres.text),
        niveau: niveau,
        statut: statut,
        typelog: typelog,
        typeoccup: typeoccup,
        vlmeprop: 0,
        vve: 0,
        lm: int.parse(lm.text),
        vlmeoc: 0,
        confort: confort,
        phone: phone.text,
        valrec: int.parse(valrec.text),
        nbrpp: int.parse(nbrpp.text),
        stpp: double.tryParse(stpp.text),
        nbrps: int.parse(nbrps.text),
        stps: int.parse(stps.text),
        declarant: declarant.text,
        lien: lien,
        idcons: widget.numcons);
  }

  void handleUpdate() async {
    Logement logement = getLogement();

    logement.datetimes = widget.logement!.datetimes;
    logement.numlog = widget.logement!.numlog;
    if (declarant.text.isNotEmpty) {
      await DB.instance.updateLogement(logement).then((value) {
        widget.refresh!();
        Navigator.of(context).pop();
      });
    } else {
      declarantFocus.requestFocus();
    }
  }

  void changeValueOf(String varToChange, String valueOf) {
    setState(() {
      switch (varToChange) {
        case ("Type logement"):
          typelog = valueOf;

          break;
        case ("Niveau"):
          niveau = valueOf;

          break;
        case ("Statut"):
          statut = valueOf;

          break;
        case ("Type occupant"):
          typeoccup = valueOf;
          break;
        case ("Lien par rapport au chef du logement"):
          lien = valueOf;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    data.Logement.dropDownItems();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Formulaire logement"),
          backgroundColor: Colors.green[900],
        ),
        backgroundColor: color.AppColor.backgroundColor,
        body: Column(children: [
          Expanded(
            child: ListView(
              children: [
                MyDropdown(
                    label: "Statut",
                    value: statut,
                    items: data.Logement.dropdownStatut,
                    setState: changeValueOf),
                MyDropdown(
                    label: "Type logement",
                    value: typelog,
                    items: data.Logement.dropdownTypelog,
                    setState: changeValueOf),
                MyDropdown(
                    label: "Type occupant",
                    value: typeoccup,
                    items: data.Logement.dropdownTypeoccup,
                    setState: changeValueOf),
                myDropDownButton("Niveau", niveau, data.Logement.dropdownNiveau,
                    changeValueOf),
                myTextField(nbrres, "Nombre personne residant", number: true),
                myTextField(lm, "Loyer mensuel", number: true),
                myTextField(nbrpp, "Nombre de pièce", number: true),
                myTextField(stpp, "Surface du logement", number: true),
                CheckBoxes(
                    options: data.Logement.varconfort,
                    value: confort,
                    handleChange: handleConfort,
                    title: "Confort"),
                myTextField(declarant, "Declarant",
                    number: false, focusNode: declarantFocus),
                MyDropdown(
                    label: "Lien par rapport au chef du logement",
                    value: lien,
                    items: data.Logement.dropdownLien,
                    setState: changeValueOf),
                saveButton(logement == null ? handleSave : handleUpdate)
              ],
            ),
          ),
        ]));
  }
}
