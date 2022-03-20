import 'package:flutter/material.dart';
import 'bootstrap.dart';
import 'bootSteps/login_boot_step.dart';

class HomeServerBootstrap extends StatelessWidget {
  final BootCompleted bootCompleted;

  const HomeServerBootstrap(this.bootCompleted, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BootStrap(
      const [
        LoginBootStep(),
      ],
      bootCompleted,
    );
  }
}