import 'package:connectivity/connectivity.dart';

class ConnectivityStatus {
  // check network connection
  ConnectivityStatus() {
    Connectivity().onConnectivityChanged.listen((result) {});
  }
}
