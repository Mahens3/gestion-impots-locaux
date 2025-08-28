import "package:flutter/material.dart";
import 'package:geohetra/components/button.dart';
import 'package:geohetra/models/logement.dart';

Container logementContainer(
    Logement logement, int numcons, Function refresh, BuildContext context) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(0, 3, 0, 10),
    height: 180,
    padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 4,
              blurRadius: 6,
              offset: const Offset(0, 3))
        ]),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Statut : ",
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  logement.statut,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            buttonEditLog(logement, numcons, refresh, context),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(logement.nbrres.toString() + " residant(s)",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text("Occupant : ", style: TextStyle(fontSize: 12)),
                Text(
                  logement.typeoccup,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Loyer : "),
                Text(logement.lm.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12))
              ],
            )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            const Text("Niveau: ", style: TextStyle(fontSize: 12)),
            const SizedBox(
              width: 5,
            ),
            Text(logement.niveau,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        const Text("Confort:", style: TextStyle(fontSize: 12)),
        Text(logement.confort,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        logement.declarant != null
            ? SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    const Text("Declarant:", style: TextStyle(fontSize: 12)),
                    Text(
                        logement.declarant.toString() +
                            "(" +
                            logement.lien.toString() +
                            ")",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              )
            : const SizedBox()
      ],
    ),
  );
}

Widget widgetLogements(int numcons, List<Logement> logements, Function refresh,
    Size size, BuildContext context) {
  List<Widget> widgets = [];
  for (int i = 0; i < logements.length; i++) {
    widgets.add(logementContainer(logements[i], numcons, refresh, context));
  }
  return SizedBox(
      child: logements.isEmpty
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: IconButton(
                        iconSize: 100,
                        onPressed: () {},
                        icon: Icon(
                          Icons.home,
                          color: Colors.grey[400],
                        )),
                  ),
                  Text(
                    "Liste des logements",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[400]),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  height: size.height - 200,
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                  child: SingleChildScrollView(
                    child: Column(children: widgets),
                  ),
                )
              ],
            ));
}
