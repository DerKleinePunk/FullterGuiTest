import 'package:flutter/material.dart';
import '../component/widget/panels.dart';
import 'package:mnehomeapp/core/client_helper.dart';

class AutomationPanelController {
  final List<Widget> _panels = <Widget>[];
  final Map<String, bool> _switchMap = <String, bool>{};

  AutomationPanelController();

  void init() {
    for (int i = 0; i < 16; i++) {
      _switchMap["panel" + i.toString()] = false;
      _panels.add(Panels.getSwitchPanel("Panel " + i.toString(),
          "panel" + i.toString(), switchPanelGet, switchPanelSet, false));
    }
  }

  List<Widget> getPanels(String pageName) {
    return _panels;
  }

  bool switchPanelGet(String id) {
    return _switchMap[id]!;
  }

  void switchPanelSet(String id, bool value) {
    _switchMap[id] = value;
  }

  void loadPage(String pageName) async {
    CoreClientHelper.getClient()
        .loadAutomationPageConfig(pageName)
        .then((value) => (value) {
              if (value == null) {
                debugPrint("new Page Config get failed");
                return;
              }

              debugPrint("new Page Config get " + value.name);
            });
  }
}
