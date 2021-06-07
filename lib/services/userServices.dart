import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:psyscale/classes/User.dart';

class UsersServices {
  final String useruid;
  UsersServices({this.useruid});

  // collection refrence
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // update user data
  Future updateUserData(UserData userData) async {
    return await usersCollection.doc(useruid).update({
      'name': userData.name,
      'email': userData.email,
      'type': userData.type,
      'language': userData.language,
      'theme': userData.theme,
    });
  }

  Future addUserData(UserData userData) async {
    return await usersCollection.doc(useruid).set({
      'name': userData.name,
      'email': userData.email,
      'type': userData.type,
      'language': userData.language,
      'theme': userData.theme,
      'creationDate': Timestamp.now(),
      'lastSignIn': Timestamp.now(),
    });
  }

  // update user hestory
  Future updatelastSignIn() async {
    return await usersCollection.doc(useruid).update({
      'lastSignIn': Timestamp.now(),
    });
  }

  // update user hestory
  Future updateUserHestory(List<Map<String, Object>> hestory) async {
    return await usersCollection.doc(useruid).update({
      'history': hestory,
    });
  }

  updateHestoryList(List<Map<String, Object>> historys, String userUid) {
    String _currentYear = DateFormat(DateFormat.YEAR).format(DateTime.now());
    String _currentMonth = DateFormat(DateFormat.MONTH).format(DateTime.now());
    historys.forEach((element) {
      if (DateFormat(DateFormat.MONTH).format(element['date']) ==
              _currentMonth &&
          DateFormat(DateFormat.YEAR).format(element['date']) != _currentYear) {
        historys.remove(element);
        UsersServices(useruid: userUid).updateUserHestory(historys);
      }
    });
  }

  // user data from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: useruid,
      name: snapshot.data()['name'],
      email: snapshot.data()['email'],
      type: snapshot.data()['type'],
      language: snapshot.data()['language'],
      theme: snapshot.data()['theme'],
      creationDate: snapshot.data()['creationDate'],
      lastSignIn: snapshot.data()['lastSignIn'],
      history: snapshot.data().containsKey('history')
          ? UserData.getList(snapshot.data()['history'])
          : null,
    );
  }

  // get current user data stream
  Stream<UserData> get userData {
    return usersCollection.doc(useruid).snapshots().map(_userDataFromSnapshot);
  }

// get all user data stream
  Stream<QuerySnapshot> get allUserData {
    return usersCollection.snapshots();
  }
}
