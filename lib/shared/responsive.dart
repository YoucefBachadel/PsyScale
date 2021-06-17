import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const Responsive({
    Key key,
    @required this.mobile,
    @required this.desktop,
  }) : super(key: key);

  // This size work fine on my design, maybe you need some customization depends on your design

  // This isMobile, isDesktop helep us later

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;
  static bool isdesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 850;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If our width is more than 850 then we consider it a desktop
        if (constraints.maxWidth >= 850)
          return desktop;
        // Or less then that we called it mobile
        else
          return mobile;
      },
    );
  }
}
