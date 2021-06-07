import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Admin/adminHome.dart';
import 'package:psyscale/screens/Auth/signin.dart';
import 'package:psyscale/screens/Psychiatrist/doctorHome.dart';
import 'package:psyscale/screens/User/userHome.dart';
import 'package:psyscale/services/auth.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/theme_provider.dart';
import 'package:psyscale/shared/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    await DesktopWindow.setMinWindowSize(const Size(600, 800));
  }
  // change the color of navigation button bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Constants.border,
  ));

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<CurrentUser>.value(
      initialData: null,
      value: AuthService().user,
      child: ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          builder: (context, _) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            return MaterialApp(
              themeMode: themeProvider.themeMode,
              theme: MyTheme.lightTheme,
              darkTheme: MyTheme.darkTheme,
              title: 'PsyScale',
              debugShowCheckedModeBanner: false,
              home: WillPopScope(
                onWillPop: () async => false,
                child: Wrapper(),
              ),
            );
          }),
    );
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CurrentUser>(context);

    // return either HomePages or Authenticate widget
    if (user == null) {
      return Responsive.isMobile(context)
          ? UserHome(
              userData: UserData(
                  uid: 'gest',
                  name: '',
                  language: 'English',
                  theme: 'System',
                  history: null),
            )
          : SignIn();
    } else {
      return StreamBuilder<UserData>(
        stream: UsersServices(useruid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            UserData userData = snapshot.data;

            return StreamProvider<UserData>.value(
              initialData: null,
              value: UsersServices(useruid: user.uid).userData,
              child: userData != null
                  ? userData.type == 'admin' || userData.type == 'superAdmin'
                      ? AdminHome()
                      : userData.type == 'doctor'
                          ? DoctorHome()
                          : UserHome(
                              userData: userData,
                            )
                  : Scaffold(body: checkYourNetwork(context)),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return loading(context);
          } else {
            return error();
          }
        },
      );
    }
  }
}
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return StreamProvider<CurrentUser>.value(
//       initialData: null,
//       value: AuthService().user,
//       child: getUserData(context),
//     );
//   }

//   Widget getUserData(BuildContext context) {
//     final user = Provider.of<CurrentUser>(context);
//     if (user == null) {
//       return SignIn();
//     } else {
//       return StreamProvider<UserData>.value(
//         initialData: null,
//         value: UsersServices(useruid: user.uid).userData,
//         child: getThemeProvider(context),
//       );
//     }
//   }

//   Widget getThemeProvider(BuildContext context) {
//     return ChangeNotifierProvider(
//         create: (context) => ThemeProvider(),
//         builder: (context, _) {
//           final themeProvider = Provider.of<ThemeProvider>(context);
//           return MaterialApp(
//             themeMode: themeProvider.themeMode,
//             theme: MyTheme.lightTheme,
//             darkTheme: MyTheme.darkTheme,
//             title: 'PsyScall',
//             debugShowCheckedModeBanner: false,
//             home: WillPopScope(
//               onWillPop: () async => false,
//               child: getHomePageType(context),
//             ),
//           );
//         });
//   }

//   Widget getHomePageType(BuildContext context) {
//     final userData = Provider.of<UserData>(context);
//     return userData.type == 'admin'
//         ? AdminHome()
//         : userData.type == 'doctor'
//             ? DoctorHome()
//             : UserHome();
//   }
// }
