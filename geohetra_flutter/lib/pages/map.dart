import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:file_manager/file_manager.dart';
import 'package:geohetra/api/control.dart';
import 'package:geohetra/components/fade_animation.dart';
import 'package:geohetra/components/tools.dart';
import 'package:geohetra/database/database.dart';
import 'package:geohetra/models/construction.dart';
import 'package:geohetra/pages/about.dart';
import 'package:geohetra/pages/construction.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class OfflineMap extends StatefulWidget {
  final bool isSending;
  final Function handleSend;

  const OfflineMap(
      {Key? key, required this.isSending, required this.handleSend})
      : super(key: key);
  @override
  OfflineMapState createState() {
    return OfflineMapState();
  }
}

class OfflineMapState extends State<OfflineMap> with TickerProviderStateMixin {
  double currentLatitude = -21.83083;
  double currentLongitude = 46.932005;
  LatLng center = LatLng(-21.83083, 46.932005);

  late LatLng positionCreate = LatLng(0, 0);
  late bool canCreate = false;

  late Map<String, Object?> agent = {};
  void getAgent() async {
    var result =
        await DB.instance.queryBuilder("SELECT * FROM user WHERE active=1");
    setState(() {
      agent = result.first;
    });
  }

  OfflineMapState() {
    launch();
  }

  MapController mapController = MapController();

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late bool loading = true; // ETO
  late String str = "";
  late String stage = "";
  late int index = 0;

  int? limit;

  late bool showInachieve = true;
  late bool showAchieve = true;
  late bool showVoisin = true;

  late List<Marker> markers = [];
  late List<Marker> markerAchieve = [];
  late List<Marker> markerVoisin = [];
  late Map<String, String> tache = {
    "pourcentage": "",
    "tache": "",
    "cree": "",
    "reste": "",
    "quota": ""
  };

  late int idfoko = 0;
  late List<Map<String, Object?>> fokontany = [];

  late LatLng gps = LatLng(0, 0);

  void setIdFoko(int id) {
    setState(() {
      idfoko = id;
    });
    refresh(moved: true);
  }

  late Map<String, Color> colors = {
    "achieve": Colors.red,
    "inachieve": Colors.yellow,
    "voisin": Colors.purple
  };

  @override
  void initState() {
    super.initState();
    localisation();
    getAgent();
    downloadCoordinates();
  }

  Future launch() async {
    var id = await controlData();
    var pl = await formatDate();
  }

  void handleLimit(int? newLimit) {
    refresh();
    setState(() {
      limit = newLimit;
    });
  }

  void localisation() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      setState(() {
        gps = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void yourLocatlisation() {
    mapController.move(gps, mapController.zoom);
  }

  void setMarkerInachieve({int? idfkt, bool moved = true}) async {
    List<Marker> markercons = [];

    //var constructions = await DB.instance.findAmbiny();
    var constructions =
        await DB.instance.findConstruction(idfkt: idfkt, limit: limit);

    for (var construction in constructions) {
      Marker marker = Marker(
          key: Key(construction.id.toString()),
          width: 15,
          height: 15,
          point: LatLng(construction.lat, construction.lng),
          builder: (BuildContext ctx) => InkWell(
              onTap: () {
                dynamic route;
                if (construction.numcons == null) {
                  route = MaterialPageRoute(
                      builder: (context) => FormConstruction(
                            construction: construction,
                            refresh: refresh,
                            next: true,
                          ));
                } else {
                  route = MaterialPageRoute(
                      builder: (context) => About(
                            construction: construction,
                            refresh: refresh,
                          ));
                }
                Navigator.of(context).push(route);
              },
              child: Icon(
                Icons.home_outlined,
                shadows: const [Shadow(color: Colors.grey, blurRadius: 2)],
                size: 16,
                color: colors["inachieve"],
              )));
      markercons.add(marker);
    }
    setState(() {
      markers = markercons;
      loading = false;
    });
  }

  void setMarkerAchieve(int idfkt) async {
    List<Marker> markercons = [];
    // ETO OVAINA
    var constructions = await DB.instance.findAchieve(idfkt: idfkt);
    for (var construction in constructions) {
      Marker marker = Marker(
          key: Key(construction.id.toString()),
          width: 15,
          height: 15,
          point: LatLng(construction.lat, construction.lng),
          builder: (BuildContext ctx) => InkWell(
              onTap: () {
                dynamic route;
                if (construction.mur == null) {
                  route = MaterialPageRoute(
                      builder: (context) => FormConstruction(
                            construction: construction,
                            refresh: refresh,
                            next: true,
                          ));
                } else {
                  route = MaterialPageRoute(
                      builder: (context) => About(
                            construction: construction,
                            refresh: refresh,
                          ));
                }
                Navigator.of(context).push(route);
              },
              child: Icon(
                Icons.home_outlined,
                shadows: const [Shadow(color: Colors.grey, blurRadius: 2)],
                size: 16,
                color: colors["achieve"],
              )));
      markercons.add(marker);
    }
    setState(() {
      markerAchieve = markercons;
    });
  }

  void setMarkerVoisin(int idfkt) async {
    List<Marker> markercons = [];
    var constructions = await DB.instance.findVoisin(idfkt: idfkt);
    for (var construction in constructions) {
      Marker marker = Marker(
          key: Key(construction.id.toString()),
          width: 15,
          height: 15,
          point: LatLng(construction.lat, construction.lng),
          builder: (BuildContext ctx) => InkWell(
              onTap: () {},
              child: Icon(
                Icons.home_outlined,
                shadows: const [Shadow(color: Colors.grey, blurRadius: 2)],
                size: 16,
                color: colors["voisin"],
              )));
      markercons.add(marker);
    }
    setState(() {
      markerVoisin = markercons;
    });
  }

  Marker createMark() {
    return Marker(
        width: 15,
        height: 15,
        point: positionCreate,
        builder: (BuildContext ctx) => const Icon(
              Icons.home,
              shadows: [Shadow(color: Colors.grey, blurRadius: 2)],
              size: 16,
              color: Colors.yellow,
            ));
  }

  void setColor(Map<String, Color> color) {
    setState(() {
      colors = color;
    });
  }

  void handleAchieve() {
    setState(() {
      showAchieve = !showAchieve;
    });
  }

  void handleInachieve() {
    setState(() {
      showInachieve = !showInachieve;
    });
  }

  void handleVoisin() {
    setState(() {
      showVoisin = !showVoisin;
    });
  }

  void refresh({bool moved = false}) async {
    var fkt = await DB.instance.getFkt();
    var id = 0;
    try {
      try {
        if (idfoko == 0) {
          id = fkt.first["idfoko"] as int;
        } else {
          id = idfoko;
        }
      } catch (e) {}
    } catch (e) {
      //await DB.instance.insertFokontany();
    } finally {
      setMarkerInachieve(idfkt: id, moved: moved);
      setMarkerAchieve(id);
      setMarkerVoisin(id);
      try {
        var ta = await DB.instance.getTache();
        setState(() {
          idfoko = id;
          tache = ta;
        });
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  Future<String> _getPathMap() async {
    var support = await FileManager.getStorageList();
    return support.last.path + "/Geohetra/map/{z}/{x}/{y}.png";
  }

  Future downloadCoordinates() async {
    var root = await getApplicationSupportDirectory();
    var file = File(root.path + "/settings.json");
    var text = await file.readAsString();

    var agent =
        await DB.instance.queryBuilder("SELECT idagt FROM user WHERE active=1");

    var construction = await DB.instance.queryBuilder(
        "SELECT idcoord FROM construction WHERE idagt=${agent.first["idagt"]} ORDER BY idcoord");
    var idcoord = "0";
    if (construction.isNotEmpty) {
      idcoord = construction.last["idcoord"].toString();
    }

    Map<String, dynamic> data = json.decode(text);
    setState(() {
      loading = true;
    });
    try {
      final response = await http.post(
          Uri.parse(data["server"].toString() + "/api/coordonnees/get"),
          body: {"idagt": agent.first["idagt"].toString(), "idcoord": idcoord});

      print(response.body);
      setState(() {
        str = "0%";
        stage = "Téléchargement des coordonées...";
      });

      List<dynamic> coordinates = json.decode(response.body);

      for (var i = 0; i < coordinates.length; i++) {
        Map<String, dynamic> coords = coordinates[i] as Map<String, dynamic>;
        /**
        await DB.instance
            .insertConstruction(Construction.fromDynamic(coords))
            .then((response) {
          setState(() {
            var pourcent = (i * 100) / coordinates.length;
            str = pourcent.round().toString() + "%";
          });
        });
         */
        String query =
            "(${coords["lat"]},${coords["lng"]},${coords["idagt"]},'${coords["typequart"]}',${coords["rang"]},${coords["idfoko"]},${coords["id"]})";
        await DB.instance.rawQuery(query).then((value) {
          setState(() {
            var pourcent = (i * 100) / coordinates.length;
            str = pourcent.round().toString() + "%";
          });
        });
      }
      // ignore: empty_catches
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      loading = false;
      refresh();
    });
  }

  void handleError(bool value) {
    setState(() {
      error = value;
    });
  }

  void logout() async {
    await DB.instance.queryUpdate("UPDATE user SET active=0").then((value) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    });
  }

  LatLng toLatLng(String lat, String lng) {
    return LatLng(double.parse(lat), double.parse(lng));
  }

  // Equipe 10, Equipe 5, 4

  // DRAWER
  Widget drawer() {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height - 80,
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey[300] as Color))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/logo.png",
                                width: 30,
                                height: 30,
                              ),
                              const Text(
                                "Geo",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              const Text(
                                "hetra",
                                style: TextStyle(fontSize: 20),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 5, left: 5),
                                child: Text(
                                  "v1.0.5",
                                  style: TextStyle(fontSize: 13),
                                ),
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                          onTap: () {
                            _key.currentState!.closeDrawer();
                            widget.handleSend();
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(2)),
                                    padding: const EdgeInsets.all(5),
                                    margin:
                                        const EdgeInsets.fromLTRB(40, 0, 10, 0),
                                    child: const Icon(
                                      Icons.wifi,
                                      size: 13,
                                    ),
                                  ),
                                  Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "Envoyer données",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Envoi des informations au serveur distant (via WI-FI)",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ))
                                ],
                              ))),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed("/export");
                            _key.currentState!.closeDrawer();
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(2)),
                                    padding: const EdgeInsets.all(5),
                                    margin:
                                        const EdgeInsets.fromLTRB(40, 0, 10, 0),
                                    child: const Icon(
                                      Icons.data_object_sharp,
                                      size: 13,
                                    ),
                                  ),
                                  Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "Exporter données",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Exportation des informations collectées dans un fichier excel",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ))
                                ],
                              ))),
                      InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/setting");
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(2)),
                                    padding: const EdgeInsets.all(5),
                                    margin:
                                        const EdgeInsets.fromLTRB(40, 0, 10, 0),
                                    child: const Icon(
                                      Icons.settings,
                                      size: 13,
                                    ),
                                  ),
                                  Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "Parametre",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Configuration de l'app",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ))
                                ],
                              ))),
                      const SizedBox(height: 20),
                      InkWell(
                          onTap: () {
                            logout();
                          },
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Colors.grey[300] as Color))),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(2)),
                                    padding: const EdgeInsets.all(5),
                                    margin:
                                        const EdgeInsets.fromLTRB(50, 0, 10, 0),
                                    child: const Icon(
                                      Icons.power_settings_new,
                                      size: 13,
                                    ),
                                  ),
                                  Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "Se deconnecter",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ))
                                ],
                              ))),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: Colors.grey[300] as Color))),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            40, 0, 10, 0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Equipe " +
                                                  agent["numequip"].toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              " (" +
                                                  agent["pseudo"].toString() +
                                                  ")",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            40, 0, 10, 0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Construction : ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              tache["tache"].toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              " (" +
                                                  tache["reste"].toString() +
                                                  ")",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            40, 0, 10, 0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Pourcentage : ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              tache["pourcentage"].toString() +
                                                  "%",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            40, 0, 10, 0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Quota du jour : ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              tache["quota"].toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ))
                                  ],
                                )
                              ],
                            )),
                      )
                    ],
                  )),
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  width: 500,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.grey[300] as Color))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Copyright ",
                        style: TextStyle(fontSize: 11),
                      ),
                      Icon(
                        Icons.copyright,
                        size: 13,
                      ),
                      Text(
                        " 2023 developped by ",
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        "Dera Philippe",
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ))
            ]));
  }

  Container retryBtn() {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
    );
    return Container(
        margin: const EdgeInsets.all(20),
        height: 50,
        child: ElevatedButton(
          style: raisedButtonStyle,
          onPressed: () {
            setState(() {
              str = "";
            });
            handleError(false);
            downloadCoordinates();
          },
          child: const Text("Réessayer",
              style: TextStyle(
                color: Colors.white,
              )),
        ));
  }

  late bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: Drawer(
        child: drawer(),
      ),
      body: loading
          ? Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.green[900] as Color,
                Colors.green[800] as Color,
                Colors.green[400] as Color
              ])),
              child: Center(
                child: Column(children: [
                  Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 2 - 100),
                      child: Stack(
                        children: error
                            ? [
                                const SizedBox(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 60,
                                  ),
                                )
                              ]
                            : [
                                const SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                                Container(
                                    width: 40,
                                    height: 40,
                                    margin: const EdgeInsets.only(left: 2),
                                    child: Center(
                                        child: Text(
                                      str,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ))),
                              ],
                      )),
                  error
                      ? Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: const Text(
                            "Echec de la connexion",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : const SizedBox(),
                  Container(
                    margin: EdgeInsets.only(top: error ? 5 : 30),
                    child: Text(
                      error
                          ? "Impossible de se connecter au serveur distant."
                          : stage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  error ? retryBtn() : const SizedBox()
                ]),
              ))
          : FutureBuilder<String>(
              future: _getPathMap(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Stack(
                    children: [
                      SimpleTransition(
                          0.2,
                          FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              onTap: (position, latlng) {
                                setState(() {
                                  positionCreate = latlng;
                                });
                              },
                              rotation: 0.5,
                              interactiveFlags: InteractiveFlag.drag |
                                  InteractiveFlag.pinchZoom,
                              center: center,
                              maxZoom: 19,
                              minZoom: 14,
                              zoom: 14,
                              plugins: [MarkerClusterPlugin()],
                            ),
                            layers: [
                              TileLayerOptions(
                                evictErrorTileStrategy:
                                    EvictErrorTileStrategy.notVisible,
                                tileProvider: FileTileProvider(),
                                errorImage: const AssetImage("assets/grey.png"),
                                errorTileCallback: ((tile, error) {}),
                                backgroundColor: Colors.grey,
                                tms: true,
                                urlTemplate: snapshot.data,
                              ),
                              MarkerLayerOptions(
                                markers: [
                                  Marker(
                                      width: 10,
                                      height: 10,
                                      point: gps,
                                      builder: (BuildContext ctx) =>
                                          const GPS())
                                ],
                              ),
                              showInachieve
                                  ? MarkerClusterLayerOptions(
                                      maxClusterRadius: 120,
                                      disableClusteringAtZoom: 16,
                                      size: const Size(30, 30),
                                      anchor:
                                          AnchorPos.align(AnchorAlign.center),
                                      fitBoundsOptions: const FitBoundsOptions(
                                        padding: EdgeInsets.all(10),
                                      ),
                                      builder: (context, markers) {
                                        return FloatingActionButton(
                                          heroTag: null,
                                          backgroundColor: Colors.lightGreen,
                                          child:
                                              Text(markers.length.toString()),
                                          onPressed: null,
                                        );
                                      },
                                      markers: markers)
                                  : MarkerLayerOptions(),
                              canCreate
                                  ? MarkerLayerOptions(markers: [createMark()])
                                  : MarkerLayerOptions(),
                              showAchieve
                                  ? MarkerClusterLayerOptions(
                                      maxClusterRadius: 120,
                                      disableClusteringAtZoom: 17,
                                      size: const Size(30, 30),
                                      anchor:
                                          AnchorPos.align(AnchorAlign.center),
                                      fitBoundsOptions: const FitBoundsOptions(
                                        padding: EdgeInsets.all(10),
                                      ),
                                      builder: (context, markers) {
                                        return FloatingActionButton(
                                          heroTag: null,
                                          backgroundColor: Colors.lightGreen,
                                          child:
                                              Text(markers.length.toString()),
                                          onPressed: null,
                                        );
                                      },
                                      markers: markerAchieve)
                                  : MarkerLayerOptions(),
                              showVoisin
                                  ? MarkerClusterLayerOptions(
                                      maxClusterRadius: 120,
                                      disableClusteringAtZoom: 17,
                                      size: const Size(30, 30),
                                      anchor:
                                          AnchorPos.align(AnchorAlign.center),
                                      fitBoundsOptions: const FitBoundsOptions(
                                        padding: EdgeInsets.all(10),
                                      ),
                                      builder: (context, markers) {
                                        return FloatingActionButton(
                                          heroTag: null,
                                          backgroundColor: Colors.lightGreen,
                                          child:
                                              Text(markers.length.toString()),
                                          onPressed: null,
                                        );
                                      },
                                      markers: markerVoisin)
                                  : MarkerLayerOptions()
                            ],
                          )),
                      Positioned(
                          top: 40,
                          left: 10,
                          child: InkWell(
                              onTap: (() {
                                if (widget.isSending == false) {
                                  _key.currentState!.openDrawer();
                                }
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: widget.isSending == true
                                    ? const SizedBox(
                                        height: 27,
                                        width: 27,
                                        child: CircularProgressIndicator(
                                          color: Colors.grey,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.menu_book,
                                        color: Colors.grey,
                                        size: 28,
                                      ),
                              ))),
                      Positioned(
                          top: 100,
                          left: 10,
                          child: InkWell(
                              onTap: (() {
                                setState(() {
                                  canCreate = !canCreate;
                                });
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: canCreate == true
                                        ? Colors.green
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  Icons.location_on,
                                  color: canCreate == true
                                      ? Colors.white
                                      : Colors.grey,
                                  size: 28,
                                ),
                              ))),
                      canCreate
                          ? Positioned(
                              top: 160,
                              left: 10,
                              child: InkWell(
                                  onTap: (() {
                                    setState(() {
                                      FormConstruction.createConstruction(
                                          ref: refresh,
                                          position: positionCreate,
                                          idfoko: idfoko,
                                          context: context);
                                    });
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  )))
                          : const SizedBox(),
                      Positioned(
                          bottom: 40,
                          child: BarFkt(
                              id: idfoko,
                              handleChange: setIdFoko,
                              handleLimit: handleLimit)),
                      Positioned(
                          bottom: 0,
                          child: BarBottom(
                            yourLocalisation: yourLocatlisation,
                            showAchieve: handleAchieve,
                            showInachieve: handleInachieve,
                            showVoisin: handleVoisin,
                            handleColor: setColor,
                          ))
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        gradient:
                            LinearGradient(begin: Alignment.topCenter, colors: [
                      Colors.green[900] as Color,
                      Colors.green[800] as Color,
                      Colors.green[400] as Color
                    ])),
                    child: const Center(),
                  );
                }
              }),
    );
  }
}
