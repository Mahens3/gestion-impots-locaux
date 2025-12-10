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
  late bool dismissed = true;
  late String message = "Envoi des données";
  late bool logged = false;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen(showConnectivitySnackBar);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void handleLogged() {
    setState(() {
      logged = true;
    });
  }

  Future<void> showConnectivitySnackBar(ConnectivityResult result) async {
    if (logged) {
      if (result != ConnectivityResult.none) {
        setState(() {
          dismissed = true;
          message = "Envoi des données";
        });
        Utils.showEstablished(context, "Serveur connecté", dismissed);
      } else {
        Utils.showError(context, message: "Serveur déconnecté");
      }
    }
  }

  Future<void> send() async {
    var phone = await DB.instance.getUser();
    debugPrint("📱 Utilisateur actuel : $phone");

    try {
      var serverUrl = await getServer();
      debugPrint("🌍 Serveur détecté : $serverUrl");
    } catch (e) {
      debugPrint("🚨 Erreur lors de la lecture du serveur : $e");
    }

    var connectivity = await HttpServer.checkConnectivity(phone);
    
    if (connectivity["connect"] == true) {
      setState(() => isSending = true);

      HttpServer server = HttpServer(phone: phone, date: connectivity);

      try {
        await server.send();
        setState(() {
          isSending = false;
          dismissed = false;
        });
        if (mounted) {
          Utils.showFinished(context);
        }
      } catch (e) {
        debugPrint("❌ Erreur lors de l'envoi : $e");
        setState(() => isSending = false);
        if (mounted) {
          Utils.showError(context, message: 'Erreur lors de l\'envoi des données');
        }
      }
    } else {
      debugPrint("❌ Serveur inaccessible");
      if (mounted) {
        Utils.showError(context, message: 'Serveur introuvable ou non connecté');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: "Geohetra",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Couleurs principales cohérentes avec le web
          primaryColor: const Color(0xFF1E40AF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E40AF),
            primary: const Color(0xFF1E40AF),
            secondary: const Color(0xFF10B981),
          ),
          // AppBar moderne
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E40AF),
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Boutons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Input fields
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E40AF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          // Cards
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Font
          fontFamily: 'Roboto',
        ),
        initialRoute: "/",
        routes: {
          "/export": (context) => const Exportation(),
          "/map": (context) => OfflineMap(
                handleSend: send,
                isSending: isSending,
              ),
          "/login": (context) => Login(
                logged: logged,
                handleLogged: handleLogged,
              ),
          "/setting": (context) => const Parametre(),
        },
        home: logged
            ? OfflineMap(
                handleSend: send,
                isSending: isSending,
              )
            : Login(
                logged: logged,
                handleLogged: handleLogged,
              ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale("fr"),
        ],
      ),
    );
  }
}