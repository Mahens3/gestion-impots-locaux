import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/components/checkbox.dart';
import 'package:geohetra/models/logement.dart';
import '../database/database.dart';
import "../data/logement.dart" as data;


class FormLogement extends StatefulWidget {
  final Logement? logement;
  final Function? refresh;
  final int numcons;
  
  const FormLogement({
    Key? key,
    this.logement,
    this.refresh,
    required this.numcons,
  }) : super(key: key);

  @override
  State<FormLogement> createState() => _FormLogementState();
}

class _FormLogementState extends State<FormLogement> {
  Logement? logement;
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

  // Variables d'état
  late String statut;
  late String typelog;
  late String typeoccup;
  late String niveau;
  late String? lien;
  late String confort;

  // Controllers
  late TextEditingController declarant;
  late TextEditingController nbrres;
  late TextEditingController valrec;
  late TextEditingController nbrpp;
  late TextEditingController nbrps;
  late TextEditingController stpp;
  late TextEditingController stps;
  late TextEditingController phone;
  late TextEditingController vlmeprop;
  late TextEditingController vve;
  late TextEditingController lm;
  late TextEditingController vlmeoc;

  // Focus nodes
  late FocusNode declarantFocus;
  late FocusNode nbrresFocus;
  late FocusNode lmFocus;
  late FocusNode nbrppFocus;
  late FocusNode stppFocus;
  late FocusNode phoneFocus;

  @override
  void initState() {
    super.initState();
    logement = widget.logement;

    statut = logement?.statut ?? data.Logement.statut[0];
    typelog = logement?.typelog ?? data.Logement.typelog[0];
    typeoccup = logement?.typeoccup ?? data.Logement.typeoccup[0];
    niveau = logement?.niveau ?? data.Logement.niveau[0];
    lien = logement?.lien ?? data.Logement.lien[0];
    confort = logement?.confort ?? "";

    declarant = TextEditingController(text: logement?.declarant ?? "");
    nbrres = TextEditingController(text: logement?.nbrres.toString() ?? "0");
    valrec = TextEditingController(text: logement?.valrec.toString() ?? "0");
    nbrpp = TextEditingController(text: logement?.nbrpp.toString() ?? "0");
    nbrps = TextEditingController(text: logement?.nbrps.toString() ?? "0");
    stpp = TextEditingController(text: logement?.stpp.toString() ?? "0");
    stps = TextEditingController(text: logement?.stps.toString() ?? "0");
    phone = TextEditingController(text: logement?.phone ?? "");
    vlmeprop = TextEditingController(text: logement?.vlmeprop.toString() ?? "0");
    vve = TextEditingController(text: "0");
    lm = TextEditingController(text: logement?.lm.toString() ?? "0");
    vlmeoc = TextEditingController(text: logement?.vlmeoc.toString() ?? "0");

    declarantFocus = FocusNode();
    nbrresFocus = FocusNode();
    lmFocus = FocusNode();
    nbrppFocus = FocusNode();
    stppFocus = FocusNode();
    phoneFocus = FocusNode();
  }

  @override
  void dispose() {
    declarant.dispose();
    nbrres.dispose();
    valrec.dispose();
    nbrpp.dispose();
    nbrps.dispose();
    stpp.dispose();
    stps.dispose();
    phone.dispose();
    vlmeprop.dispose();
    vve.dispose();
    lm.dispose();
    vlmeoc.dispose();
    declarantFocus.dispose();
    nbrresFocus.dispose();
    lmFocus.dispose();
    nbrppFocus.dispose();
    stppFocus.dispose();
    phoneFocus.dispose();
    super.dispose();
  }

  Logement getLogement() {
    return Logement(
      nbrres: int.tryParse(nbrres.text) ?? 0,
      niveau: niveau,
      statut: statut,
      typelog: typelog,
      typeoccup: typeoccup,
      vlmeprop: 0,
      vve: 0,
      lm: int.tryParse(lm.text) ?? 0,
      vlmeoc: 0,
      confort: confort,
      phone: phone.text,
      valrec: int.tryParse(valrec.text) ?? 0,
      nbrpp: int.tryParse(nbrpp.text) ?? 0,
      stpp: double.tryParse(stpp.text) ?? 0.0,
      nbrps: int.tryParse(nbrps.text) ?? 0,
      stps: int.tryParse(stps.text) ?? 0,
      declarant: declarant.text,
      lien: lien,
      idcons: widget.numcons,
    );
  }

  Future<void> handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (declarant.text.trim().isEmpty) {
      declarantFocus.requestFocus();
      _showSnackBar("Le déclarant est obligatoire", isError: true);
      return;
    }

    setState(() => loading = true);
    try {
      Logement logement = getLogement();
      logement.datetimes = now();
      logement.numlog = await identity();

      await DB.instance.insertLogement(logement);
      if (widget.refresh != null) widget.refresh!();

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

    if (declarant.text.trim().isEmpty) {
      declarantFocus.requestFocus();
      _showSnackBar("Le déclarant est obligatoire", isError: true);
      return;
    }

    setState(() => loading = true);
    try {
      Logement logement = getLogement();
      logement.datetimes = widget.logement!.datetimes;
      logement.numlog = widget.logement!.numlog;

      await DB.instance.updateLogement(logement);
      if (widget.refresh != null) widget.refresh!();

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

  void handleConfort(String value) {
    setState(() => confort = value);
  }

  void changeValueOf(String varToChange, String valueOf) {
    setState(() {
      switch (varToChange) {
        case "Type logement":
          typelog = valueOf;
          break;
        case "Niveau":
          niveau = valueOf;
          break;
        case "Statut":
          statut = valueOf;
          break;
        case "Type occupant":
          typeoccup = valueOf;
          break;
        case "Lien par rapport au chef du logement":
          lien = valueOf;
          break;
      }
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required FocusNode focusNode,
    FocusNode? nextFocus,
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
        textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
        },
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

  @override
  Widget build(BuildContext context) {
    data.Logement.dropDownItems();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          logement == null ? "Nouveau logement" : "Modifier logement",
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
                    _buildHeader("Informations générales", Icons.home_outlined),
                    
                    _buildDropdown(
                      label: "Statut",
                      value: statut,
                      items: data.Logement.dropdownStatut,
                      onChanged: changeValueOf,
                      icon: Icons.info_outline,
                    ),

                    _buildDropdown(
                      label: "Type logement",
                      value: typelog,
                      items: data.Logement.dropdownTypelog,
                      onChanged: changeValueOf,
                      icon: Icons.apartment,
                    ),

                    _buildDropdown(
                      label: "Type occupant",
                      value: typeoccup,
                      items: data.Logement.dropdownTypeoccup,
                      onChanged: changeValueOf,
                      icon: Icons.person_outline,
                    ),

                    _buildDropdown(
                      label: "Niveau",
                      value: niveau,
                      items: data.Logement.dropdownNiveau,
                      onChanged: changeValueOf,
                      icon: Icons.layers_outlined,
                    ),

                    _buildHeader("Caractéristiques", Icons.architecture),

                    _buildTextField(
                      controller: nbrres,
                      label: "Nombre résidents",
                      focusNode: nbrresFocus,
                      nextFocus: nbrppFocus,
                      icon: Icons.people_outline,
                      validator: (v) => v != null && v.isNotEmpty && int.tryParse(v) == null ? "Nombre invalide" : null,
                    ),

                    _buildTextField(
                      controller: nbrpp,
                      label: "Nombre pièces",
                      focusNode: nbrppFocus,
                      nextFocus: stppFocus,
                      icon: Icons.meeting_room_outlined,
                      validator: (v) => v != null && v.isNotEmpty && int.tryParse(v) == null ? "Nombre invalide" : null,
                    ),

                    _buildTextField(
                      controller: stpp,
                      label: "Surface (m²)",
                      focusNode: stppFocus,
                      nextFocus: lmFocus,
                      icon: Icons.square_foot,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v != null && v.isNotEmpty && double.tryParse(v) == null ? "Nombre invalide" : null,
                    ),

                    _buildTextField(
                      controller: lm,
                      label: "Loyer (Ar)",
                      focusNode: lmFocus,
                      nextFocus: declarantFocus,
                      icon: Icons.payments_outlined,
                      validator: (v) => v != null && v.isNotEmpty && int.tryParse(v) == null ? "Nombre invalide" : null,
                    ),

                    _buildHeader("Confort", Icons.house_outlined),

                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: CheckBoxes(
                        options: data.Logement.varconfort,
                        value: confort,
                        handleChange: handleConfort,
                        title: "Équipements",
                      ),
                    ),

                    _buildHeader("Déclarant", Icons.person_pin_outlined),

                    _buildTextField(
                      controller: declarant,
                      label: "Nom déclarant *",
                      focusNode: declarantFocus,
                      nextFocus: phoneFocus,
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.name,
                      validator: (v) => v == null || v.trim().isEmpty ? "Obligatoire" : null,
                    ),

                    _buildTextField(
                      controller: phone,
                      label: "Téléphone",
                      focusNode: phoneFocus,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    _buildDropdown(
                      label: "Lien avec chef",
                      value: lien,
                      items: data.Logement.dropdownLien,
                      onChanged: changeValueOf,
                      icon: Icons.family_restroom,
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
                  onPressed: loading ? null : (logement == null ? handleSave : handleUpdate),
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
                          logement == null ? "Enregistrer" : "Mettre à jour",
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