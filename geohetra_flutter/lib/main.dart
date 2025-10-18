// ignore_for_file: avoid_print

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geohetra/api/server.dart';
import 'package:geohetra/database/database.dart';
import 'package:geohetra/pages/exportation.dart';
import 'package:geohetra/pages/map.dart';
import 'package:geohetra/pages/login.dart';
import 'package:geohetra/pages/parametre.dart';
import 'package:geohetra/utils.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription subscription;
  late bool isSending = false;

  @override
  void initState() {
    super.initState();
    subscription =
        Connectivity().onConnectivityChanged.listen(showConnectivitySnackBar);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkConnectivity(BuildContext context) async {
    final result = await Connectivity().checkConnectivity();
    showConnectivitySnackBar(result);
  }

  late bool dismissed = true;
  late String message = "Envoi des données";
  late bool logged = false;

  void handleLogged() {
    setState(() {
      logged = true;
    });
  }

  Future showConnectivitySnackBar(ConnectivityResult result) async {
    if (logged == true) {
      if (result != ConnectivityResult.none) {
        setState(() {
          dismissed = true;
          message = "Envoi des données";
        });
        if (result != ConnectivityResult.none) {
          Utils.showEstablished(context, "Serveur connecté", dismissed);
        } else {
          Utils.showError(context, message: "Serveur déconnecté");
        }
      }
    }
  }

  // void send() async {
  //   var phone = await DB.instance.getUser();
  //   var connectivity = await HttpServer.checkConnectivity(phone);
  //   if (connectivity["connect"] == true) {
  //     setState(() {
  //       isSending = true;
  //     });
  //     HttpServer server = HttpServer(phone: phone, date: connectivity);
  //     await server.send().then((value) {
  //       setState(() {
  //         isSending = false;
  //         dismissed = false;
  //         Utils.showFinished(context);
  //       });
  //     });
  //   } else {
  //     Utils.showError(context);
  //   }
  // }

  void send() async {
    var phone = await DB.instance.getUser();
    print("📱 Utilisateur actuel : $phone");

    try {
      var serverUrl = await getServer();
      print("🌍 Serveur détecté : $serverUrl");
    } catch (e) {
      print("🚨 Erreur lors de la lecture du serveur : $e");
    }

    var connectivity = await HttpServer.checkConnectivity(phone);
    if (connectivity["connect"] == true) {
      setState(() => isSending = true);

      HttpServer server = HttpServer(phone: phone, date: connectivity);

      await server.send().then((_) {
        setState(() {
          isSending = false;
          dismissed = false;
        });
        Utils.showFinished(context);
      });
    } else {
      print("❌ Serveur inaccessible, impossible d'envoyer les données");
      Utils.showError(context, message: 'Serveur introuvable ou non connecté');
    }
  }

  @override
  Widget build(BuildContext context) => OverlaySupport.global(
      child: MaterialApp(
          title: "Geo hetra",
          debugShowCheckedModeBanner: false,
          initialRoute: "/",
          routes: {
            "/export": (context) => const Exportation(),
            "/map": (context) => OfflineMap(
                  handleSend: send,
                  isSending: isSending,
                ),
            "/login": (context) =>
                Login(logged: logged, handleLogged: handleLogged),
            "/setting": (context) => const Parametre(),
          },
          home: logged == true
              ? OfflineMap(
                  handleSend: send,
                  isSending: isSending,
                )
              : Login(logged: logged, handleLogged: handleLogged),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: const [Locale("fr")]));
}
