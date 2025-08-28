import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geohetra/api/server.dart';
import 'package:geohetra/components/fade_animation.dart';
import 'package:geohetra/database/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Login extends StatefulWidget {
  final bool logged;
  final Function handleLogged;
  const Login({Key? key, required this.logged, required this.handleLogged})
      : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController user = TextEditingController();
  late TextEditingController password = TextEditingController();
  late TextEditingController ctrl = TextEditingController();
  late bool send = false;
  late bool authentificate = true;

  late bool errorPass = false;
  late bool errorPhone = false;
  late bool isLoading = false;

  late Map<String, dynamic> config = {};
  late bool showModal = false;

  _LoginState() {
    checkFkt();
    checkPermission();
    Timer(const Duration(milliseconds: 4000), () {
      setState(() {
        checkSession();
      });
    });
  }

  void checkFkt() async {
    var fkts = await DB.instance.queryBuilder("SELECT * FROM fokontany");
    if (fkts.length == 0) {
      await DB.instance.addFkt();
    }
  }

  void checkPermission() async {
    var storage = await Permission.storage.request();
    var location = await Permission.location.request();
    var external = await Permission.manageExternalStorage.request();
  }

  void checkSession() async {
    await DB.instance.verifFktOr().then((value) {
      initial();
    });
  }

  void initial() async {
    final commercial =
        await DB.instance.queryBuilder("SELECT * FROM user WHERE active=1");
    if (commercial.isNotEmpty) {
      widget.handleLogged();
    } else {
      setState(() {
        authentificate = false;
      });
    }
  }

  Widget logo() {
    return FadeAnimation(
      1,
      SizedBox(
        width: 20,
        height: 20,
        child: Image.asset("assets/logo.png"),
      ),
    );
  }

  Widget userField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Téléphone",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextField(
            controller: user,
            style: const TextStyle(
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(
                  Icons.account_box_sharp,
                  color: Colors.grey,
                ),
                hintText: "Téléphone",
                hintStyle: TextStyle(color: Colors.black38)),
          ),
        )
      ],
    );
  }

  Widget passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mot de passe",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                )
              ]),
          height: 60,
          child: TextField(
            obscureText: true,
            controller: password,
            style: const TextStyle(
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
                hintText: "Mot de passe",
                hintStyle: TextStyle(color: Colors.black38)),
          ),
        )
      ],
    );
  }

  Future handleParametreFile() async {
    var root = await getApplicationSupportDirectory();
    var file = File(root.path + "/settings.json");

    try {
      if ((await file.exists()) == false) {
        await file.create(recursive: true).then((value) async {
          var data = {
            "reset": true,
            "server": "http://192.168.1.102:8000",
            "color": {"inachieve": 6, "achieve": 2, "voisin": 9}
          };
          await file.writeAsString(json.encode(data));
        });
      }
    } catch (e) {
    } finally {
      var text = await file.readAsString();
      Map<String, dynamic> data = json.decode(text);
      setState(() {
        config = data;
        ctrl = TextEditingController(text: data["server"].toString());
      });
    }
  }

  void setNewParametre() async {
    var root = await getApplicationSupportDirectory();
    var file = File(root.path + "/settings.json");
    var cfg = config;
    cfg["server"] = ctrl.text;
    await file.writeAsString(json.encode(config)).then((value) {
      setState(() {
        config = cfg;
        showModal = false;
        isLoading = false;
        errorPhone = false;
        authentification();
      });
    });
  }

  void authentification() async {
    await handleParametreFile();
    setState(() {
      isLoading = true;
    });
    var phone = await DB.instance
        .queryBuilder("SELECT * FROM user WHERE phone='" + user.text + "'");
    if (phone.isNotEmpty) {
      setState(() {
        errorPhone = false;
        isLoading = false;
      });
      var result = await DB.instance.queryBuilder(
          "SELECT * FROM user WHERE phone='" +
              user.text +
              "' AND mdp='" +
              password.text +
              "'");
      if (result.isNotEmpty) {
        await DB.instance.queryUpdate("UPDATE user SET active=1").then((value) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil("/map", (route) => false);
        });
      } else {
        setState(() {
          errorPass = true;
          isLoading = false;
        });
      }
    } else {
      var agents = await DB.instance.queryBuilder("SELECT * FROM user");
      if (agents.isEmpty) {
        getAgent();
      } else {
        setState(() {
          errorPhone = true;
          isLoading = false;
        });
      }
    }
  }

  void getAgent() async {
    try {
      Map<String, bool> result =
          await HttpServer.getAgent(phone: user.text, password: password.text);
      setState(() {
        if (result["server"] == false) {
          errorPhone = true;
          isLoading = false;
          showModal = true;
        } else {
          if (result["agent"] == true) {
            checkSession();
          } else {
            errorPhone = true;
            isLoading = false;
          }
        }
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        showModal = true;
        isLoading = false;
      });
    }
  }

  Widget modal() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.6)),
      child: Center(
          child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width - 50,
        height: 180,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(2)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.error),
            SizedBox(
              width: 5,
            ),
            Text(
              "Serveur introuvable",
            )
          ]),
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
            child: TextField(
                cursorColor: Colors.green,
                controller: ctrl,
                decoration: const InputDecoration(border: InputBorder.none)),
          ),
          btnRetry()
        ]),
      )),
    );
  }

  Container btnLogin() {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))),
    );
    return Container(
        margin: const EdgeInsets.fromLTRB(5, 5, 0, 0),
        height: 50,
        width: MediaQuery.of(context).size.width - 80,
        child: ElevatedButton(
            style: raisedButtonStyle,
            onPressed: () {
              if (isLoading == false) {
                authentification();
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading
                    ? Container(
                        padding: const EdgeInsets.only(right: 7),
                        width: 20,
                        height: 15,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ))
                    : const SizedBox(),
                const Text("Se connecter",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            )));
  }

  Container btnRetry() {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green[900],
      padding: const EdgeInsets.symmetric(horizontal: 5),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
    );
    return Container(
        margin: const EdgeInsets.fromLTRB(5, 5, 0, 0),
        height: 40,
        width: MediaQuery.of(context).size.width - 80,
        child: ElevatedButton(
            style: raisedButtonStyle,
            onPressed: () {
              setNewParametre();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading
                    ? Container(
                        padding: const EdgeInsets.only(right: 7),
                        width: 20,
                        height: 15,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ))
                    : const SizedBox(),
                const Text("Réessayer",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.green[900] as Color,
              Colors.green[800] as Color,
              Colors.green[400] as Color
            ])),
            child: authentificate
                ? logo()
                : Stack(children: [
                    SingleChildScrollView(
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 60,
                                ),
                                FadeAnimation(
                                    1,
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(children: const [
                                        Text(
                                          "Geohetra",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 40),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Authentifiez-vous",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ]),
                                    )),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                    child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(60),
                                          topRight: Radius.circular(60))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(children: [
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Color.fromARGB(
                                                      75, 91, 211, 44),
                                                  blurRadius: 20,
                                                  offset: Offset(0, 10))
                                            ]),
                                        child: FadeAnimation(
                                            1.5,
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                FadeAnimation(
                                                    1.7,
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                        .grey[200]
                                                                    as Color)),
                                                      ),
                                                      child: TextField(
                                                        keyboardType:
                                                            TextInputType.phone,
                                                        controller: user,
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              "Identifiant",
                                                          hintStyle: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    )),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                errorPhone
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: const Text(
                                                          "Utilisateur inéxstant",
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                FadeAnimation(
                                                    1.5,
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                        .grey[200]
                                                                    as Color)),
                                                      ),
                                                      child: TextField(
                                                        keyboardType:
                                                            TextInputType
                                                                .visiblePassword,
                                                        obscureText: true,
                                                        controller: password,
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              "Mot de passe",
                                                          hintStyle: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    )),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                errorPass
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: const Text(
                                                          "Mot de passe incorrecte",
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )
                                                    : const SizedBox()
                                              ],
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      FadeAnimation(1.9, btnLogin()),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      const FadeAnimation(
                                          2,
                                          Text(
                                            "Application mobile pour le recensement fiscal de la commune urbaine Ambalavao",
                                            textAlign: TextAlign.center,
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ))
                                    ]),
                                  ),
                                ))
                              ],
                            ))),
                    showModal ? modal() : const SizedBox()
                  ])));
  }
}
