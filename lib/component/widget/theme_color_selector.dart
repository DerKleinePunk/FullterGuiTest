import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../../core/client_helper.dart';
import 'color_selector.dart';

class ThemeColorSelector extends StatefulWidget {
  final BuildContext customContext;

  const ThemeColorSelector({required this.customContext, Key? key})
      : super(key: key);

  @override
  _ThemeColorSelectorState createState() => _ThemeColorSelectorState();
}

class _ThemeColorSelectorState extends State<ThemeColorSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      color: Colors.black,
      child: ColorSelector(
        color: CoreClientHelper.getClient().getUserSesstings().getBaseColor(),
        onColorChanged: (color) {
          //TODO when this is Called the State is Change with wrong Color
          //ColorSelector show wrong Color do not work right

          CoreClientHelper.getClient().getUserSesstings().setBaseColor(color);
          setState(() {});
          /*NeumorphicTheme.update(widget.customContext,
              (current) => current!.copyWith(baseColor: color));*/
        },
        onDialogClosed: _onDialogClosed,
      ),
    );
  }

  void _onDialogClosed() {
    NeumorphicTheme.update(
        widget.customContext,
        (current) => current!.copyWith(
            baseColor: CoreClientHelper.getClient()
                .getUserSesstings()
                .getBaseColor()));
  }
}
