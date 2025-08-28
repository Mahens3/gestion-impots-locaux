import 'package:flutter/material.dart';

class Logement {
  static List<String> varconfort = [
    "Garage",
    "Ecran plat",
    "Wifi",
    "Parabole",
    "WC interne",
    "Douche interne",
    "Salle d'eau",
    "Eau",
    "Electricité",
    "Cuisine interne",
    "Evacuation des eaux usées"
  ];
  static List<String> statut = [
    "Familial",
    "Entreprise privée",
    "Secteur public",
    "Association ou ONG",
    "Loisirs",
    "Autre"
  ];
  static List<String> typelog = [
    "Habitat",
    "Bureau",
    "Commerce",
    "Hôtellerie",
    "Banque ou microfinance",
    "Industrie",
    "Artisanat",
    "Education",
    "Santé",
    "Autre"
  ];

  static List<String> lien = [
    "Lui-même",
    "Sa fille",
    "Sa femme",
    "Son marie",
    "Son fils",
    "Son père",
    "Sa mère",
    "Son frère",
    "Sa soeur",
    "Autre"
  ];

  static List<String> typeoccup = [
    "Propriétaire",
    "Locataire",
    "Occupant gratuit"
  ];
  static List<String> niveau = [
    "Rez de chaussée",
    "1e étage",
    "2e étage",
    "3e étage",
    "4e étage",
    "5e étage",
    "6e étage",
    "7e étage",
  ];

  static List<DropdownMenuItem<String>> dropdownStatut = [];
  static List<DropdownMenuItem<String>> dropdownTypelog = [];
  static List<DropdownMenuItem<String>> dropdownTypeoccup = [];
  static List<DropdownMenuItem<String>> dropdownNiveau = [];
  static List<DropdownMenuItem<String>> dropdownLien = [];

  static void dropDownItems() {
    dropdownTypelog.clear();
    dropdownTypeoccup.clear();
    dropdownNiveau.clear();
    dropdownStatut.clear();
    dropdownLien.clear();

    for (var item in typelog) {
      dropdownTypelog.add(DropdownMenuItem(value: item, child: Text(item)));
    }
    for (var item in typeoccup) {
      dropdownTypeoccup.add(DropdownMenuItem(value: item, child: Text(item)));
    }
    for (var item in niveau) {
      dropdownNiveau.add(DropdownMenuItem(value: item, child: Text(item)));
    }
    for (var item in statut) {
      dropdownStatut.add(DropdownMenuItem(value: item, child: Text(item)));
    }

    for (var item in lien) {
      dropdownLien.add(DropdownMenuItem(value: item, child: Text(item)));
    }
  }
}
