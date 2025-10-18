import 'package:flutter/material.dart';
import 'package:geohetra/models/logement.dart';
import 'package:geohetra/models/personne.dart';
import 'package:geohetra/pages/construction.dart';
import 'package:geohetra/pages/logement.dart';
import 'package:geohetra/pages/personne.dart';
import 'package:latlong2/latlong.dart';

Container saveButton(Function? handleChange, {bool? loading}) {
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))),
  );
  return Container(
      margin: const EdgeInsets.all(20),
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: raisedButtonStyle,
        onPressed: () {
          if (loading == null) {
            handleChange != null ? handleChange() : null;
          } else {
            if (loading == false) {
              handleChange != null ? handleChange() : null;
            }
          }
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          (loading == true)
              ? Container(
                  margin: const EdgeInsets.only(right: 10),
                  height: 10,
                  width: 10,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ))
              : const SizedBox(),
          const Text("Enregistrer")
        ]),
      ));
}

InkWell newConstruction(
    BuildContext context, LatLng? latLng, Function refresh, bool next) {
  return InkWell(
      onTap: () {
        var route = MaterialPageRoute(
            builder: (context) => FormConstruction(
                  latLng: latLng,
                  refresh: refresh,
                  next: next,
                ));
        Navigator.of(context).push(route);
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 8),
          child: const Icon(
            Icons.add_location,
            color: Colors.white,
          ),
          decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(1, 2),
                  blurRadius: 2,
                )
              ])));
}

InkWell showTerrain(BuildContext context, Function fonction, bool show) {
  return InkWell(
      onTap: () {
        fonction();
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 8),
          child: const Icon(
            Icons.map,
            color: Colors.white,
          ),
          decoration: BoxDecoration(
              color: show ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(1, 2),
                  blurRadius: 2,
                )
              ])));
}

Widget myButtonEdit(Function fonction) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
    ),
    child: IconButton(
        onPressed: () {
          fonction();
        },
        icon: const Icon(Icons.edit)),
  );
}

Widget buttonEditLog(
    Logement? logement, int id, Function refresh, BuildContext context) {
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 13),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
  );
  return SizedBox(
      height: 30,
      width: 95,
      child: ElevatedButton(
        style: raisedButtonStyle,
        onPressed: () {
          var route = MaterialPageRoute(
              builder: (context) => FormLogement(
                    numcons: id,
                    logement: logement,
                    refresh: refresh,
                  ));
          Navigator.of(context).push(route);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Icon(
              Icons.edit,
              size: 13,
            ),
            Text("Modifier")
          ],
        ),
      ));
}

Widget buttonEditPers(
    Personne? personne, int id, Function refresh, BuildContext context) {
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 13),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
  );
  return SizedBox(
      height: 30,
      width: 95,
      child: ElevatedButton(
        style: raisedButtonStyle,
        onPressed: () {
          var route = MaterialPageRoute(
              builder: (context) => FormPersonne(
                    numcons: id,
                    personne: personne,
                    refresh: refresh,
                  ));
          Navigator.of(context).push(route);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Icon(
              Icons.edit,
              size: 13,
            ),
            Text("Modifier")
          ],
        ),
      ));
}
