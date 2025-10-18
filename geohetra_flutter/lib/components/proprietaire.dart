import "package:flutter/material.dart";
import "package:geohetra/models/construction.dart";
import 'package:geohetra/pages/proprietaire.dart';
import "components.dart";
import "package:geohetra/models/proprietaire.dart";

Widget widgetProprietaire(Proprietaire proprietaire, Size size) {
  return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      height: size.height - 200,
      child: SingleChildScrollView(
          child: Column(
        children: [
          textColumn("Nom", proprietaire.nomprop),
          textColumn("Prénoms", proprietaire.prenomprop),
          textColumn("Adresse", proprietaire.adress)
        ],
      )));
}

Widget containerProprietaire(
  Proprietaire? proprietaire,
  Function setter,
  Size screen,
  BuildContext context,
  Construction construction,
) {
  return Container(
    child: proprietaire == null
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: IconButton(
                      iconSize: 100,
                      onPressed: () {
                        var route = MaterialPageRoute(
                            builder: (context) => FormProprietaire(
                                  proprietaire: proprietaire,
                                  setter: setter,
                                  numcons: construction.numcons, // 👈 correct
                                ));
                        Navigator.of(context).push(route);
                      },
                      icon: Icon(
                        Icons.account_circle,
                        color: Colors.grey[400],
                      )),
                ),
                Text(
                  "Page du propriétaire",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey[400]),
                )
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [widgetProprietaire(proprietaire, screen)],
          ),
  );
}
