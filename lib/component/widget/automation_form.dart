import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../../core/automation_panel_controller.dart';
import '../../core/extensions.dart';

class AutomationForm extends StatelessWidget {
  final AutomationPanelController panelController;

  const AutomationForm(this.panelController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int count = renderMobileMode(context) ? 3 : 4;
    return GridView.count(
        crossAxisCount: count,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.all(10.0),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        children: panelController.getPanels());
  }
}
