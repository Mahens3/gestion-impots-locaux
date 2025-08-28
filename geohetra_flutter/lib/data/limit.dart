import 'package:flutter/material.dart';

class Limit {
  static List<String> varlimit = [
    "Tous",
    "50",
    "100",
    "200",
  ];

  static List<DropdownMenuItem<String>> dropdownLimit = [];

  static void dropDownItems() {
    dropdownLimit.clear();

    for (var item in varlimit) {
      dropdownLimit.add(DropdownMenuItem(value: item, child: Text(item)));
    }
  }
}
