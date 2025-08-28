import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/database/database.dart';
import "package:geohetra/data/colors.dart" as color;
import "package:geohetra/components/components.dart";
import 'package:geohetra/components/button.dart';
import 'package:geohetra/models/ifpb.dart';

// ignore: prefer_const_literals_to_create_immutables
class FormIfpb extends StatefulWidget {
  final Ifpb? ifpb;
  final Function setter;
  final String? numcons;
  const FormIfpb({Key? key, this.ifpb, required this.setter, this.numcons})
      : super(key: key);
  @override
  State<FormIfpb> createState() => _FormIfpbState();
}

class _FormIfpbState extends State<FormIfpb> {
  Ifpb? ifpb;
  @override
  void initState() {
    super.initState();
    ifpb = widget.ifpb;
  }

  late String exon = ifpb != null ? ifpb!.exon : "oui";
  late TextEditingController cause =
      TextEditingController(text: ifpb != null ? ifpb!.cause : "");
  late TextEditingController dernanne =
      TextEditingController(text: ifpb != null ? ifpb!.dernanne : "");
  late TextEditingController montantins = TextEditingController(
      text: ifpb != null ? ifpb!.montantins.toString() : "0");
  late TextEditingController montantpay = TextEditingController(
      text: ifpb != null ? ifpb!.montantpay.toString() : "0");
  late TextEditingController article =
      TextEditingController(text: ifpb != null ? ifpb!.article.toString() : "");
  late TextEditingController role =
      TextEditingController(text: ifpb != null ? ifpb!.role.toString() : "");
  late bool loading = false;
  Ifpb getIfpb() {
    return Ifpb(
        exon: exon,
        dernanne: dernanne.text,
        montantins: int.parse(montantins.text),
        montantpay: int.parse(montantpay.text),
        cause: cause.text,
        article: int.tryParse(article.text),
        role: int.tryParse(role.text));
  }

  void handleSave() async {
    Ifpb ifpb = getIfpb();
    setState(() {
      loading = true;
    });
    ifpb.datetimes = now();
    ifpb.numif = await identity();
    await DB.instance.insertIfpb(ifpb, widget.numcons as String).then((value) {
      widget.setter(ifpb);
      Timer(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    });
  }

  void handleUpdate() async {
    Ifpb ifpb = getIfpb();
    setState(() {
      loading = true;
    });
    ifpb.numif = widget.ifpb!.numif;
    ifpb.datetimes = widget.ifpb!.datetimes;
    await DB.instance.updateIfpb(ifpb).then((value) {
      widget.setter(ifpb);
      Timer(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    });
  }

  Widget myRadioButton(double width) {
    List<Widget> buttonRadioList = [];
    buttonRadioList.add(const Text("Contribuable"));
    buttonRadioList.add(RadioListTile(
      value: "oui",
      groupValue: exon,
      title: const Text("Oui"),
      activeColor: Colors.green,
      onChanged: (value) {
        setState(() {
          exon = value as String;
        });
      },
    ));

    buttonRadioList.add(RadioListTile(
      value: "non",
      title: const Text("Non"),
      groupValue: exon,
      activeColor: Colors.green,
      onChanged: (value) {
        setState(() {
          exon = value as String;
        });
      },
    ));

    return Container(
        margin: const EdgeInsets.all(10),
        width: width,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buttonRadioList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color.AppColor.backgroundColor,
        appBar: AppBar(
          title: const Text("Formulaire IFPB"),
          backgroundColor: Colors.green[900],
        ),
        body: Column(children: [
          Expanded(
            child: ListView(
              children: [
                myRadioButton(MediaQuery.of(context).size.width),
                exon == "oui"
                    ? myTextField(dernanne, "Dernière année de l'avis",
                        number: true, focusNode: FocusNode())
                    : const SizedBox(),
                exon == "oui"
                    ? myTextField(montantins, "Montant inscrit",
                        number: true, focusNode: FocusNode())
                    : const SizedBox(),
                exon == "oui"
                    ? myTextField(montantpay, "Montant payé",
                        number: true, focusNode: FocusNode())
                    : const SizedBox(),
                exon == "oui"
                    ? myTextField(article, "Article",
                        number: true, focusNode: FocusNode())
                    : const SizedBox(),
                exon == "oui"
                    ? myTextField(role, "Role",
                        number: true, focusNode: FocusNode())
                    : const SizedBox(),
                saveButton(ifpb == null ? handleSave : handleUpdate,
                    loading: loading)
              ],
            ),
          ),
        ]));
  }
}
