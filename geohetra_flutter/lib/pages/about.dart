import 'package:flutter/material.dart';
import 'package:geohetra/components/widget_personne.dart';
import 'package:geohetra/models/ifpb.dart';
import 'package:geohetra/models/personne.dart';
import 'package:geohetra/models/proprietaire.dart';
import 'package:geohetra/pages/construction.dart';
import 'package:geohetra/pages/ifpb.dart';
import 'package:geohetra/pages/logement.dart';
import 'package:geohetra/pages/personne.dart';
import 'package:geohetra/pages/proprietaire.dart';
import "../data/colors.dart" as color;
import '../database/database.dart';

import '../models/construction.dart';
import "../components/construction.dart";
import "../components/proprietaire.dart";
import "../components/ifpb.dart";
import '../components/widget_logement.dart';
import 'package:geohetra/models/logement.dart';

class About extends StatefulWidget {
  final Construction construction;
  final Function refresh;
  const About({Key? key, required this.construction, required this.refresh})
      : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> with TickerProviderStateMixin {
  bool showLog = false;
  late TabController tabController =
      TabController(length: 5, initialIndex: 0, vsync: this);
  late Construction construction;
  Proprietaire? proprietaire;
  IconData icon = Icons.edit;
  Ifpb? ifpb;
  String filename = "";
  List<Logement> logements = [];
  List<Personne> personnes = [];

  void listenTabController() {
    tabController.addListener((() {
      if (tabController.index < 3) {
        setState(() {
          icon = Icons.edit;
        });
      } else {
        setState(() {
          icon = Icons.add;
        });
      }
    }));
  }

  Future changeFile(String file) async {
    var list = file.split(".");
    await DB.instance
        .setImageConstruction(construction.numcons.toString() + "." + list[1],
            construction.id as int)
        .then((value) {
      setState(() {
        filename = file;
        construction.image = construction.numcons.toString() + "." + list[1];
        widget.refresh();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    construction = widget.construction;
    filename = construction.image == null
        ? construction.numcons.toString()
        : construction.image.toString();
    listenTabController();
    setLogements();
    setPersonnes();
    // Initialisation des données du propriétaire
    if (widget.construction.numprop != null) {
      try {
        DB.instance.findProprietaire(widget.construction.numprop).then((value) {
          setState(() {
            proprietaire = value[0];
          });
        });
      } catch (e) {}
    }

    // Initialisation des données de l'IFPB
    if (widget.construction.numifpb != null) {
      try {
        DB.instance.findIfpb(widget.construction.numifpb).then((value) {
          setState(() {
            ifpb = value[0];
          });
        });
      } catch (e) {}
    }
  }

  void setConstruction(Construction newValue) {
    setState(() {
      construction = newValue;
      widget.refresh();
    });
  }

  void setProprietaire(Proprietaire newValue) async {
    Construction construct = construction;
    if (construction.numprop == null) {
      construct.numprop = newValue.numprop as String;
      setState(() {
        proprietaire = newValue;
        widget.refresh();
      });
    } else {
      setState(() {
        construction = construct;
        widget.refresh();
        proprietaire = newValue;
      });
    }
  }

  void setIfpb(Ifpb newValue) async {
    Construction construct = construction;
    if (construction.numifpb == null) {
      construct.numifpb = newValue.numif as String;
      setState(() {
        ifpb = newValue;
        widget.refresh();
      });
    } else {
      setState(() {
        construction = construct;
        ifpb = newValue;
        widget.refresh();
      });
    }
  }

  void setLogements() async {
    await DB.instance.findLogement(widget.construction.id).then((value) {
      setState(() {
        logements = value;
      });
    });
  }

  void setPersonnes() async {
    var persons = await DB.instance.findPersonne(widget.construction.id);
    setState(() {
      personnes = persons;
      personnes;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: color.AppColor.backgroundColor,
        appBar: AppBar(
          title: const Text("Detail"),
          backgroundColor: Colors.green[900],
        ),
        body: SizedBox(
            child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20),
              height: 70,
              alignment: Alignment.center,
              width: screen.width,
              color: Colors.green,
              child: TabBar(
                isScrollable: true,
                indicatorWeight: 4,
                indicatorColor: Colors.white,
                controller: tabController,
                tabs: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.home,
                        size: 15,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Tab(child: Text("Construction")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.account_circle,
                        size: 15,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Tab(child: Text("Propriétaire")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.fact_check,
                        size: 15,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Tab(child: Text("IFPB")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.add_home_work_rounded,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Tab(
                          child: Text("Logement (" +
                              logements.length.toString() +
                              ")")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.supervised_user_circle_rounded,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Tab(
                          child: Text("Personne (" +
                              personnes.length.toString() +
                              ")")),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: SizedBox(
              child: TabBarView(
                controller: tabController,
                children: [
                  widgetConstruct(construction, screen, filename, context,
                      setConstruction, changeFile),
                  containerProprietaire(
                      proprietaire, setProprietaire, screen, context),
                  containerIfpb(ifpb, setIfpb, screen, context),
                  widgetLogements(widget.construction.id as int, logements,
                      setLogements, screen, context),
                  widgetPersonnes(widget.construction.id as int, personnes,
                      setPersonnes, screen, context)
                ],
              ),
            ))
          ],
        )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            MaterialPageRoute route;
            switch (tabController.index) {
              case 0:
                route = MaterialPageRoute(
                    builder: (context) => FormConstruction(
                          construction: construction,
                          next: false,
                          refresh: setConstruction,
                        ));
                break;
              case 1:
                route = MaterialPageRoute(
                    builder: (context) => FormProprietaire(
                          proprietaire: proprietaire,
                          setter: setProprietaire,
                          numcons: construction.id.toString(),
                        ));
                break;
              case 2:
                route = MaterialPageRoute(
                    builder: (context) => FormIfpb(
                          ifpb: ifpb,
                          setter: setIfpb,
                          numcons: construction.id.toString(),
                        ));
                break;

              case 3:
                route = MaterialPageRoute(
                    builder: (context) => FormLogement(
                        numcons: construction.id as int,
                        refresh: setLogements));
                break;
              default:
                route = MaterialPageRoute(
                    builder: (context) => FormPersonne(
                        numcons: construction.id as int,
                        refresh: setPersonnes));
            }
            Navigator.of(context).push(route);
          },
          child: Icon(icon),
        ));
  }
}
