import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geohetra/api/control.dart';
import 'package:geohetra/components/fade_animation.dart';
import 'package:geohetra/components/tools.dart';
import 'package:geohetra/database/database.dart';
import 'package:geohetra/pages/about.dart';
import 'package:geohetra/pages/construction.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class OfflineMap extends StatefulWidget {
  final bool isSending;
  final Function handleSend;

  const OfflineMap({
    Key? key,
    required this.isSending,
    required this.handleSend,
  }) : super(key: key);

  @override
  OfflineMapState createState() => OfflineMapState();
}

class OfflineMapState extends State<OfflineMap> with TickerProviderStateMixin {
  double currentLatitude = -21.83083;
  double currentLongitude = 46.932005;
  LatLng center = LatLng(-21.83083, 46.932005);

  late LatLng positionCreate = LatLng(0, 0);
  late bool canCreate = false;

  late Map<String, Object?> agent = {};
  
  MapController mapController = MapController();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late bool loading = true;
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
  late bool error = false;

  late Map<String, Color> colors = {
    "achieve": const Color(0xFFEF4444),
    "inachieve": const Color(0xFFF59E0B),
    "voisin": const Color(0xFF8B5CF6),
  };

  @override
  void initState() {
    super.initState();
    localisation();
    getAgent();
    downloadCoordinates();
    launch();
  }

  void getAgent() async {
    var result = await DB.instance.queryBuilder("SELECT * FROM user WHERE active=1");
    if (result.isNotEmpty) {
      setState(() {
        agent = result.first;
      });
    }
  }

  Future launch() async {
    await controlData();
    await formatDate();
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

  void setIdFoko(int id) {
    setState(() {
      idfoko = id;
    });
    refresh(moved: true);
  }

  void setMarkerInachieve({int? idfkt, bool moved = true}) async {
    List<Marker> markercons = [];
    var constructions = await DB.instance.findConstruction(idfkt: idfkt, limit: limit);

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
                ),
              );
            } else {
              route = MaterialPageRoute(
                builder: (context) => About(
                  construction: construction,
                  refresh: refresh,
                ),
              );
            }
            Navigator.of(context).push(route);
          },
          child: Icon(
            Icons.home_outlined,
            shadows: const [Shadow(color: Colors.grey, blurRadius: 2)],
            size: 16,
            color: colors["inachieve"],
          ),
        ),
      );
      markercons.add(marker);
    }
    
    setState(() {
      markers = markercons;
      loading = false;
    });
  }

  void setMarkerAchieve(int idfkt) async {
    List<Marker> markercons = [];
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
                ),
              );
            } else {
              route = MaterialPageRoute(
                builder: (context) => About(
                  construction: construction,
                  refresh: refresh,
                ),
              );
            }
            Navigator.of(context).push(route);
          },
          child: Icon(
            Icons.home_outlined,
            shadows: const [Shadow(color: Colors.grey, blurRadius: 2)],
            size: 16,
            color: colors["achieve"],
          ),
        ),
      );
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
          ),
        ),
      );
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
        color: Color(0xFFF59E0B),
      ),
    );
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
      if (fkt.isNotEmpty) {
        if (idfoko == 0) {
          var idValue = fkt.first["idfoko"];
          id = (idValue is int) ? idValue : int.tryParse(idValue.toString()) ?? 0;
        } else {
          id = idfoko;
        }
      }
    } catch (e) {
      debugPrint("Erreur récupération id: $e");
    } finally {
      if (id > 0) {
        setMarkerInachieve(idfkt: id, moved: moved);
        setMarkerAchieve(id);
        setMarkerVoisin(id);
      }

      try {
        var ta = await DB.instance.getTache();
        setState(() {
          idfoko = id;
          tache = ta;
        });
      } catch (e) {
        debugPrint("Erreur getTache: $e");
      }
    }
  }

  Future<void> downloadCoordinates() async {
    debugPrint("DÉBUT downloadCoordinates()");

    var root = await getApplicationSupportDirectory();
    var file = File('${root.path}/settings.json');

    if (!await file.exists()) {
      debugPrint("Fichier settings.json introuvable");
      return;
    }

    var text = await file.readAsString();
    var agent = await DB.instance.queryBuilder("SELECT idagt FROM user WHERE active=1");

    if (agent.isEmpty) {
      debugPrint("Aucun agent actif trouvé");
      return;
    }

    var construction = await DB.instance.queryBuilder(
      "SELECT idcoord FROM construction WHERE idagt=${agent.first["idagt"]} ORDER BY idcoord",
    );

    var idcoord = "0";
    if (construction.isNotEmpty) {
      idcoord = construction.last["idcoord"].toString();
    }

    Map<String, dynamic> data = json.decode(text);

    setState(() {
      loading = true;
      str = "0%";
      stage = "Téléchargement des coordonnées...";
    });

    try {
      final response = await http.post(
        Uri.parse("${data["server"]}/api/coordonnees/get"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "idagt": agent.first["idagt"],
          "idcoord": idcoord,
        }),
      );

      List<dynamic> coordinates = [];
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        coordinates = decoded["data"] ?? [];
        debugPrint("🔍 Coordonnées: ${coordinates.length} éléments");
      }

      if (coordinates.isEmpty) {
        debugPrint("ℹ️ Aucune nouvelle coordonnée");
        setState(() => str = "Aucune nouvelle coordonnée");
        return;
      }

      for (var i = 0; i < coordinates.length; i++) {
        Map<String, dynamic> coords = coordinates[i] as Map<String, dynamic>;

        final lat = coords["lat"] ?? 0.0;
        final lng = coords["lng"] ?? 0.0;
        final idagt = coords["idagt"] ?? 0;
        final typequart = coords["typequart"] ?? '';
        final rang = coords["rang"] ?? 0;
        final idfoko = coords["idfoko"] ?? 0;
        final id = coords["id"] ?? 0;

        String query = "($lat, $lng, $idagt, '$typequart', $rang, $idfoko, $id)";

        try {
          await DB.instance.rawQuery(query);
        } catch (e) {
          debugPrint("⚠️ Erreur insertion: $e");
        }

        setState(() {
          var pourcent = ((i + 1) * 100) / coordinates.length;
          str = "${pourcent.round()}% (${i + 1}/${coordinates.length})";
        });

        await Future.delayed(const Duration(milliseconds: 50));
      }

      setState(() {
        str = "100% - Terminé ✅";
      });
    } catch (e) {
      debugPrint("❌ Erreur downloadCoordinates: $e");
      setState(() {
        str = "Échec du téléchargement ❌";
        error = true;
      });
    } finally {
      setState(() {
        loading = false;
      });
      refresh();
    }
  }

  void logout() async {
    await DB.instance.queryUpdate("UPDATE user SET active=0");
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    }
  }

  Widget _buildDrawer() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          "assets/logo.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Geohetra",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.group, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Equipe ${agent["numequip"] ?? ''} (${agent["pseudo"] ?? ''})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Construction: ${tache["tache"]} (${tache["reste"]})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Progression: ${tache["pourcentage"]}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Quota: ${tache["quota"]}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMenuItem(
                    icon: Icons.wifi,
                    title: "Envoyer données",
                    subtitle: "Synchroniser avec le serveur",
                    onTap: () {
                      _key.currentState!.closeDrawer();
                      widget.handleSend();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.file_download,
                    title: "Exporter données",
                    subtitle: "Exporter en fichier Excel",
                    onTap: () {
                      Navigator.of(context).pushNamed("/export");
                      _key.currentState!.closeDrawer();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: "Paramètres",
                    subtitle: "Configuration de l'application",
                    onTap: () {
                      Navigator.pushNamed(context, "/setting");
                    },
                  ),
                  const Divider(height: 32),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: "Se déconnecter",
                    subtitle: "",
                    color: const Color(0xFFEF4444),
                    onTap: logout,
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                "© 2025 Geohetra v1.0.5",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = const Color(0xFF1E40AF),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!error) ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    Text(
                      str,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 80,
                ),
              ],
              const SizedBox(height: 32),
              Text(
                error ? "Échec de la connexion" : stage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (error) ...[
                const SizedBox(height: 8),
                Text(
                  "Impossible de se connecter au serveur",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      str = "";
                      error = false;
                    });
                    downloadCoordinates();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E40AF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    "Réessayer",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: Drawer(child: _buildDrawer()),
      body: loading
          ? _buildLoadingScreen()
          : FutureBuilder<String>(
              future: Future.value("ok"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Stack(
                    children: [
                      SimpleTransition(
                        0.2,
                        FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            onTap: (tapPosition, latlng) {
                              setState(() {
                                positionCreate = latlng;
                              });
                            },
                            rotation: 0.0,
                            interactiveFlags: InteractiveFlag.all,
                            center: LatLng(-21.82762, 46.94021),
                            maxZoom: 19,
                            minZoom: 3,
                            zoom: 14,
                            plugins: [MarkerClusterPlugin()],
                          ),
                          layers: [
                            TileLayerOptions(
                              urlTemplate: "https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}",
                              subdomains: ['mt0', 'mt1', 'mt2'],
                              maxZoom: 20,
                              backgroundColor: Colors.grey,
                              errorImage: const AssetImage("assets/grey.png"),
                              userAgentPackageName: 'com.example.geohetra',
                            ),
                            MarkerLayerOptions(
                              markers: [
                                Marker(
                                  width: 10,
                                  height: 10,
                                  point: gps,
                                  builder: (BuildContext ctx) => const GPS(),
                                )
                              ],
                            ),
                            showInachieve
                                ? MarkerClusterLayerOptions(
                                    maxClusterRadius: 120,
                                    disableClusteringAtZoom: 16,
                                    size: const Size(30, 30),
                                    anchor: AnchorPos.align(AnchorAlign.center),
                                    fitBoundsOptions: const FitBoundsOptions(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    builder: (context, markers) {
                                      return FloatingActionButton(
                                        heroTag: null,
                                        backgroundColor: const Color(0xFF3B82F6),
                                        child: Text(markers.length.toString()),
                                        onPressed: null,
                                      );
                                    },
                                    markers: markers,
                                  )
                                : MarkerLayerOptions(),
                            canCreate
                                ? MarkerLayerOptions(markers: [createMark()])
                                : MarkerLayerOptions(),
                            showAchieve
                                ? MarkerClusterLayerOptions(
                                    maxClusterRadius: 120,
                                    disableClusteringAtZoom: 17,
                                    size: const Size(30, 30),
                                    anchor: AnchorPos.align(AnchorAlign.center),
                                    fitBoundsOptions: const FitBoundsOptions(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    builder: (context, markers) {
                                      return FloatingActionButton(
                                        heroTag: null,
                                        backgroundColor: const Color(0xFF3B82F6),
                                        child: Text(markers.length.toString()),
                                        onPressed: null,
                                      );
                                    },
                                    markers: markerAchieve,
                                  )
                                : MarkerLayerOptions(),
                            showVoisin
                                ? MarkerClusterLayerOptions(
                                    maxClusterRadius: 120,
                                    disableClusteringAtZoom: 17,
                                    size: const Size(30, 30),
                                    anchor: AnchorPos.align(AnchorAlign.center),
                                    fitBoundsOptions: const FitBoundsOptions(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    builder: (context, markers) {
                                      return FloatingActionButton(
                                        heroTag: null,
                                        backgroundColor: const Color(0xFF3B82F6),
                                        child: Text(markers.length.toString()),
                                        onPressed: null,
                                      );
                                    },
                                    markers: markerVoisin,
                                  )
                                : MarkerLayerOptions()
                          ],
                        ),
                      ),
                      // Menu button
                      Positioned(
                        top: 48,
                        left: 16,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              if (!widget.isSending) {
                                _key.currentState!.openDrawer();
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: widget.isSending
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF1E40AF),
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.menu,
                                      color: Color(0xFF1E40AF),
                                      size: 24,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      // Create marker button
                      Positioned(
                        top: 116,
                        left: 16,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                canCreate = !canCreate;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: canCreate
                                    ? const Color(0xFF1E40AF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: canCreate ? Colors.white : const Color(0xFF1E40AF),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Validate button
                      if (canCreate)
                        Positioned(
                          top: 184,
                          left: 16,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                FormConstruction.createConstruction(
                                  ref: refresh,
                                  position: positionCreate,
                                  idfoko: idfoko,
                                  context: context,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Fokontany bar
                      Positioned(
                        bottom: 40,
                        child: BarFkt(
                          id: idfoko,
                          handleChange: setIdFoko,
                          handleLimit: handleLimit,
                        ),
                      ),
                      // Bottom bar
                      Positioned(
                        bottom: 0,
                        child: BarBottom(
                          yourLocalisation: yourLocatlisation,
                          showAchieve: handleAchieve,
                          showInachieve: handleInachieve,
                          showVoisin: handleVoisin,
                          handleColor: setColor,
                        ),
                      ),
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
              },
            ),
    );
  }
}

class GPS extends StatelessWidget {
  const GPS({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}