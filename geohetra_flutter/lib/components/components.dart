import 'package:flutter/material.dart';

Widget myTextField(TextEditingController ctrl, String text,
    {bool number = false, FocusNode? focusNode}) {
  return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 1, 15, 1),
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 7),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0, 0),
                  blurRadius: 0.5,
                )
              ]),
          child: TextField(
              focusNode: focusNode,
              cursorColor: Colors.green,
              controller: ctrl,
              keyboardType:
                  (number == false) ? TextInputType.text : TextInputType.number,
              decoration: const InputDecoration(border: InputBorder.none)),
        )
      ]));
}

Widget myText(String titre, String value, double width) {
  return Container(
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.only(top: 10),
    width: width,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Row(
      children: [
        Text(
          titre + ": ",
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        )
      ],
    ),
  );
}

Widget myText2(String titre, String value, double width) {
  return Container(
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.only(top: 10),
    width: width,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre + ": ",
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        )
      ],
    ),
  );
}

class MyDropdown extends StatefulWidget {
  final String? value;
  final String label;
  final List<DropdownMenuItem<String>> items;
  final Function setState;
  const MyDropdown(
      {Key? key,
      required this.value,
      required this.label,
      required this.items,
      required this.setState})
      : super(key: key);

  @override
  State<MyDropdown> createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  TextEditingController text = TextEditingController(text: "");
  late String val = "";

  @override
  void initState() {
    super.initState();
    if (exist(widget.items, widget.value)) {
      val = widget.value!;
    } else {
      val = "Autre";
      text.text = widget.value!;
    }
  }

  void change(String value) {
    setState(() {
      val = value;
    });
  }

  bool exist(List<DropdownMenuItem<String>> items, String? search) {
    bool result = false;
    for (var i = 0; i < items.length; i++) {
      if (items[i].value == search && items[i].value != "Autre") {
        result = true;
        break;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(15, 1, 15, 1),
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 7),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0, 0),
                        blurRadius: 0.5,
                      )
                    ]),
                child: DropdownButton(
                    underline: const SizedBox.shrink(),
                    isExpanded: true,
                    value: exist(widget.items, widget.value)
                        ? widget.value
                        : "Autre",
                    items: widget.items,
                    onChanged: (value) {
                      widget.setState(widget.label, value.toString());
                      change(value.toString());
                    })),
            (exist(widget.items, widget.value) == false)
                ? Container(
                    padding: const EdgeInsets.fromLTRB(15, 1, 15, 1),
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 7),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0, 0),
                            blurRadius: 0.5,
                          )
                        ]),
                    child: TextField(
                        controller: text,
                        cursorColor: Colors.green,
                        onChanged: (value) {
                          change("Autre");
                          widget.setState(widget.label, value);
                        },
                        decoration:
                            const InputDecoration(border: InputBorder.none)),
                  )
                : const SizedBox()
          ],
        ));
  }
}

Widget myDropDownButton(String label, String? val,
    List<DropdownMenuItem<String>> items, Function setState) {
  return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(15, 1, 15, 1),
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 7),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, 0),
                      blurRadius: 0.5,
                    )
                  ]),
              child: DropdownButton(
                  underline: const SizedBox.shrink(),
                  isExpanded: true,
                  value: val,
                  items: items,
                  onChanged: (value) {
                    setState(label, value.toString());
                  })),
        ],
      ));
}

Container textRow(textLeft, textRight) {
  return Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(top: 15),
    width: double.infinity,
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3))
        ]),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          textLeft,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        Text(
          textRight ?? "",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Container textColumn(textLeft, textRight) {
  return Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(top: 15),
    width: double.infinity,
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3))
        ]),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textLeft,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        Text(
          textRight,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
