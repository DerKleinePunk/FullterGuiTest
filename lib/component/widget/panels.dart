import 'package:flutter/material.dart';

typedef GetStateCallback = bool Function(String id);
typedef SetStateCallback = void Function(String id, bool value);

class Panels {
  static getSwitchPanel(String title, String id, GetStateCallback getcallback,
      SetStateCallback setCallback) {
    return SwitchPanel(title, id, getcallback, setCallback);
  }
}

class SwitchPanel extends StatefulWidget {
  final String _title;
  final String _id;
  final GetStateCallback _getcallback;
  final SetStateCallback _setcallback;
  const SwitchPanel(this._title, this._id, this._getcallback, this._setcallback,
      {Key? key})
      : super(key: key);

  @override
  _SwitchPanelState createState() => _SwitchPanelState();
}

class _SwitchPanelState extends State<SwitchPanel> {
  static const String imageUrl =
      'https://mocah.org/thumbs/268085-wallpaper-1080-2400.jpg';
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red[500]!,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            /*image: const DecorationImage(
              image: NetworkImage(imageUrl),
            )*/
            color: Colors.yellowAccent,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget._title),
            Switch(
              value: widget._getcallback(widget._id),
              onChanged: (value) {
                widget._setcallback(widget._id, value);
                setState(() {});
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
          ])),
      onTap: () {
        widget._setcallback(widget._id, !widget._getcallback(widget._id));
        setState(() {});
      },
    );
  }
}
