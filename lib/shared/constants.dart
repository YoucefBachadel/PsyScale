import 'package:flutter/material.dart';

class Constants {
  static const Color border = Color(0xff263238);
  static const Color myGrey = Colors.grey;

  static const int animationDuration = 1000;
  static const int snackBarDuration = 5;

  static navigationFunc(BuildContext context, Widget widget) {
    Navigator.of(context).push(PageRouteBuilder(
      fullscreenDialog: true,
      transitionDuration: Duration(milliseconds: animationDuration),
      reverseTransitionDuration: Duration(milliseconds: animationDuration),
      pageBuilder: (context, animation, secondaryAnimation) {
        final transition = CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: transition,
          child: widget,
        );
      },
    ));
  }
}
