import 'package:flutter/material.dart';
import '../component/widget/panels.dart';

class AutomationPanelController {
  final List<Widget> _panels = <Widget>[];
  final Map<String, bool> _switchMap = <String, bool>{};

  AutomationPanelController();

  void init() {
    for (int i = 0; i < 16; i++) {
      _switchMap["panel" + i.toString()] = false;
      _panels.add(Panels.getSwitchPanel("Panel " + i.toString(),
          "panel" + i.toString(), switchPanelGet, switchPanelSet));
    }
  }

  List<Widget> getPanels() {
    return _panels;
  }

  bool switchPanelGet(String id) {
    return _switchMap[id]!;
  }

  void switchPanelSet(String id, bool value) {
    _switchMap[id] = value;
  }
}
