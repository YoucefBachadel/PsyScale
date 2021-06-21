import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:psyscale/main.dart';
import 'package:psyscale/services/authenticationServices%20.dart';
import 'package:psyscale/shared/constants.dart';

Widget appBar(BuildContext context, String txt1, String txt2) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        txt1,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 30,
        ),
      ),
      Text(
        txt2,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).accentColor,
          fontSize: 30,
        ),
      ),
    ],
  );
}

Widget loading(BuildContext context) {
  return Container(
    color: Colors.transparent,
    child: Center(
      child: SpinKitChasingDots(
        color: Theme.of(context).accentColor,
        size: 50.0,
      ),
    ),
  );
}

Widget loadingImage(BuildContext context, String image) {
  return Stack(
    fit: StackFit.expand,
    children: [
      CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (context, url) => SpinKitPulse(
          color: Theme.of(context).accentColor,
          size: 50.0,
        ),
      ),
    ],
  );
}

Widget checkYourNetwork(BuildContext context) {
  return Container(
    color: Colors.transparent,
    child: Center(
      child: Text('Check Your Network'),
    ),
  );
}

Widget error() {
  return Container(
    child: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.warning),
        ),
        Text('Error in loadind data')
      ],
    ),
  );
}

InputDecoration textInputDecoration(BuildContext context, String hint) {
  return InputDecoration(
    filled: true,
    hintText: hint,
    labelText: hint,
    labelStyle: TextStyle(color: Constants.myGrey),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Constants.myGrey,
        width: 2.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).accentColor,
        width: 2.0,
      ),
    ),
  );
}

InputDecoration searchTextInputDecoration(
    BuildContext context, Function onPressed) {
  return InputDecoration(
    filled: true,
    hintText: 'Search',
    labelText: 'Search',
    labelStyle: TextStyle(color: Constants.myGrey),
    prefixIcon: Icon(
      Icons.search,
      size: 30.0,
      color: Constants.border,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Theme.of(context).accentColor,
        width: 0.5,
      ),
    ),
    suffixIcon: IconButton(
      alignment: Alignment.center,
      icon: Icon(
        Icons.close,
        size: 30.0,
        color: Constants.border,
      ),
      focusColor: Theme.of(context).accentColor,
      onPressed: onPressed,
    ),
  );
}

Widget desktopWidget(
    Widget flexibleChild1, Widget flexibleChild2, Widget mainChild) {
  return Row(children: [
    Flexible(
      flex: 2,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: flexibleChild1,
        ),
      ),
    ),
    const Spacer(),
    Container(
      width: 720.0,
      child: mainChild,
    ),
    const Spacer(),
    Flexible(
      flex: 2,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: flexibleChild2,
        ),
      ),
    ),
  ]);
}

Widget divider() {
  return Divider(
    color: Constants.myGrey,
    thickness: 1.5,
  );
}

Widget emptyList() {
  return Container(
    alignment: Alignment.center,
    child: Text(
      'No Result To Show',
      style: TextStyle(fontSize: 30, color: Constants.myGrey),
    ),
  );
}

Widget deleteButton(BuildContext context, Function onTap,
    {String text, Color color, IconData icon}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 3.0),
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.0),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
            ),
            SizedBox(width: 8.0),
            Text(
              text,
              style: TextStyle(color: color, fontSize: 16),
            ),
          ],
        ),
      ),
    ),
  );
}

ScaffoldFeatureController snackBar(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    elevation: 1.0,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Theme.of(context).accentColor, width: 2.0),
      borderRadius: BorderRadius.circular(6.0),
    ),
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: Constants.snackBarDuration),
  ));
}

Future createDialog(BuildContext context, Widget content, bool dismissable) {
  return showDialog(
    barrierDismissible: dismissable,
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: content,
    ),
  );
}

Widget unsupportedScreenSize(
    BuildContext context, String message, bool logout) {
  return Scaffold(
    body: Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: 300,
        height: 450,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border.all(color: Constants.border, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            )
          ],
        ),
        child: Column(
          children: [
            ClipOval(
              child: Image(
                image: AssetImage('assets/oops.jpg'),
                fit: BoxFit.fill,
                height: 200,
                width: 200,
              ),
            ),
            // CircleAvatar(
            //   backgroundImage: AssetImage('assets/oops.jpg'),
            //   radius: 100,
            // ),
            SizedBox(height: 8.0),
            Text(
              'Oops!',
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 12.0),
            logout
                ? InkWell(
                    onTap: () async {
                      await AuthService().signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Wrapper()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    ),
  );
}
