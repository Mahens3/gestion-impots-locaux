import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/models/proprietaire.dart';
import 'package:geohetra/database/database.dart';
import "package:geohetra/data/proprietaire.dart" as data;
import "package:geohetra/data/colors.dart" as color;
import "package:geohetra/components/components.dart";
import 'package:geohetra/components/button.dart';

class FormProprietaire extends StatefulWidget {
  final Proprietaire? proprietaire;
  final Function? setter;
  final String? numcons;
  const FormProprietaire(
      {Key? key, this.proprietaire, this.numcons, this.setter})
      : super(key: key);
  @override
  State<FormProprietaire> createState() => _FormProprietaireState();
}

class _FormProprietaireState extends State<FormProprietaire> {
  Proprietaire? proprietaire;

  @override
  void initState() {
    super.initState();
    proprietaire = widget.proprietaire;
  }

  late String? type = "";
  late TextEditingController nom = TextEditingController(
      text: proprietaire != null ? proprietaire!.nomprop : "");
  late FocusNode nomFocus = FocusNode();
  late TextEditingController prenom = TextEditingController(
      text: proprietaire != null ? proprietaire!.prenomprop : "");
  late TextEditingController adresse = TextEditingController(
      text: proprietaire != null ? proprietaire!.adress : "");
  late bool loading = false;

  Proprietaire getProprietaire() {
    return Proprietaire(
        nomprop: nom.text.toUpperCase(),
        prenomprop: prenom.text,
        adress: adresse.text,
        typeprop: type,
        datetimes: now());
  }

  void handleSave() async {
    Proprietaire proprietaire = getProprietaire();
    proprietaire.datetimes = now();
    proprietaire.numprop = await identity();

    setState(() {
      loading = true;
    });
    if (nom.text.isNotEmpty) {
      await DB.instance
          .insertProprietaire(proprietaire, widget.numcons as String)
          .then((value) async {
        await widget.setter!(proprietaire);
        Timer(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      });
    } else {
      nomFocus.requestFocus();
    }
  }

  void handleUpdate() async {
    Proprietaire proprietaire = getProprietaire();
    setState(() {
      loading = true;
    });
    proprietaire.datetimes = widget.proprietaire!.datetimes;
    proprietaire.numprop = widget.proprietaire!.numprop;
    if (nom.text.isNotEmpty) {
      await DB.instance.updateProprietaire(proprietaire).then((value) {
        widget.setter!(proprietaire);
        Timer(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      });
    } else {
      nomFocus.requestFocus();
    }
  }

  void changeValueOf(String varToChange, String valueOf) {
    switch (varToChange) {
      case ("Type"):
        setState(() {
          type = valueOf;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    data.Proprietaire.dropDownItems();
    return Scaffold(
        backgroundColor: color.AppColor.backgroundColor,
        appBar: AppBar(
          title: const Text("Formulaire de propriétaire"),
          backgroundColor: Colors.green[900],
        ),
        body: Column(children: [
          Expanded(
            child: ListView(
              children: [
                myTextField(nom, "Nom", focusNode: nomFocus),
                myTextField(prenom, "Prénoms"),
                myTextField(adresse, "Adresse"),
                saveButton(proprietaire == null ? handleSave : handleUpdate,
                    loading: loading)
              ],
            ),
          ),
        ]));
  }
}
