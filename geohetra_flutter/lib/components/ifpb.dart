import "package:flutter/material.dart";
import 'package:geohetra/models/ifpb.dart';
import 'package:geohetra/pages/ifpb.dart';
import "components.dart";

Widget widgetIFPB(Ifpb ifpb, Size size) {
  return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      height: size.height - 200,
      child: SingleChildScrollView(
          child: Column(
        children: [
          textRow("Exonération", ifpb.exon),
          textRow("Dernière avis reçu", ifpb.dernanne),
          textRow("Montant inscrit", ifpb.montantins.toString()),
          textRow("Montant payé", ifpb.montantpay.toString()),
          textRow("Article", ifpb.article.toString()),
          textRow("Role", ifpb.role.toString()),
        ],
      )));
}

Widget containerIfpb(
    Ifpb? ifpb, Function setter, Size screen, BuildContext context) {
  return Container(
    child: ifpb == null
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
                            builder: (context) => FormIfpb(
                                  ifpb: ifpb,
                                  setter: setter,
                                ));
                        Navigator.of(context).push(route);
                      },
                      icon: Icon(
                        Icons.money,
                        color: Colors.grey[400],
                      )),
                ),
                Text(
                  "Page de l'IFPB",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey[400]),
                )
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [widgetIFPB(ifpb, screen)],
          ),
  );
}
