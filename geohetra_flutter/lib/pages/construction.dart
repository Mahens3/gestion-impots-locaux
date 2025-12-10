import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/pages/about.dart';
import '../database/database.dart';
import '../models/construction.dart';
import "../data/construction.dart" as data;
import 'package:latlong2/latlong.dart';

class FormConstruction extends StatefulWidget {
  final Construction? construction;
  final Function refresh;
  final LatLng? latLng;
  final bool create;
  final bool next;

  static void createConstruction({
    required Function ref,
    required LatLng position,
    required int idfoko,
    required BuildContext context,
  }) {
    Construction construction = Construction(
      lat: position.latitude,
      lng: position.longitude,
      idfoko: idfoko,
    );
    var route = MaterialPageRoute(
      builder: ((context) => FormConstruction(
        refresh: ref,
        next: true,
        construction: construction,
        create: true,
      )),
    );
    Navigator.of(context).push(route);
  }

  const FormConstruction({
    Key? key,
    this.construction,
    this.latLng,
    this.create = false,
    required this.refresh,
    required this.next,
  }) : super(key: key);

  @override
  State<FormConstruction> createState() => _FormConstructionState();
}

class _FormConstructionState extends State<FormConstruction> {
  Construction? construction;
  bool next = false;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  
  // Couleurs
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color errorColor = Color(0xFFD32F2F);
  // static const Color suceesColor = Color(0xFF388E3C);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  late List<Map<String, Object?>> fokontany = [];
  late List<DropdownMenuItem<String>> dropdown = [];

  // Variables d'état
  late String? mur;
  late String? fktorigin;
  late String? ossature;
  late String? fondation;
  late String? toiture;
  late String? typehab;
  late String? access;
  late String? etatmur;
  late String? typecons;
  late String? wc;

  // Controllers
  late TextEditingController anconst;
  late TextEditingController adress;
  late TextEditingController boriboritany;
  late TextEditingController nbrniv;
  late TextEditingController nbrhab;
  late TextEditingController nbrcom;
  late TextEditingController nbrbur;
  late TextEditingController nbrprop;
  late TextEditingController nbrocgrat;
  late TextEditingController nbrloc;
  late TextEditingController surface;

  // Focus nodes
  late FocusNode nivFocus;
  late FocusNode habFocus;
  late FocusNode comFocus;
  late FocusNode burFocus;
  late FocusNode propFocus;
  late FocusNode ocgratFocus;
  late FocusNode locFocus;
  late FocusNode surfaceFocus;

  @override
  void initState() {
    super.initState();
    construction = widget.construction;
    next = widget.next;

    // Initialisation des valeurs
    mur = next ? data.Construction.mur[0] : construction!.mur;
    fktorigin = "";
    ossature = !next ? construction!.ossature : data.Construction.ossature[0];
    fondation = !next ? construction!.fondation : data.Construction.fondation[0];
    toiture = !next ? construction!.toiture : data.Construction.toiture[0];
    typehab = !next ? construction!.typehab : data.Construction.typehab[0];
    access = !next ? construction!.access : data.Construction.access[0];
    etatmur = !next ? construction!.etatmur : data.Construction.etatmur[0];
    typecons = !next ? construction!.typecons : data.Construction.typecons[0];
    wc = !next ? construction!.wc : "oui";

    // Controllers
    anconst = TextEditingController(text: !next ? construction!.anconst : "0");
    adress = TextEditingController(text: construction?.adress ?? "");
    boriboritany = TextEditingController(text: construction?.boriboritany ?? "");
    nbrniv = TextEditingController(text: !next ? construction!.nbrniv.toString() : "1");
    nbrhab = TextEditingController(text: !next ? construction!.nbrhab.toString() : "0");
    nbrcom = TextEditingController(text: !next ? construction!.nbrcom.toString() : "0");
    nbrbur = TextEditingController(text: !next ? construction!.nbrbur.toString() : "0");
    nbrprop = TextEditingController(text: !next ? construction!.nbrprop.toString() : "0");
    nbrocgrat = TextEditingController(text: !next ? construction!.nbrocgrat.toString() : "0");
    nbrloc = TextEditingController(text: !next ? construction!.nbrloc.toString() : "0");
    surface = TextEditingController(text: !next ? construction!.surface.toString() : "0");

    // Focus nodes
    nivFocus = FocusNode();
    habFocus = FocusNode();
    comFocus = FocusNode();
    burFocus = FocusNode();
    propFocus = FocusNode();
    ocgratFocus = FocusNode();
    locFocus = FocusNode();
    surfaceFocus = FocusNode();

    getFokontany();
  }

  @override
  void dispose() {
    anconst.dispose();
    adress.dispose();
    boriboritany.dispose();
    nbrniv.dispose();
    nbrhab.dispose();
    nbrcom.dispose();
    nbrbur.dispose();
    nbrprop.dispose();
    nbrocgrat.dispose();
    nbrloc.dispose();
    surface.dispose();
    nivFocus.dispose();
    habFocus.dispose();
    comFocus.dispose();
    burFocus.dispose();
    propFocus.dispose();
    ocgratFocus.dispose();
    locFocus.dispose();
    surfaceFocus.dispose();
    super.dispose();
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

  void clearDropdown() {
    dropdown.clear();
    for (var item in fokontany) {
      dropdown.add(DropdownMenuItem(
        value: item["id"].toString(),
        child: Text(item["nomfokontany"].toString()),
      ));
    }
  }

  Construction initConstruct() {
    return Construction(
      id: widget.construction?.id,
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
      lat: widget.latLng?.latitude ?? widget.construction!.lat,
      lng: widget.latLng?.longitude ?? widget.construction!.lng,
    );
  }

  bool controlField() {
    if (!_formKey.currentState!.validate()) return false;
    
    if (nbrbur.text.isEmpty) {
      burFocus.requestFocus();
      _showSnackBar("Nombre de logement bureau requis", isError: true);
      return false;
    }
    if (nbrcom.text.isEmpty) {
      comFocus.requestFocus();
      _showSnackBar("Nombre de logement commerce requis", isError: true);
      return false;
    }
    if (nbrhab.text.isEmpty) {
      habFocus.requestFocus();
      _showSnackBar("Nombre de logement habitation requis", isError: true);
      return false;
    }
    if (nbrloc.text.isEmpty) {
      locFocus.requestFocus();
      _showSnackBar("Nombre de logement à louer requis", isError: true);
      return false;
    }
    if (nbrniv.text.isEmpty) {
      nivFocus.requestFocus();
      _showSnackBar("Nombre de niveau requis", isError: true);
      return false;
    }
    if (nbrocgrat.text.isEmpty) {
      ocgratFocus.requestFocus();
      _showSnackBar("Nombre occupant gratuit requis", isError: true);
      return false;
    }
    if (nbrprop.text.isEmpty) {
      propFocus.requestFocus();
      _showSnackBar("Nombre propriétaire requis", isError: true);
      return false;
    }
    if (surface.text.isEmpty) {
      surfaceFocus.requestFocus();
      _showSnackBar("Surface requise", isError: true);
      return false;
    }
    return true;
  }

  Future<void> handleUpdate() async {
    if (!controlField()) return;

    setState(() => loading = true);
    try {
      Construction construction = initConstruct();
      construction.numcons = widget.construction!.numcons;
      construction.image = widget.construction!.image;
      construction.datetimes = widget.construction!.datetimes;
      construction.idfoko = widget.construction!.idfoko;
      construction.idagt = widget.construction!.idagt;

      await DB.instance.updateConstruction(construction);
      widget.refresh(construction);

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

  Future<void> nextStep() async {
    if (!controlField()) return;

    setState(() => loading = true);
    try {
      Construction construction = initConstruct();
      final id = await identity();
      construction.numcons = id;
      construction.datetimes = now();
      construction.idfoko = widget.construction!.idfoko;

      if (widget.create == true) {
        dynamic idagt = await DB.instance
            .queryBuilder("SELECT idagt FROM user WHERE active=1");
        idagt = idagt.first['idagt'];
        construction.idagt = idagt;
        int id = await DB.instance.insertConstruction(construction);
        construction.id = id;
      } else {
        construction.idagt = widget.construction!.idagt;
        await DB.instance.updateConstruction(construction);
      }

      if (mounted) {
        var route = MaterialPageRoute(
          builder: (context) => About(
            construction: construction,
            refresh: widget.refresh,
          ),
        );
        Navigator.of(context).pushReplacement(route);
        widget.refresh();
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
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
        case "Mur":
          mur = valueOf;
          break;
        case "Ossature":
          ossature = valueOf;
          break;
        case "Toiture":
          toiture = valueOf;
          break;
        case "Fondation":
          fondation = valueOf;
          break;
        case "Type":
          typehab = valueOf;
          break;
        case "Accessibilité":
          access = valueOf;
          break;
        case "Type construction":
          typecons = valueOf;
          break;
        case "Etat du mur":
          etatmur = valueOf;
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

  Widget _buildWCSelector() {
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
            "Avec WC",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
          ),
          RadioListTile<String>(
            value: "oui",
            groupValue: wc,
            title: const Text("Oui", style: TextStyle(fontSize: 13)),
            activeColor: primaryColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            onChanged: (value) => setState(() => wc = value),
          ),
          RadioListTile<String>(
            value: "non",
            groupValue: wc,
            title: const Text("Non", style: TextStyle(fontSize: 13)),
            activeColor: primaryColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            onChanged: (value) => setState(() => wc = value),
          ),
        ],
      ),
    );
  }

  Widget _buildFokontanySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: fktorigin,
        decoration: InputDecoration(
          labelText: "Fokontany",
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: const Icon(Icons.location_city, size: 18),
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
        items: dropdown,
        onChanged: (value) {
          setState(() => fktorigin = value.toString());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    data.Construction.dropDownItems();
    clearDropdown();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          "Construction",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
                    _buildHeader("Informations générales", Icons.apartment),

                    _buildDropdown(
                      label: "Type construction",
                      value: typecons,
                      items: data.Construction.dropdownTypecons,
                      onChanged: changeValueOf,
                      icon: Icons.business,
                    ),

                    _buildFokontanySelector(),

                    _buildTextField(
                      controller: adress,
                      label: "Lot",
                      focusNode: FocusNode(),
                      icon: Icons.place_outlined,
                      keyboardType: TextInputType.text,
                    ),

                    _buildTextField(
                      controller: boriboritany,
                      label: "Boriboritany",
                      focusNode: FocusNode(),
                      icon: Icons.map_outlined,
                      keyboardType: TextInputType.text,
                    ),

                    _buildHeader("Caractéristiques", Icons.construction),

                    _buildDropdown(
                      label: "Mur",
                      value: mur,
                      items: data.Construction.dropdownMur,
                      onChanged: changeValueOf,
                      icon: Icons.border_all,
                    ),

                    _buildDropdown(
                      label: "Ossature",
                      value: ossature,
                      items: data.Construction.dropdownOssature,
                      onChanged: changeValueOf,
                      icon: Icons.view_in_ar_outlined,
                    ),

                    _buildDropdown(
                      label: "Fondation",
                      value: fondation,
                      items: data.Construction.dropdownFondation,
                      onChanged: changeValueOf,
                      icon: Icons.foundation,
                    ),

                    _buildDropdown(
                      label: "Toiture",
                      value: toiture,
                      items: data.Construction.dropdownToiture,
                      onChanged: changeValueOf,
                      icon: Icons.roofing_outlined,
                    ),

                    _buildDropdown(
                      label: "Type",
                      value: typehab,
                      items: data.Construction.dropdownTypehab,
                      onChanged: changeValueOf,
                      icon: Icons.home_work_outlined,
                    ),

                    _buildDropdown(
                      label: "Accessibilité",
                      value: access,
                      items: data.Construction.dropdownAccess,
                      onChanged: changeValueOf,
                      icon: Icons.add_road,
                    ),

                    _buildDropdown(
                      label: "Etat du mur",
                      value: etatmur,
                      items: data.Construction.dropdownEtatmur,
                      onChanged: changeValueOf,
                      icon: Icons.check_circle_outline,
                    ),

                    _buildWCSelector(),

                    _buildTextField(
                      controller: anconst,
                      label: "Année de construction",
                      focusNode: FocusNode(),
                      icon: Icons.calendar_today_outlined,
                    ),

                    _buildHeader("Détails des logements", Icons.door_front_door_outlined),

                    _buildTextField(
                      controller: nbrniv,
                      label: "Nombre d'étages",
                      focusNode: nivFocus,
                      nextFocus: habFocus,
                      icon: Icons.layers_outlined,
                    ),

                    _buildTextField(
                      controller: nbrhab,
                      label: "Logements habitation",
                      focusNode: habFocus,
                      nextFocus: comFocus,
                      icon: Icons.home_outlined,
                    ),

                    _buildTextField(
                      controller: nbrcom,
                      label: "Logements commerce",
                      focusNode: comFocus,
                      nextFocus: burFocus,
                      icon: Icons.store_outlined,
                    ),

                    _buildTextField(
                      controller: nbrbur,
                      label: "Logements bureau",
                      focusNode: burFocus,
                      nextFocus: propFocus,
                      icon: Icons.business_center_outlined,
                    ),

                    _buildTextField(
                      controller: nbrprop,
                      label: "Logements propriétaire",
                      focusNode: propFocus,
                      nextFocus: locFocus,
                      icon: Icons.person_outline,
                    ),

                    _buildTextField(
                      controller: nbrloc,
                      label: "Logements à louer",
                      focusNode: locFocus,
                      nextFocus: ocgratFocus,
                      icon: Icons.vpn_key_outlined,
                    ),

                    _buildTextField(
                      controller: nbrocgrat,
                      label: "Occupants gratuits",
                      focusNode: ocgratFocus,
                      nextFocus: surfaceFocus,
                      icon: Icons.people_alt_outlined,
                    ),

                    _buildTextField(
                      controller: surface,
                      label: "Surface (m²)",
                      focusNode: surfaceFocus,
                      icon: Icons.square_foot,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  onPressed: loading ? null : (widget.next ? nextStep : handleUpdate),
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
                          widget.next ? "Suivant" : "Mettre à jour",
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