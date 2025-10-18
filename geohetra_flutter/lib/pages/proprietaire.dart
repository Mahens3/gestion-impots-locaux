import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/models/proprietaire.dart';
import 'package:geohetra/database/database.dart';
import "package:geohetra/data/proprietaire.dart" as data;
import "package:geohetra/data/colors.dart" as color;
import "package:geohetra/components/components.dart";
import 'package:geohetra/components/button.dart';

class FormProprietaire extends StatefulWidget {
  final Proprietaire? proprietaire;
  final Function? setter;
  final String? numcons;

  const FormProprietaire({
    Key? key,
    this.proprietaire,
    this.numcons,
    this.setter,
  }) : super(key: key);

  @override
  State<FormProprietaire> createState() => _FormProprietaireState();
}

class _FormProprietaireState extends State<FormProprietaire> {
  Proprietaire? proprietaire;
  String? type = "";
  late TextEditingController nom;
  late TextEditingController prenom;
  late TextEditingController adresse;
  late FocusNode nomFocus;
  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    proprietaire = widget.proprietaire;

    // Initialisation des contrôleurs avec les valeurs existantes (ou vides)
    nom = TextEditingController(text: proprietaire?.nomprop ?? "");
    prenom = TextEditingController(text: proprietaire?.prenomprop ?? "");
    adresse = TextEditingController(text: proprietaire?.adress ?? "");
    nomFocus = FocusNode();

    // Récupération du type si présent
    type = proprietaire?.typeprop ?? "";
  }

  @override
  void dispose() {
    nom.dispose();
    prenom.dispose();
    adresse.dispose();
    nomFocus.dispose();
    super.dispose();
  }

  /// Construit un objet Proprietaire à partir des champs
  Proprietaire getProprietaire() {
    return Proprietaire(
      nomprop: nom.text.trim().toUpperCase(),
      prenomprop: prenom.text.trim(),
      adress: adresse.text.trim(),
      typeprop: type,
      datetimes: now(),
    );
  }

  /// Enregistrer un nouveau propriétaire
  Future<void> handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.numcons == null || widget.numcons!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur : aucun numéro de construction fourni."),
        ),
      );
      return;
    }


    setState(() => loading = true);
    try {
      Proprietaire p = getProprietaire();
      p.datetimes = now();
      p.numprop = await identity();

      print("🟦 [handleSave] numcons = ${widget.numcons}");
      print("🟦 [handleSave] proprietaire = ${p.toJson()}");

      await DB.instance.insertProprietaire(p, widget.numcons!);

      if (widget.setter != null) widget.setter!(p);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Propriétaire enregistré avec succès')),
        );
        Navigator.of(context).pop(p);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur lors de l\'enregistrement : $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// Mettre à jour un propriétaire existant
  Future<void> handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      Proprietaire p = getProprietaire();
      p.datetimes = widget.proprietaire!.datetimes;
      p.numprop = widget.proprietaire!.numprop;

      await DB.instance.updateProprietaire(p);

      if (widget.setter != null) widget.setter!(p);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propriétaire mis à jour avec succès')),
        );
        Navigator.of(context).pop(p);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// Gestion du changement de valeur d’un champ (ex: dropdown)
  void changeValueOf(String varToChange, String valueOf) {
    switch (varToChange) {
      case "Type":
        setState(() {
          type = valueOf;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Préparer les éléments du dropdown depuis le fichier data
    final List<DropdownMenuItem<String>> typeOptions =
        data.Proprietaire.dropDownItems();

    return Scaffold(
      backgroundColor: color.AppColor.backgroundColor,
      appBar: AppBar(
        title: const Text("Formulaire de propriétaire"),
        backgroundColor: Colors.blue[900],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                myTextField(
                  nom,
                  "Nom",
                  focusNode: nomFocus,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Le nom est obligatoire";
                    }
                    return null;
                  },
                ),
                myTextField(
                  prenom,
                  "Prénoms",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Le prénom est obligatoire";
                    }
                    return null;
                  },
                ),
                myTextField(
                  adresse,
                  "Adresse",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "L'adresse est obligatoire";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Dropdown pour le type de propriétaire (si tu veux le garder)
                DropdownButtonFormField<String>(
                  value: type?.isNotEmpty == true ? type : null,
                  decoration: InputDecoration(
                    labelText: "Type de propriétaire",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  items: typeOptions.map((DropdownMenuItem<String> t) {
                    return DropdownMenuItem<String>(
                      value: t.value,
                      child: t.child,
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) changeValueOf("Type", value);
                  },
                ),

                const SizedBox(height: 25),

                saveButton(
                  proprietaire == null ? handleSave : handleUpdate,
                  loading: loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
