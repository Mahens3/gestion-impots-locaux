import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/pages/about.dart';
import '../database/database.dart';
import '../models/construction.dart';
import "../data/construction.dart" as data;
import "../data/colors.dart" as color;
import "../components/components.dart";
import '../components/button.dart';
import 'package:latlong2/latlong.dart';

// ignore: prefer_const_literals_to_create_immutables
class FormConstruction extends StatefulWidget {
  final Construction? construction;
  final Function refresh;
  final LatLng? latLng;
  final bool create;
  final bool next;

  static void createConstruction(
      {required Function ref,
      required LatLng position,
      required int idfoko,
      required BuildContext context}) {
    Construction construction = Construction(
        lat: position.latitude, lng: position.longitude, idfoko: idfoko);
    var route = MaterialPageRoute(
        builder: ((context) => FormConstruction(
              refresh: ref,
              next: true,
              construction: construction,
              create: true,
            )));
    Navigator.of(context).push(route);
  }

  const FormConstruction(
      {Key? key,
      this.construction,
      this.latLng,
      this.create = false,
      required this.refresh,
      required this.next})
      : super(key: key);
  @override
  State<FormConstruction> createState() => _FormConstructionState();
}

class _FormConstructionState extends State<FormConstruction> {
  Construction? construction;
  late double latitude = 0;
  late double longitude = 0;
  bool next = false;
  late List<Map<String, Object?>> fokontany = [];

  @override
  void initState() {
    super.initState();
    getFokontany();
    construction = widget.construction;
    next = widget.next;
  }

  Widget widgetFkt() {
    return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fokontany",
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
                child: DropdownButton(
                    underline: const SizedBox.shrink(),
                    isExpanded: true,
                    value: fktorigin,
                    items: dropdown,
                    onChanged: (value) {
                      setState(() {
                        fktorigin = value.toString();
                      });
                    })),
          ],
        ));
  }

  void getFokontany() async {
    var fkt = await DB.instance.getFkt(all: true);
    setState(() {
      fokontany = fkt;
      if (construction?.idfoko == null) {
        fktorigin = fokontany.first["id"].toString();
      } else {
        if (construction?.fktorigin != null) {
          fktorigin = construction?.fktorigin.toString();
        } else {
          fktorigin = construction?.idfoko.toString();
        }
      }
    });
  }

  late String? mur = next ? data.Construction.mur[0] : construction!.mur;
  late String? fktorigin = "";
  late String? ossature =
      !next ? construction!.ossature : data.Construction.ossature[0];
  late String? fondation =
      !next ? construction!.fondation : data.Construction.fondation[0];
  late String? toiture =
      !next ? construction!.toiture : data.Construction.toiture[0];
  late String? typehab =
      !next ? construction!.typehab : data.Construction.typehab[0];
  late String? access =
      !next ? construction!.access : data.Construction.access[0];
  late String? etatmur =
      !next ? construction!.etatmur : data.Construction.etatmur[0];
  late String? typecons =
      !next ? construction!.typecons : data.Construction.typecons[0];

  late String? wc = !next ? construction!.wc : "oui";

  late TextEditingController anconst =
      TextEditingController(text: !next ? construction!.anconst : "0");

  late TextEditingController adress = TextEditingController(
      text: construction?.adress == null ? "" : construction!.adress);

  late TextEditingController boriboritany = TextEditingController(
      text:
          construction?.boriboritany == null ? "" : construction!.boriboritany);

  late TextEditingController nbrniv = TextEditingController(
      text: !next ? construction!.nbrniv.toString() : "1");
  late FocusNode nivFocus = FocusNode();

  late TextEditingController nbrhab = TextEditingController(
      text: !next ? construction!.nbrhab.toString() : "0");
  late FocusNode habFocus = FocusNode();

  late TextEditingController nbrcom = TextEditingController(
      text: !next ? construction!.nbrcom.toString() : "0");
  late FocusNode comFocus = FocusNode();

  late TextEditingController nbrbur = TextEditingController(
      text: !next ? construction!.nbrbur.toString() : "0");
  late FocusNode burFocus = FocusNode();

  late TextEditingController nbrprop = TextEditingController(
      text: !next ? construction!.nbrprop.toString() : "0");
  late FocusNode propFocus = FocusNode();

  late TextEditingController nbrocgrat = TextEditingController(
      text: !next ? construction!.nbrocgrat.toString() : "0");
  late FocusNode ocgratFocus = FocusNode();

  late TextEditingController nbrloc = TextEditingController(
      text: !next ? construction!.nbrloc.toString() : "0");
  late FocusNode locFocus = FocusNode();

  late TextEditingController surface = TextEditingController(
      text: !next ? construction!.surface.toString() : "0");
  late FocusNode surfaceFocus = FocusNode();

  void changeValueOf(String varToChange, String valueOf) {
    switch (varToChange) {
      case ("Mur"):
        setState(() {
          mur = valueOf;
        });
        break;
      case ("Ossature"):
        setState(() {
          ossature = valueOf;
        });
        break;
      case ("Toiture"):
        setState(() {
          toiture = valueOf;
        });
        break;
      case ("Fondation"):
        setState(() {
          fondation = valueOf;
        });
        break;
      case ("Type"):
        setState(() {
          typehab = valueOf;
        });
        break;
      case ("Accessibilité"):
        setState(() {
          access = valueOf;
        });
        break;
      case ("Type construction"):
        setState(() {
          typecons = valueOf;
        });
        break;
      case ("Etat du mur"):
        setState(() {
          etatmur = valueOf;
        });
        break;
    }
  }

  Widget myRadioButton() {
    List<Widget> buttonRadioList = [];
    buttonRadioList.add(const Text("Avec WC"));
    buttonRadioList.add(RadioListTile(
      value: "oui",
      groupValue: wc,
      title: const Text("Oui"),
      activeColor: Colors.blue,
      onChanged: (value) {
        setState(() {
          wc = value as String?;
        });
      },
    ));

    buttonRadioList.add(RadioListTile(
      value: "non",
      title: const Text("Non"),
      groupValue: wc,
      activeColor: Colors.blue,
      onChanged: (value) {
        setState(() {
          wc = value as String?;
        });
      },
    ));
    return Container(
        margin: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buttonRadioList));
  }

  bool controlField() {
    if (nbrbur.text.isEmpty) {
      burFocus.requestFocus();
      return false;
    } else if (nbrcom.text.isEmpty) {
      comFocus.requestFocus();
      return false;
    } else if (nbrhab.text.isEmpty) {
      habFocus.requestFocus();
      return false;
    } else if (nbrloc.text.isEmpty) {
      locFocus.requestFocus();
      return false;
    } else if (nbrniv.text.isEmpty) {
      nivFocus.requestFocus();
      return false;
    } else if (nbrocgrat.text.isEmpty) {
      ocgratFocus.requestFocus();
      return false;
    } else if (nbrprop.text.isEmpty) {
      propFocus.requestFocus();
      return false;
    } else if (surface.text.isEmpty) {
      surfaceFocus.requestFocus();
      return false;
    } else {
      return true;
    }
  }

  Construction initConstruct() {
    return Construction(
        id: widget.construction != null ? widget.construction!.id : null,
        mur: mur,
        ossature: ossature,
        toiture: toiture,
        fondation: fondation,
        typehab: typehab,
        etatmur: etatmur,
        access: access,
        adress: adress.text,
        typecons: typecons,
        wc: wc,
        boriboritany: boriboritany.text.toUpperCase(),
        nbrhab: int.tryParse(nbrhab.text),
        nbrniv: int.tryParse(nbrniv.text),
        anconst: anconst.text,
        nbrcom: int.tryParse(nbrcom.text),
        nbrbur: int.tryParse(nbrbur.text),
        nbrprop: int.tryParse(nbrprop.text),
        nbrloc: int.tryParse(nbrloc.text),
        fktorigin: int.tryParse(fktorigin.toString()),
        nbrocgrat: int.tryParse(nbrocgrat.text),
        surface: double.tryParse(surface.text),
        lat: widget.latLng != null
            ? widget.latLng!.latitude
            : widget.construction!.lat,
        lng: widget.latLng != null
            ? widget.latLng!.longitude
            : widget.construction!.lng);
  }

  late List<DropdownMenuItem<String>> dropdown = [];

  void clearDropdown() {
    dropdown.clear();
    for (var item in fokontany) {
      dropdown.add(DropdownMenuItem(
          value: item["id"].toString(),
          child: Text(item["nomfokontany"].toString())));
    }
  }

  void handleUpdate() async {
    Construction construction = initConstruct();
    construction.numcons = widget.construction!.numcons;
    construction.image = widget.construction!.image;
    construction.datetimes = widget.construction!.datetimes;
    construction.idfoko = widget.construction!.idfoko;
    construction.idagt = widget.construction!.idagt;
    if (controlField()) {
      await DB.instance.updateConstruction(construction).then((value) {
        widget.refresh(construction);
        Navigator.of(context).pop();
      });
    }
  }

  void nextStep() async {
    Construction construction = initConstruct();
    final id = await identity();
    construction.numcons = id;
    construction.datetimes = now();
    construction.idfoko = widget.construction!.idfoko;
    if (controlField()) {
      if (widget.create == true) {
        // CREATION D'UNE NOUVELLE CONSTRUCTION
        dynamic idagt = await DB.instance
            .queryBuilder("SELECT idagt FROM user WHERE active=1");
        idagt = idagt.first['idagt'];
        construction.idagt = idagt;
        int id = await DB.instance.insertConstruction(construction);
        construction.id = id;
      } else {
        // MODIFICATION DE LA CONSTRUCTION EXISTANTE
        construction.idagt = widget.construction!.idagt;
        await DB.instance.updateConstruction(construction);
      }

      var route = MaterialPageRoute(
          builder: (context) => About(
                construction: construction,
                refresh: widget.refresh,
              ));
      Navigator.of(context).pushReplacement(route);
      widget.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    data.Construction.dropDownItems();
    clearDropdown();
    return Scaffold(
        backgroundColor: color.AppColor.backgroundColor,
        appBar: AppBar(
          title: const Text("Formulaire construction"),
          backgroundColor: Colors.blue[900],
        ),
        body: Column(children: [
          Expanded(
            child: ListView(
              children: [
                MyDropdown(
                    label: "Type construction",
                    value: typecons,
                    items: data.Construction.dropdownTypecons,
                    setState: changeValueOf),
                widgetFkt(),
                myTextField(adress, "Lot", focusNode: FocusNode(),  validator: (value) => null,),
                myTextField(boriboritany, "Boriboritany",
                    focusNode: FocusNode(),  validator: (value) => null,),
                MyDropdown(
                    label: "Mur",
                    value: mur,
                    items: data.Construction.dropdownMur,
                    setState: changeValueOf),
                MyDropdown(
                    label: "Ossature",
                    value: ossature,
                    items: data.Construction.dropdownOssature,
                    setState: changeValueOf),
                MyDropdown(
                    label: "Fondation",
                    value: fondation,
                    items: data.Construction.dropdownFondation,
                    setState: changeValueOf),
                MyDropdown(
                    label: "Toiture",
                    value: toiture,
                    items: data.Construction.dropdownToiture,
                    setState: changeValueOf),
                MyDropdown(
                    label: "Type",
                    value: typehab,
                    items: data.Construction.dropdownTypehab,
                    setState: changeValueOf),
                MyDropdown(
                    label: "Accessibilité",
                    value: access,
                    items: data.Construction.dropdownAccess,
                    setState: changeValueOf),
                MyDropdown(
                    label: "Etat du mur",
                    value: etatmur,
                    items: data.Construction.dropdownEtatmur,
                    setState: changeValueOf),
                myRadioButton(),
                myTextField(anconst, "Année de la construction", number: true, validator: (value) => null),
                myTextField(nbrniv, "Niveau(nombre d'etage)",
                    number: true, focusNode: nivFocus, validator: (value) => null),
                myTextField(nbrhab, "Nombre de logement pour habitation",
                    number: true, focusNode: habFocus, validator: (value) => null),
                myTextField(nbrcom, "Nombre de logement pour commerce",
                    number: true, focusNode: comFocus, validator: (value) => null),
                myTextField(nbrbur, "Nombre de logement pour bureau",
                    number: true, focusNode: burFocus, validator: (value) => null),
                myTextField(nbrprop, "Nombre de logement pour propriétaire",
                    number: true, focusNode: propFocus, validator: (value) => null),
                myTextField(nbrloc, "Nombre de logement à louer",
                    number: true, focusNode: locFocus, validator: (value) => null),
                myTextField(
                    nbrocgrat, "Nombre de logement pour occupant gratuit",
                    number: true, focusNode: ocgratFocus, validator: (value) => null),
                myTextField(surface, "Surface de la construction",
                    number: true, focusNode: surfaceFocus, validator: (value) => null),
                saveButton(widget.next ? nextStep : handleUpdate),
              ],
            ),
          ),
        ]));
  }
}
