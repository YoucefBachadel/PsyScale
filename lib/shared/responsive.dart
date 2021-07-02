import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const Responsive({
    Key key,
    @required this.mobile,
    @required this.tablet,
    @required this.desktop,
  }) : super(key: key);

  // This isMobile, isDesktop helep us to get the right interface

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 750;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 750 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isdesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If our width is more than 1100 then we consider it a desktop
        if (constraints.maxWidth >= 1100)
          return desktop;
        // If our width is more than 750 and less then 1100 then we consider it a tablet
        else if (constraints.maxWidth >= 750 && constraints.maxWidth < 1100)
          return tablet;
        // Or less then that we called it mobile
        else
          return mobile;
      },
    );
  }
}
