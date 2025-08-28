import 'package:flutter/material.dart';

class Construction {
  static List<String> typecons = [
    "Imposable",
    "WC",
    "Douche",
    "Maison effondrée",
    "En cours de construction",
    "Autre"
  ];
  static List<String> mur = [
    "Néant",
    "Pisé",
    "Brique crue",
    "Tôle",
    "Planche",
    "Végétal",
    "Brique cuite",
    "Parpaing",
    "Pierre",
    "Bois de qualité",
    "Préfabriqué",
    "Béton",
    "Autre"
  ];
  static List<String> ossature = [
    "Bois",
    "Brique crue",
    "Brique cuite",
    "Pierre",
    "Béton",
    "Autre"
  ];
  static List<String> toiture = [
    "Chaume/précaire",
    "Tôle",
    "Tuiles",
    "Béton",
    "Autre"
  ];
  static List<String> fondation = [
    "Néant",
    "Brique crue",
    "Brique cuite",
    "Béton",
    "Pierre",
    "Ciment et pierre",
    "Pisé",
    "Sur pilotis",
    "Autre"
  ];
  static List<String> typehab = [
    "Précaire",
    "Traditionnel",
    "Moderne",
    "Haut standing",
    "Autre"
  ];
  static List<String> etatmur = [
    "Très bon",
    "Bon",
    "Moyen",
    "Dégradé",
    "Autre"
  ];
  static List<String> access = [
    "Chemin",
    "Piste",
    "Goudron/pavé",
    "Sentier",
    "Autre"
  ];

  static List<DropdownMenuItem<String>> dropdownMur = [];
  static List<DropdownMenuItem<String>> dropdownOssature = [];
  static List<DropdownMenuItem<String>> dropdownToiture = [];
  static List<DropdownMenuItem<String>> dropdownFondation = [];
  static List<DropdownMenuItem<String>> dropdownTypehab = [];
  static List<DropdownMenuItem<String>> dropdownAccess = [];
  static List<DropdownMenuItem<String>> dropdownEtatmur = [];
  static List<DropdownMenuItem<String>> dropdownTypecons = [];

  static void dropDownItems() {
    dropdownMur.clear();
    dropdownToiture.clear();
    dropdownOssature.clear();
    dropdownFondation.clear();
    dropdownTypehab.clear();
    dropdownEtatmur.clear();
    dropdownAccess.clear();
    dropdownTypecons.clear();

    for (var item in mur) {
      dropdownMur.add(DropdownMenuItem(value: item, child: Text(item)));
    }

    for (var item in toiture) {
      dropdownToiture.add(DropdownMenuItem(value: item, child: Text(item)));
    }

    for (var item in ossature) {
      dropdownOssature.add(DropdownMenuItem(value: item, child: Text(item)));
    }
    for (var item in fondation) {
      dropdownFondation.add(DropdownMenuItem(value: item, child: Text(item)));
    }
    for (var item in typehab) {
      dropdownTypehab.add(DropdownMenuItem(value: item, child: Text(item)));
    }
    for (var item in etatmur) {
      dropdownEtatmur.add(DropdownMenuItem(value: item, child: Text(item)));
    }
    for (var item in access) {
      dropdownAccess.add(DropdownMenuItem(value: item, child: Text(item)));
    }

    for (var item in typecons) {
      dropdownTypecons.add(DropdownMenuItem(value: item, child: Text(item)));
    }
  }
}
