import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser {
  final String uid;
  final String email;

  CurrentUser({this.uid, this.email});
}

class UserData {
  final String uid;
  final String name;
  final String email;
  final int phone;
  final String type;
  final String language;
  final String theme;
  final Timestamp creationDate;
  final Timestamp lastSignIn;
  final bool validated;
  List<Map<String, Object>> history;

  UserData(
      {this.uid,
      this.name,
      this.email,
      this.phone,
      this.type,
      this.language,
      this.theme,
      this.creationDate,
      this.lastSignIn,
      this.validated,
      this.history});

  static List<Map<String, Object>> getList(List<dynamic> list) {
    return list == null
        ? null
        : list.map((item) => Map<String, Object>.from(item)).toList();
  }
}
