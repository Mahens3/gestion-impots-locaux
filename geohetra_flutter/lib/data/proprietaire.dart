import 'package:flutter/material.dart';

class Proprietaire {
  static List<String> types = ["Mr", "Mme", "Autre"];

  static List<DropdownMenuItem<String>> dropDownItems() {
    // Retourne directement une nouvelle liste au lieu de modifier une variable statique
    return types
        .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ))
        .toList();
  }
}
