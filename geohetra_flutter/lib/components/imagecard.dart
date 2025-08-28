import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geohetra/filemanager/file_manager.dart';
import 'package:geohetra/filemanager/save_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class ImageCard extends StatefulWidget {
  ImageCard(
      {Key? key, this.filename = "", this.setState, this.changeable = false})
      : super(key: key);
  final Function? setState;
  final Object? filename;
  bool? radiusCircular;
  bool? changeable;
  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  late ImageProvider<Object> image;
  final imagePicker = ImagePicker();

  String extension(String file) {
    List<String> splitted = file.split(".");
    return "." + splitted[splitted.length - 1];
  }

  Future<String> getServer() async {
    var root = await getApplicationDocumentsDirectory();
    var file = File(root.path + "/settings.json");
    var text = await file.readAsString();
    Map<String, dynamic> data = json.decode(text);
    return data["server"].toString();
  }

  Future uploadImage() async {
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    final uploadedFile = pickedImage?.name;

    if (uploadedFile != null) {
      var filename = "";

      // Si le nom de fichier contient UN POINT, on ajoute pas l'extension
      if (widget.filename.toString().contains(".")) {
        filename = widget.filename.toString();
      } else {
        filename = widget.filename.toString() + extension(uploadedFile);
      }
      final bytes =
          await pickedImage!.readAsBytes().then((value) => value.toList());
      FileManager.instance
          .writeImage(filename.toString(), bytes)
          .then((value) async {
        saveImage(filename, bytes);
        await FileManager.instance.readImage(filename.toString()).then((value) {
          setState(() {
            //image = Image.network("${getServer()}/api/image/20230309112905411703410.jpg") .image;
            image = Image.memory(value as Uint8List).image;
            widget.setState!(filename);
          });
        });
      });
    }
  }

  Future loadImage() async {
    final filemanager =
        FileManager.instance.readImage(widget.filename as String);
    if (await filemanager != null) {
      return Image.memory(await filemanager as Uint8List).image;
    } else {
      return null;
    }

  }

  FutureBuilder imageDisplay() {
    return FutureBuilder(
        future: loadImage(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data == null
                ? Container(
                    height: 250,
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/grey.png")),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.white,
                              spreadRadius: 4,
                              blurRadius: 6,
                              offset: Offset(0, 3))
                        ]))
                : Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: snapshot.data, fit: BoxFit.cover),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.white,
                              spreadRadius: 4,
                              blurRadius: 6,
                              offset: Offset(0, 3))
                        ]),
                    height: 250,
                  );
          } else {
            return Center(
                child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/grey.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: double.infinity,
                    height: 150,
                    child: const Center(
                        child:
                            CircularProgressIndicator(color: Colors.green))));
          }
        });
  }

  double getTop() {
    return widget.filename == "" ? 50 : 20;
  }

  double getLeft() {
    return widget.filename == ""
        ? MediaQuery.of(context).size.width / 2 - 30
        : 20;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      imageDisplay(),
      widget.changeable == true
          ? Container(
              margin: EdgeInsets.only(top: getTop(), left: getLeft()),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromARGB(255, 123, 248, 135),
                        blurRadius: 5)
                  ]),
              child: IconButton(
                iconSize: 40,
                icon: const Icon(
                  Icons.camera_alt,
                  size: 25,
                ),
                onPressed: () {
                  uploadImage();
                },
              ))
          : Container()
    ]);
  }
}
