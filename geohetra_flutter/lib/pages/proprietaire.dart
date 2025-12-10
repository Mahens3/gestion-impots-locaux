import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geohetra/api/date.dart';
import 'package:geohetra/models/proprietaire.dart';
import 'package:geohetra/database/database.dart';
import "package:geohetra/data/proprietaire.dart" as data;

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
  late FocusNode prenomFocus;
  late FocusNode adresseFocus;
  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  // Couleurs cohérentes pour l'interface
  // static const Color primaryColor = Color(0xFF1565C0); // Bleu professionnel
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF42A5F5);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    proprietaire = widget.proprietaire;

    nom = TextEditingController(text: proprietaire?.nomprop ?? "");
    prenom = TextEditingController(text: proprietaire?.prenomprop ?? "");
    adresse = TextEditingController(text: proprietaire?.adress ?? "");

    nomFocus = FocusNode();
    prenomFocus = FocusNode();
    adresseFocus = FocusNode();

    type = proprietaire?.typeprop ?? "";
  }

  @override
  void dispose() {
    nom.dispose();
    prenom.dispose();
    adresse.dispose();
    nomFocus.dispose();
    prenomFocus.dispose();
    adresseFocus.dispose();
    super.dispose();
  }

  Proprietaire getProprietaire() {
    return Proprietaire(
      nomprop: nom.text.trim().toUpperCase(),
      prenomprop: prenom.text.trim(),
      adress: adresse.text.trim(),
      typeprop: type,
      datetimes: now(),
    );
  }

  Future<void> handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.numcons == null || widget.numcons!.isEmpty) {
      _showSnackBar(
        "Erreur : aucun numéro de construction fourni.",
        isError: true,
      );
      return;
    }

    setState(() => loading = true);
    try {
      Proprietaire p = getProprietaire();
      p.datetimes = now();
      p.numprop = await identity();

      await DB.instance.insertProprietaire(p, widget.numcons!);

      if (widget.setter != null) widget.setter!(p);

      if (mounted) {
        _showSnackBar('Propriétaire enregistré avec succès', isError: false);
        Navigator.of(context).pop(p);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de l\'enregistrement : $e', isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

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
        _showSnackBar('Propriétaire mis à jour avec succès', isError: false);
        Navigator.of(context).pop(p);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la mise à jour : $e', isError: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  void changeValueOf(String varToChange, String valueOf) {
    switch (varToChange) {
      case "Type":
        setState(() {
          type = valueOf;
        });
        break;
    }
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 16,
          color: textPrimaryColor,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: focusNode.hasFocus ? primaryColor : textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: focusNode.hasFocus ? primaryColor : textSecondaryColor,
                  size: 22,
                )
              : null,
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorColor, width: 2),
          ),
          errorStyle: const TextStyle(
            color: errorColor,
            fontSize: 12,
          ),
        ),
        validator: validator,
        textInputAction:
            nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> typeOptions =
        data.Proprietaire.dropDownItems();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          proprietaire == null
              ? "Nouveau propriétaire"
              : "Modifier propriétaire",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Informations du propriétaire",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Veuillez remplir tous les champs obligatoires",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Champs du formulaire
                  _buildStyledTextField(
                    controller: nom,
                    label: "Nom *",
                    focusNode: nomFocus,
                    nextFocus: prenomFocus,
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Le nom est obligatoire";
                      }
                      return null;
                    },
                  ),

                  _buildStyledTextField(
                    controller: prenom,
                    label: "Prénoms *",
                    focusNode: prenomFocus,
                    nextFocus: adresseFocus,
                    prefixIcon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Le prénom est obligatoire";
                      }
                      return null;
                    },
                  ),

                  _buildStyledTextField(
                    controller: adresse,
                    label: "Adresse *",
                    focusNode: adresseFocus,
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "L'adresse est obligatoire";
                      }
                      return null;
                    },
                  ),

                  // Dropdown pour le type
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: DropdownButtonFormField<String>(
                      value: type?.isNotEmpty == true ? type : null,
                      decoration: InputDecoration(
                        labelText: "Type de propriétaire",
                        labelStyle: const TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(
                          Icons.category_outlined,
                          color: textSecondaryColor,
                          size: 22,
                        ),
                        filled: true,
                        fillColor: cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: borderColor,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: borderColor,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: textSecondaryColor,
                      ),
                      dropdownColor: cardColor,
                      items: typeOptions,
                      onChanged: (value) {
                        if (value != null) changeValueOf("Type", value);
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bouton d'enregistrement stylisé
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : (proprietaire == null ? handleSave : handleUpdate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: textSecondaryColor,
                        elevation: 2,
                        shadowColor: primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  proprietaire == null
                                      ? Icons.save_outlined
                                      : Icons.update_outlined,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  proprietaire == null
                                      ? "Enregistrer"
                                      : "Mettre à jour",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
