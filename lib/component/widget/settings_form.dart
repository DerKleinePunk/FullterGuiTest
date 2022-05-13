import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SettingsForm extends StatelessWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
    NeumorphicButton(
      onPressed: () {
        var theme = NeumorphicTheme.of(context)!;
        if (theme.isUsingDark) {
          theme.themeMode = ThemeMode.light;
          theme.current.
        } else {
          theme.themeMode = ThemeMode.dark;
        }
      },
      child: const Text('Dark Theme'),
    )
      ],
    );
  }
}
