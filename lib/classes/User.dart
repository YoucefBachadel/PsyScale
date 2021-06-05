import 'package:firebase_auth/firebase_auth.dart';

class CurrentUser {
  final String uid;
  final String email;

  CurrentUser({this.uid, this.email});
}

class UserData {
  final String uid;
  User user;
  final String name;
  final String type;
  final String language;
  final String theme;
  final List<Map<String, Object>> history;

  UserData(
      {this.uid,
      this.user,
      this.name,
      this.type,
      this.language,
      this.theme,
      this.history});

  static List<Map<String, Object>> getList(List<dynamic> list) {
    return list == null
        ? null
        : list.map((item) => Map<String, Object>.from(item)).toList();
  }
}
