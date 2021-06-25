import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Admin/adminHome.dart';
import 'package:psyscale/screens/Auth/signin.dart';
import 'package:psyscale/screens/doctor/doctorHome.dart';
import 'package:psyscale/screens/User/userHome.dart';
import 'package:psyscale/services/authenticationServices%20.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/theme_provider.dart';
import 'package:psyscale/shared/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // change the color of navigation button bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Constants.border,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
      child: ChangeNotifierProvider<ThemeProvider>(
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

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool networkConnected = true;

  checkNetworkConnection() async {
    networkConnected =
        await Connectivity().checkConnectivity() != ConnectivityResult.none;
  }

  @override
  void initState() {
    checkNetworkConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (networkConnected) {
      final user = Provider.of<CurrentUser>(context);
      // GoogleSheetApi().fillStudentsSheets();

      // return either HomePages or Authenticate widget
      if (user == null) {
        return Responsive.isMobile(context)
            ? !kIsWeb
                ? UserHome(
                    userData: UserData(
                        uid: 'gest',
                        name: '',
                        language: 'English',
                        history: null),
                  )
                : Material(
                    child: unsupportedScreenSize(
                    context,
                    'The visitor interface is not supported for the web',
                    false,
                  ))
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
                      ? userData.type == 'admin' ||
                              userData.type == 'superAdmin'
                          ? AdminHome()
                          : userData.type == 'doctor'
                              ? userData.validated
                                  ? DoctorHome()
                                  : unsupportedScreenSize(
                                      context,
                                      'It looks like your account hasn\'t been validated yet, please be patient!!',
                                      false,
                                    )
                              : userData.user.emailVerified
                                  ? UserHome(
                                      userData: userData,
                                    )
                                  : unsupportedScreenSize(
                                      context,
                                      'It looks like you haven\'t activated your account yet, please check your email box and activate it!!',
                                      false,
                                    )
                      : checkNetwork(context));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return loading(context);
            } else {
              return error();
            }
          },
        );
      }
    }
    return checkNetwork(context);
  }
}
