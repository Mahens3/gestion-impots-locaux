import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geohetra/api/server.dart';
import 'package:geohetra/database/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Login extends StatefulWidget {
  final bool logged;
  final Function handleLogged;
  
  const Login({
    Key? key,
    required this.logged,
    required this.handleLogged,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController user = TextEditingController();
  late TextEditingController password = TextEditingController();
  late TextEditingController ctrl = TextEditingController();
  
  late bool authentificate = true;
  late bool errorPass = false;
  late bool errorPhone = false;
  late bool isLoading = false;
  late bool showPassword = false;
  late bool showModal = false;
  
  late Map<String, dynamic> config = {};

  @override
  void initState() {
    super.initState();
    checkFkt();
    checkPermission();
    
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          checkSession();
        });
      }
    });
  }

  @override
  void dispose() {
    user.dispose();
    password.dispose();
    ctrl.dispose();
    super.dispose();
  }

  void checkFkt() async {
    var fkts = await DB.instance.queryBuilder("SELECT * FROM fokontany");
    if (fkts.isEmpty) {
      await DB.instance.addFkt();
    }
  }

  void checkPermission() async {
    await Permission.storage.request();
    await Permission.location.request();
    await Permission.manageExternalStorage.request();
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

  Future<void> handleParametreFile() async {
    var root = await getApplicationSupportDirectory();
    var file = File('${root.path}/settings.json');

    try {
      if (!await file.exists()) {
        await file.create(recursive: true);
        var data = {
          "reset": true,
          // "server": "http://192.168.1.102:8000",
          "server": "https://athletic-inspiration-production-c83e.up.railway.app",
          "color": {"inachieve": 6, "achieve": 2, "voisin": 9}
        };
        await file.writeAsString(json.encode(data));
      }
    } catch (e) {
      debugPrint("❌ Erreur création settings: $e");
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
    var file = File('${root.path}/settings.json');
    var cfg = config;
    cfg["server"] = ctrl.text;
    
    await file.writeAsString(json.encode(cfg));
    
    setState(() {
      config = cfg;
      showModal = false;
      isLoading = false;
      errorPhone = false;
    });
    
    authentification();
  }

  void authentification() async {
    await handleParametreFile();
    
    setState(() {
      isLoading = true;
      errorPhone = false;
      errorPass = false;
    });

    var phone = await DB.instance.queryBuilder(
        "SELECT * FROM user WHERE phone='${user.text}'");
        
    if (phone.isNotEmpty) {
      setState(() {
        errorPhone = false;
        isLoading = false;
      });
      
      var result = await DB.instance.queryBuilder(
          "SELECT * FROM user WHERE phone='${user.text}' AND mdp='${password.text}'");
          
      if (result.isNotEmpty) {
        await DB.instance.queryUpdate("UPDATE user SET active=1");
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil("/map", (route) => false);
        }
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
      Map<String, bool> result = await HttpServer.getAgent(
        phone: user.text,
        password: password.text,
      );
      
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
      debugPrint("❌ Erreur getAgent: $e");
      setState(() {
        showModal = true;
        isLoading = false;
      });
    }
  }

  Widget _buildServerModal() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Serveur introuvable",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    labelText: "URL du serveur",
                    prefixIcon: Icon(Icons.dns, color: Color(0xFF1E40AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : setNewParametre,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Réessayer",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E40AF),
              Color(0xFF1E3A8A),
            ],
          ),
        ),
        child: authentificate
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 60),
                            // Brand
                            const Text(
                              "Geohetra",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Géomatique et Impôt",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 60),
                            // Login Card
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Connexion",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Identifiant
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: errorPhone 
                                            ? const Color(0xFFEF4444) 
                                            : Colors.grey[300]!,
                                        width: errorPhone ? 2 : 1,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: user,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1E293B),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Identifiant",
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 15,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: errorPhone 
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF1E40AF),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (errorPhone) ...[
                                    const SizedBox(height: 8),
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 16,
                                          color: Color(0xFFEF4444),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Utilisateur inexistant",
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  // Mot de passe
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: errorPass 
                                            ? const Color(0xFFEF4444) 
                                            : Colors.grey[300]!,
                                        width: errorPass ? 2 : 1,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: password,
                                      obscureText: !showPassword,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1E293B),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Mot de passe",
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 15,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: errorPass 
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF1E40AF),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            showPassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              showPassword = !showPassword;
                                            });
                                          },
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (errorPass) ...[
                                    const SizedBox(height: 8),
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 16,
                                          color: Color(0xFFEF4444),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Mot de passe incorrect",
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 32),
                                  // Login Button
                                  ElevatedButton(
                                    onPressed: isLoading ? null : authentification,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E40AF),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      disabledBackgroundColor: const Color(0xFF1E40AF).withOpacity(0.6),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            "Se connecter",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Footer
                            Text(
                              "© 2025 Geohetra",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showModal) _buildServerModal(),
                ],
              ),
      ),
    );
  }
}