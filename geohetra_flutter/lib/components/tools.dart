import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geohetra/components/fade_animation.dart';
import 'package:geohetra/database/database.dart';
import 'package:geohetra/data/limit.dart' as data;

class BarBottom extends StatefulWidget {
  final Function yourLocalisation;
  final Function showAchieve;
  final Function showInachieve;
  final Function showVoisin;
  final Function handleColor;
  const BarBottom(
      {Key? key,
      required this.yourLocalisation,
      required this.showAchieve,
      required this.showInachieve,
      required this.handleColor,
      required this.showVoisin})
      : super(key: key);

  @override
  State<BarBottom> createState() => _BarBottomState();
}

class _BarBottomState extends State<BarBottom> {
  Color inachieve = Colors.green;
  bool show = false;
  bool showInachieve = true;
  bool showAchieve = true;
  bool showVoisin = true;

  Map<String, int> myColor = {"inachieve": 6, "achieve": 2, "voisin": 9};

  String selected = "inachieve";
  final List<Color> colors = [
    Colors.pink,
    Colors.pinkAccent,
    Colors.red,
    Colors.deepOrangeAccent,
    Colors.orange,
    Colors.yellow,
    Colors.yellowAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.indigo,
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.purple,
    Colors.purpleAccent,
    Colors.black,
    Colors.white,
  ];

  void changeColor(int index) {
    setState(() {
      Map<String, int> newColor = myColor;
      newColor[selected] = index;
      myColor = newColor;
      show = false;
    });
    setColor();
  }

  void setColor() {
    Map<String, Color> newColor = {};

    //print(myColor);
    myColor.map((key, value) {
      newColor[key] = colors[value];
      return MapEntry(key, value);
    });
    widget.handleColor(newColor);
  }

  Widget homeColor({required int index}) {
    return InkWell(
        onTap: () {
          changeColor(index);
        },
        child: Container(
          width: 40,
          height: 20,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: colors[index], borderRadius: BorderRadius.circular(5)),
        ));
  }

  List<Widget> widgets() {
    List<Widget> liste = [];
    for (var i = 0; i < colors.length; i++) {
      liste.add(homeColor(
        index: i,
      ));
    }
    return liste;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        children: [
          Container(
              color: Colors.grey[200],
              height: show ? 60 : 0,
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widgets(),
              )),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Scaling(
                      child: InkWell(
                          onDoubleTap: () {
                            setState(() {
                              show = !show;
                              selected = "inachieve";
                            });
                          },
                          onTap: () {
                            setState(() {
                              showInachieve = !showInachieve;
                              widget.showInachieve();
                            });
                          },
                          child: Opacity(
                              opacity: showInachieve ? 1 : 0.5,
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 2),
                                    width: 20,
                                    height: 20,
                                    child: Icon(
                                      Icons.home_outlined,
                                      color:
                                          colors[myColor["inachieve"] as int],
                                      size: 16,
                                    ),
                                  ),
                                  const Text(
                                    "Inachevé",
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              )))),
                  Scaling(
                      child: InkWell(
                          onDoubleTap: () {
                            setState(() {
                              show = !show;
                              selected = "achieve";
                            });
                          },
                          onTap: () {
                            setState(() {
                              showAchieve = !showAchieve;
                              widget.showAchieve();
                            });
                          },
                          child: Opacity(
                              opacity: showAchieve ? 1 : 0.5,
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 2),
                                    width: 20,
                                    height: 20,
                                    child: Icon(
                                      Icons.home_outlined,
                                      color: colors[myColor["achieve"] as int],
                                      size: 16,
                                    ),
                                  ),
                                  const Text(
                                    "Achevé",
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              )))),
                  Scaling(
                      child: InkWell(
                          onTap: () {
                            setState(() {
                              showVoisin = !showVoisin;
                              widget.showVoisin();
                            });
                          },
                          onDoubleTap: () {
                            setState(() {
                              show = !show;
                              selected = "voisin";
                            });
                          },
                          child: Opacity(
                              opacity: showVoisin ? 1 : 0.5,
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 2),
                                    width: 20,
                                    height: 20,
                                    child: Icon(
                                      Icons.home_outlined,
                                      color: colors[myColor["voisin"] as int],
                                      size: 16,
                                    ),
                                  ),
                                  const Text(
                                    "Autre",
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              )))),
                  Scaling(
                      child: InkWell(
                    onTap: (() {
                      widget.yourLocalisation();
                    }),
                    child: Row(
                      children: const [
                        GPS(),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Vous",
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  ))
                ]),
          )
        ],
      ),
    );
  }
}

Widget dropdownItem(
    List<DropdownMenuItem<String>> items, String? val, Function handleLimit) {
  return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: DropdownButton(
          underline: const SizedBox.shrink(),
          isExpanded: true,
          value: val,
          items: items,
          onChanged: (value) {
            handleLimit(value);
          }));
}

class BarFkt extends StatefulWidget {
  final int id;
  final Function handleChange;
  final Function handleLimit;
  const BarFkt(
      {Key? key,
      required this.id,
      required this.handleChange,
      required this.handleLimit})
      : super(key: key);

  @override
  State<BarFkt> createState() => _BarFktState();
}

class _BarFktState extends State<BarFkt> {
  late String? selected = "";
  late String? limit = "Tous";
  late List<DropdownMenuItem<String>> dropdown = [];

  late List<DropdownMenuItem<String>> limitItems = [];

  late List<Map<String, Object?>> fokontany = [];

  void handleLimit(String newLimit) {
    setState(() {
      limit = newLimit;
      if (newLimit == "Tous") {
        widget.handleLimit(null);
      } else {
        widget.handleLimit(int.parse(newLimit));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getFokontany();
  }

  void getFokontany() async {
    try {
      var fkt = await DB.instance.getFkt();
      //print(fkt);

      fokontany = fkt;
      selected = fokontany.first["idfoko"].toString();
    } catch (e) {}
  }

  void clearDropdown() {
    dropdown.clear();
    for (var item in fokontany) {
      dropdown.add(DropdownMenuItem(
          value: item["idfoko"].toString(),
          child: Text(item["nomfokontany"].toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    clearDropdown();
    double width = MediaQuery.of(context).size.width;
    return fokontany.isNotEmpty
        ? Container(
            width: width,
            color: Colors.grey[300],
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      width: width * (2 / 3),
                      child: DropdownButton(
                          underline: const SizedBox.shrink(),
                          isExpanded: true,
                          value: selected,
                          items: dropdown,
                          onChanged: (value) {
                            setState(() {
                              selected = value.toString();
                              widget.handleChange(int.parse(value.toString()));
                            });
                          })),
                  SizedBox(
                      width: (width / 3) - 15,
                      child: dropdownItem(
                          data.Limit.dropdownLimit, limit, handleLimit))
                ]))
        : const SizedBox();
  }
}

class GPS extends StatefulWidget {
  const GPS({Key? key}) : super(key: key);

  @override
  State<GPS> createState() => _GPSState();
}

class _GPSState extends State<GPS> with TickerProviderStateMixin {
  double spread = 0;
  bool grown = true;
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 150), grow);
  }

  void grow(Timer t) {
    if (mounted) {
      setState(() {
        if (spread == 5) {
          grown = false;
        } else if (spread == 0) {
          grown = true;
        }

        if (grown == true) {
          spread += 0.5;
        } else {
          spread -= 0.5;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    data.Limit.dropDownItems();
    return Container(
      child: Icon(
        Icons.circle,
        color: Colors.green[200],
        size: 5,
      ),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(
          color: Colors.green,
          spreadRadius: spread,
          blurRadius: 6,
        )
      ]),
    );
  }
}
