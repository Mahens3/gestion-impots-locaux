import 'package:flutter/material.dart';

class Proprietaire {
  static List<String> types = ["Mr", "Mme", "Autre"];
  static List<DropdownMenuItem<String>> dropdownTypes = [];
  static void dropDownItems() {
    dropdownTypes.clear();

    for (var item in types) {
      dropdownTypes.add(DropdownMenuItem(value: item, child: Text(item)));
    }
  }
}
