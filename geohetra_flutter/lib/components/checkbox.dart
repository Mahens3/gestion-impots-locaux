import 'package:flutter/material.dart';

class CheckBoxes extends StatefulWidget {
  final List<String> options;
  final String value;
  final Function handleChange;
  final String title;
  const CheckBoxes(
      {Key? key,
      required this.options,
      required this.value,
      required this.title,
      required this.handleChange})
      : super(key: key);

  @override
  State<CheckBoxes> createState() => _CheckBoxesState();
}

class _CheckBoxesState extends State<CheckBoxes> {
  late Map<String, bool?> checked = {};
  late bool all = false;
  late String joined = "";

  @override
  void initState() {
    super.initState();
    Map<String, bool> chk = {};
    for (var i = 0; i < widget.options.length; i++) {
      chk.putIfAbsent(widget.options[i], () => false);
    }
    List<String> values = widget.value.split(", ");
    for (var i = 0; i < values.length; i++) {
      chk[values[i]] = true;
    }
    checked = chk;
  }

  void joinResult(Map<String, bool?> checked) {
    List<String> listValue = [];
    checked.map((key, val) {
      if (val == true) {
        listValue.add(key);
      }
      return MapEntry(key, val);
    });
    String value = listValue.join(", ");
    widget.handleChange(value);
  }

  void handleAll() {
    for (var i = 0; i < widget.options.length; i++) {
      var newChecked = checked;
      newChecked[widget.options[i]] = all;
      setState(() {
        joinResult(newChecked);
      });
    }
  }

  Widget allBtn() {
    return SizedBox(
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Checkbox(
                activeColor: Colors.green,
                value: all,
                onChanged: ((value) {
                  setState(() {
                    all = !all;
                  });
                })),
          ]),
    );
  }

  List<Widget> getCheckBoxes(List<String> options) {
    List<Widget> listCheckBox = [];
    listCheckBox.add(Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            allBtn()
          ],
        )));
    for (var i = 0; i < options.length; i++) {
      listCheckBox.add(CheckboxListTile(
        value: checked[options[i]],
        activeColor: Colors.green,
        onChanged: (value) {
          var newChecked = checked;
          newChecked[options[i]] = value;
          setState(() {
            joinResult(newChecked);
          });
        },
        title: Text(options[i]),
      ));
    }
    return listCheckBox;
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
        children: getCheckBoxes(widget.options),
      ),
    );
  }
}
