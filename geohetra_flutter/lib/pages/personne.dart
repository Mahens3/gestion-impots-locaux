import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/models/personne.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geohetra/database/database.dart';


class DropdownOption {
  final List<dynamic> options;
  List<DropdownMenuItem<String>> dropdown = [];

  DropdownOption({required this.options}) {
    dropDownItems();
  }

  void dropDownItems() {
    dropdown.clear();
    for (var i = 0; i < options.length; i++) {
      dropdown.add(DropdownMenuItem(
          value: options[i].toString(), child: Text(options[i].toString())));
    }
  }
}

class FormPersonne extends StatefulWidget {
  final int numcons;
  final Personne? personne;
  final Function refresh;
  
  const FormPersonne({
    Key? key,
    this.personne,
    required this.refresh,
    required this.numcons,
  }) : super(key: key);

  @override
  State<FormPersonne> createState() => _FormPersonneState();
}

class _FormPersonneState extends State<FormPersonne> {
  Personne? personne;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  // Couleurs cohérentes
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  late DropdownOption profOption = DropdownOption(options: []);
  late DropdownOption lieuOption = DropdownOption(options: []);
  late Map<String, dynamic> options = {};
  late Map<String, dynamic> items = {};

  late String sexe;
  late String profession;
  late String lieu;
  late String selectedLieu;
  late TextEditingController age;
  late TextEditingController customProfession;
  late TextEditingController customLieu;
  late FocusNode ageFocus;
  late FocusNode customProfessionFocus;
  late FocusNode customLieuFocus;
  bool showCustomProfession = false;
  bool showCustomLieu = false;

  @override
  void initState() {
    super.initState();
    personne = widget.personne;
    
    sexe = personne?.sexe ?? "Homme";
    profession = personne?.profession ?? "";
    lieu = personne?.lieu ?? "";
    selectedLieu = getType();
    
    age = TextEditingController(text: personne?.age.toString() ?? "");
    customProfession = TextEditingController();
    customLieu = TextEditingController();
    ageFocus = FocusNode();
    customProfessionFocus = FocusNode();
    customLieuFocus = FocusNode();
    
    getParametre();
  }

  @override
  void dispose() {
    age.dispose();
    customProfession.dispose();
    customLieu.dispose();
    ageFocus.dispose();
    customProfessionFocus.dispose();
    customLieuFocus.dispose();
    super.dispose();
  }

  String getType() {
    if (widget.personne != null) {
      var prof = widget.personne!.profession;
      if (prof.contains("primaire")) return "primaire";
      if (prof.contains("secondaire")) return "secondaire";
      if (prof.contains("lycée")) return "lycée";
    }
    return "";
  }

  void getParametre() async {
    var root = await getApplicationSupportDirectory();
    var file = File(root.path + "/parampers.json");
    bool exist = await file.exists();
    
    if (!exist) {
      var data = {
        "profession": [
          "Aucun",
          "Elève primaire",
          "Elève secondaire",
          "Elève au lycée",
          "Etudiant(e)",
          "Docteur",
          "Menagère",
          "Chauffeur",
          "Instituteur(trice)",
          "Cultivateur(trice)",
          "Vendeur(se)",
          "Menusier",
          "Charpentier",
        ],
        "primaire": [
          "AMJ",
          "Bambins",
          "ESPA",
          "Ecole saint Vincent de Paul",
          "EPP Alatsinainy",
          "EPP Soamanandray",
          "EPP Teteza",
          "EPP Ankondromalaza",
          "EPP Atsonga",
          "EPP Ambalamahasoa Sud",
          "EPP Ampanaovantsavony",
          "EPP Avaramanda",
          "EPP Mandamako",
          "EPP Teloambinifolo",
          "EPP Alatsinainy Fonenantsoa",
          "EPP Ambalamahasoa Nord",
          "EPP Tsaranoro",
          "EPP Maroparasy",
          "EPP Sahamasy",
          "EPP Vatofotsy",
          "EPP Vondrokely",
          "EPP Ambohimadera",
          "EPP Ambohimahasoa Namongo",
        ],
        "secondaire": [
          "ESPA",
          "AMJ",
          "CEG Ambohijafy",
          "CEG Tsaranoro",
          "Lovasoa",
          "Ecole saint Vincent de Paul"
        ],
        "lycée": [
          "Joel Sylvain",
          "LTP Teloambinifolo",
          "FJKM Lovasoa",
          "Anne Marie Javouhey",
          "Saint Joseph",
          "Saint Jean",
          "FANILO",
          "L PRIM",
          "Les Lisérons"
        ],
      };

      file = await file.writeAsString(json.encode(data));
      extract(file);
    } else {
      extract(file);
    }
  }

  Map<String, dynamic> handleParam(Map<String, dynamic> data) {
    List<dynamic> profession = List.from(data["profession"]);
    profession.add("Autre");

    List<dynamic> lycee = List.from(data["lycée"]);
    lycee.add("Autre");

    List<dynamic> secondaire = List.from(data["secondaire"]);
    secondaire.add("Autre");

    List<dynamic> primaire = List.from(data["primaire"]);
    primaire.add("Autre");

    return {
      "profession": profession,
      "lycée": lycee,
      "secondaire": secondaire,
      "primaire": primaire
    };
  }

  void saveFile(Map<String, dynamic> data) async {
    var root = await getApplicationSupportDirectory();
    var file = File(root.path + "/parampers.json");
    await file.writeAsString(json.encode(data), flush: true);
  }

  void extract(File file) async {
    var content = await file.readAsString();
    var content1 = json.decode(content);
    var content2 = json.decode(content);
    
    setState(() {
      items = content1;
      options = handleParam(content2);
      
      var opt = options["profession"];
      profession = widget.personne?.profession ?? opt[0];
      profOption = DropdownOption(options: opt);
      
      if (selectedLieu == "") {
        opt = options["primaire"];
      } else {
        opt = options[selectedLieu];
      }
      lieu = widget.personne?.lieu ?? opt[0];
      lieuOption = DropdownOption(options: opt);
    });
  }

  Personne getPersonne() {
    // Si "Autre" est sélectionné, utiliser la profession personnalisée
    String finalProfession = profession == "Autre" && customProfession.text.isNotEmpty
        ? customProfession.text.trim()
        : profession;
    
    String finalLieu = lieu == "Autre" && customLieu.text.isNotEmpty
        ? customLieu.text.trim()
        : lieu;
    
    Personne personne = Personne(
      sexe: sexe,
      profession: finalProfession,
      lieu: finalProfession.contains("Elève") ? finalLieu : "",
    );
    
    Map<String, dynamic> liste = Map.from(items);

    if (selectedLieu != "") {
      List<dynamic> list = List.from(liste[selectedLieu]);
      if (!list.contains(finalLieu) && finalLieu.isNotEmpty) {
        list.add(finalLieu);
        liste[selectedLieu] = list;
      }
    }

    List<dynamic> list = List.from(liste["profession"]);
    if (!list.contains(finalProfession) && selectedLieu == "" && finalProfession.isNotEmpty) {
      list.add(finalProfession);
      liste["profession"] = list;
    }
    
    saveFile(liste);
    
    try {
      personne.age = double.parse(age.text);
    } catch (e) {}
    
    return personne;
  }

  Future<void> handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (age.text.trim().isEmpty) {
      ageFocus.requestFocus();
      _showSnackBar("L'âge est obligatoire", isError: true);
      return;
    }

    if (profession == "Autre" && customProfession.text.trim().isEmpty) {
      customProfessionFocus.requestFocus();
      _showSnackBar("Veuillez préciser la profession", isError: true);
      return;
    }

    if (lieu == "Autre" && profession.contains("Elève") && customLieu.text.trim().isEmpty) {
      customLieuFocus.requestFocus();
      _showSnackBar("Veuillez préciser le lieu d'étude", isError: true);
      return;
    }

    setState(() => loading = true);
    try {
      Personne personne = getPersonne();
      personne.numpers = await identity();
      personne.datetimes = now();
      personne.idcons = widget.numcons;

      await DB.instance.insertPersonne(personne);
      widget.refresh();

      if (mounted) {
        _showSnackBar('Enregistré avec succès', isError: false);
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    if (age.text.trim().isEmpty) {
      ageFocus.requestFocus();
      _showSnackBar("L'âge est obligatoire", isError: true);
      return;
    }

    if (profession == "Autre" && customProfession.text.trim().isEmpty) {
      customProfessionFocus.requestFocus();
      _showSnackBar("Veuillez préciser la profession", isError: true);
      return;
    }

    if (lieu == "Autre" && profession.contains("Elève") && customLieu.text.trim().isEmpty) {
      customLieuFocus.requestFocus();
      _showSnackBar("Veuillez préciser le lieu d'étude", isError: true);
      return;
    }

    setState(() => loading = true);
    try {
      Personne personne = getPersonne();
      personne.numpers = widget.personne!.numpers;

      await DB.instance.updatePersonne(personne);
      widget.refresh();

      if (mounted) {
        _showSnackBar('Mis à jour avec succès', isError: false);
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void changeValueOf(String varToChange, String valueOf) {
    setState(() {
      switch (varToChange) {
        case "Profession":
          profession = valueOf;
          showCustomProfession = (valueOf == "Autre");
          lieuOption.dropDownItems();
          if (valueOf.contains("primaire")) {
            lieu = options["primaire"][0];
            lieuOption = DropdownOption(options: options["primaire"]);
            selectedLieu = "primaire";
            showCustomLieu = false;
          } else if (valueOf.contains("secondaire")) {
            lieu = options["secondaire"][0];
            selectedLieu = "secondaire";
            lieuOption = DropdownOption(options: options["secondaire"]);
            showCustomLieu = false;
          } else if (valueOf.contains("lycée")) {
            lieu = options["lycée"][0];
            selectedLieu = "lycée";
            lieuOption = DropdownOption(options: options["lycée"]);
            showCustomLieu = false;
          } else {
            lieu = "";
            selectedLieu = "";
            showCustomLieu = false;
          }
          break;
        case "Lieu":
          lieu = valueOf;
          showCustomLieu = (valueOf == "Autre");
          break;
      }
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required FocusNode focusNode,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType ?? TextInputType.number,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: icon != null ? Icon(icon, size: 18) : null,
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: errorColor),
          ),
          errorStyle: const TextStyle(fontSize: 10),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String, String) onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: icon != null ? Icon(icon, size: 18) : null,
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        dropdownColor: cardColor,
        isExpanded: true,
        items: items,
        onChanged: (newValue) {
          if (newValue != null) onChanged(label, newValue);
        },
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexeSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sexe",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
          ),
          RadioListTile<String>(
            value: "Homme",
            groupValue: sexe,
            title: const Text("Homme", style: TextStyle(fontSize: 13)),
            activeColor: primaryColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            onChanged: (value) {
              setState(() => sexe = value!);
            },
          ),
          RadioListTile<String>(
            value: "Femme",
            groupValue: sexe,
            title: const Text("Femme", style: TextStyle(fontSize: 13)),
            activeColor: primaryColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            onChanged: (value) {
              setState(() => sexe = value!);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    profOption.dropDownItems();
    lieuOption.dropDownItems();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          personne == null ? "Nouvelle personne" : "Modifier personne",
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(15),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildHeader("Informations personnelles", Icons.person_outline),

                    _buildSexeSelector(),

                    _buildTextField(
                      controller: age,
                      label: "Âge *",
                      focusNode: ageFocus,
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Obligatoire";
                        if (double.tryParse(v) == null) return "Âge invalide";
                        return null;
                      },
                    ),

                    if (profOption.options.isNotEmpty)
                      _buildDropdown(
                        label: "Profession",
                        value: profession,
                        items: profOption.dropdown,
                        onChanged: changeValueOf,
                        icon: Icons.work_outline,
                      ),

                    if (showCustomProfession)
                      _buildTextField(
                        controller: customProfession,
                        label: "Précisez votre profession *",
                        focusNode: customProfessionFocus,
                        icon: Icons.edit_outlined,
                        keyboardType: TextInputType.text,
                        validator: (v) {
                          if (profession == "Autre" && (v == null || v.trim().isEmpty)) {
                            return "Veuillez préciser";
                          }
                          return null;
                        },
                      ),

                    if (lieuOption.options.isNotEmpty && profession.contains("Elève"))
                      _buildDropdown(
                        label: "Lieu d'étude",
                        value: lieu,
                        items: lieuOption.dropdown,
                        onChanged: changeValueOf,
                        icon: Icons.school_outlined,
                      ),

                    if (showCustomLieu && profession.contains("Elève"))
                      _buildTextField(
                        controller: customLieu,
                        label: "Précisez le lieu d'étude *",
                        focusNode: customLieuFocus,
                        icon: Icons.location_on_outlined,
                        keyboardType: TextInputType.text,
                        validator: (v) {
                          if (lieu == "Autre" && profession.contains("Elève") && (v == null || v.trim().isEmpty)) {
                            return "Veuillez préciser";
                          }
                          return null;
                        },
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : (personne == null ? handleSave : handleUpdate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: textSecondaryColor,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          personne == null ? "Enregistrer" : "Mettre à jour",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}