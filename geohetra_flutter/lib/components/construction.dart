import "package:flutter/material.dart";
import 'package:geohetra/components/imagecard.dart';
import "components.dart";
import '../models/construction.dart';

Container nombrePiece(Construction construction) {
  return Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(top: 15),
    width: double.infinity,
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nombre de logement par categorie",
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              construction.nbrhab.toString() + " Habitat(s)",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              construction.nbrcom.toString() + " Commerce(s)",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              construction.nbrbur.toString() + " Bureau(x)",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              construction.nbrprop.toString() + " Propriétaire(s)",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              construction.nbrloc.toString() + " Locataire(s)",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              construction.nbrocgrat.toString() + " Occupant Gratuit(x)",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    ),
  );
}

Row piece(String nom, int nombre, String surface) {
  List<Widget> rows = [];
  if (nombre > 1) {
    nom = "pièces " + nom + "s, ";
    rows = [
      Text(
        nombre.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 3),
      Text(nom),
      const SizedBox(width: 3),
      Text(
        surface.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ];
  } else if (nombre == 0) {
    nom = "aucune pièce " + nom;
    rows = [Text(nom)];
  } else if (nombre == 1) {
    nom = "Une seule pièce " + nom + ", ";
    rows = [
      Text(nom),
      const SizedBox(width: 3),
      Text(
        surface.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ];
  }
  return Row(children: rows);
}

Widget widgetConstruct(Construction construction, Size size, String filename,
    BuildContext context, Function setConstruction, Function changeFile) {
  return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: size.height - 200,
      child: SingleChildScrollView(
          child: Column(
        children: [
          ImageCard(
            changeable: true,
            filename: filename,
            setState: changeFile,
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              children: [
                textRow("Type construction", construction.typecons.toString()),
                textRow("Adresse(Lot)", construction.adress.toString()),
                textRow("Boriboritany", construction.boriboritany),
                textRow("Mur", construction.mur),
                textRow("Ossature", construction.ossature),
                textRow("Toiture", construction.toiture),
                textRow("Fondation", construction.fondation),
                textRow("Etat du mur", construction.etatmur),
                textRow("Accéssibilité", construction.access),
                textRow("Année de construction", construction.anconst),
                textRow("Avec wc", construction.wc),
                textRow("Surface de la construction",
                    construction.surface.toString()),
                textRow("Niveau", construction.nbrniv.toString()),
                nombrePiece(construction)
              ],
            ),
          )
        ],
      )));
}
