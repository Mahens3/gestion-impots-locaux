import "package:flutter/material.dart";
import 'package:geohetra/components/button.dart';
import 'package:geohetra/models/personne.dart';

Container personneContainer(
    {Personne? personne,
    required int index,
    int? numcons,
    required Function refresh,
    required BuildContext context}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(0, 3, 0, 10),
    height: 140,
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
            Container(
              width: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(20)),
              child: Text(
                index.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            buttonEditPers(personne, numcons as int, refresh, context)
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            const Text(
              "Sexe : ",
              style: TextStyle(fontSize: 12),
            ),
            Text(
              personne!.sexe,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Age : ",
              style: TextStyle(fontSize: 12),
            ),
            Text(
              personne.age.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profession : ",
              style: TextStyle(fontSize: 12),
            ),
            Text(
              personne.profession.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        (personne.profession.contains("Elève") ||
                personne.profession == "Etudiant")
            ? Row(
                children: [
                  const Text("Lieu: ", style: TextStyle(fontSize: 12)),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(personne.lieu,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12))
                ],
              )
            : const SizedBox(),
      ],
    ),
  );
}

Widget widgetPersonnes(int numcons, List<Personne> personne, Function refresh,
    Size size, BuildContext context) {
  List<Widget> widgets = [];
  for (int i = 0; i < personne.length; i++) {
    widgets.add(personneContainer(
        index: personne.length - i,
        personne: personne[i],
        numcons: numcons,
        refresh: refresh,
        context: context));
  }
  return SizedBox(
      child: personne.isEmpty
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
                          Icons.supervised_user_circle,
                          color: Colors.grey[400],
                        )),
                  ),
                  Text(
                    "Liste des personnes",
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
