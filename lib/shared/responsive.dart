import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const Responsive({
    Key key,
    @required this.mobile,
    this.tablet,
    @required this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 720;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 720 &&
      MediaQuery.of(context).size.width < 1000;
  static bool isdesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200)
          return desktop;
        else if (constraints.maxHeight >= 800)
          return tablet ?? desktop;
        else
          return mobile;
      },
    );
  }
}
