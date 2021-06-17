import 'package:connectivity/connectivity.dart';

class ConnectivityStatus {
  ConnectivityStatus() {
    Connectivity().onConnectivityChanged.listen((result) {});
  }
}
