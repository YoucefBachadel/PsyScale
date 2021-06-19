import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/User.dart';

class UsersServices {
  final String useruid;
  UsersServices({this.useruid});

  // collection refrence
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future addUserData(UserData userData, String type) async {
    switch (type) {
      case 'user':
        return await usersCollection.doc(useruid).set({
          'name': userData.name,
          'email': userData.email,
          'type': type,
          'language': userData.language,
          'theme': userData.theme,
          'creationDate': Timestamp.now(),
          'lastSignIn': Timestamp.now(),
          'imageUrl': 'avatar.png',
        });
      case 'doctor':
        return await usersCollection.doc(useruid).set({
          'name': userData.name,
          'clinicName': userData.clinicName,
          'email': userData.email,
          'type': type,
          'language': userData.language,
          'theme': userData.theme,
          'phone': userData.phone,
          'creationDate': Timestamp.now(),
          'lastSignIn': Timestamp.now(),
          'validated': false,
          'imageUrl': 'avatar.png',
        });
      case 'admin':
      case 'superAdmin':
        return await usersCollection.doc(useruid).set({
          'name': userData.name,
          'email': userData.email,
          'type': type,
          'language': userData.language,
          'theme': userData.theme,
          'creationDate': Timestamp.now(),
          'lastSignIn': Timestamp.now(),
          'imageUrl': 'avatar.png',
        });
      default:
        return null;
    }
  }

  // update user data
  Future updateUserData(UserData userData, String type) async {
    switch (type) {
      case 'user':
        return await usersCollection.doc(useruid).update({
          'name': userData.name,
          'email': userData.email,
          'language': userData.language,
          'theme': userData.theme,
          'imageUrl': userData.imageUrl,
        });
      case 'doctor':
        return await usersCollection.doc(useruid).update({
          'name': userData.name,
          'clinicName': userData.clinicName,
          'email': userData.email,
          'language': userData.language,
          'theme': userData.theme,
          'phone': userData.phone,
          'imageUrl': userData.imageUrl,
        });
      case 'admin':
        return await usersCollection.doc(useruid).update({
          'name': userData.name,
          'email': userData.email,
          'language': userData.language,
          'theme': userData.theme,
          'imageUrl': userData.imageUrl,
        });
      default:
        return null;
    }
  }

  // update doctor validation
  Future validateDoctor(String uid) async {
    return await usersCollection.doc(uid).update({
      'validated': true,
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

// this function delete the history item of the same month in the past year
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

  // update user hestory
  Future updatePersonnalQuestionnaires(
      List<Questionnaire> personalQuestionnaires) async {
    List<dynamic> result = [];
    personalQuestionnaires.forEach((element) {
      List<Map<String, Object>> _questionsAnswersMap = [];
      if (element.questionsAnswers != null &&
          element.questionsAnswers.isNotEmpty) {
        element.questionsAnswers.forEach((item) {
          _questionsAnswersMap.add({
            'questionEn': item.questionEn,
            'questionFr': item.questionFr,
            'questionAr': item.questionAr,
            'answers': item.answers,
          });
        });
      }
      result.add({
        'type': element.type,
        'troubleUid': element.troubleUid,
        'nameEn': element.nameEn,
        'nameFr': element.nameFr,
        'nameAr': element.nameAr,
        'descreptionEn': element.descreptionEn,
        'descreptionFr': element.descreptionFr,
        'descreptionAr': element.descreptionAr,
        'questions': element.questions,
        'answers': element.answers,
        'questionsAnswers': _questionsAnswersMap,
        'evaluations': element.evaluations,
      });
    });
    return await usersCollection.doc(useruid).update({
      'personalQuestionnaires': result,
    });
  }

  Future updatePersonnalHybrids(List<Questionnaire> personalHybrids) async {
    List<dynamic> result = [];
    personalHybrids.forEach((element) {
      List<Map<String, Object>> _questionsAnswersMap = [];
      element.questionsAnswers.forEach((item) {
        _questionsAnswersMap.add({
          'questionEn': item.questionEn,
          'questionFr': item.questionFr,
          'questionAr': item.questionAr,
          'answers': item.answers,
        });
      });

      result.add({
        'troubleUid': element.troubleUid,
        'nameEn': element.nameEn,
        'nameFr': element.nameFr,
        'nameAr': element.nameAr,
        'descreptionEn': element.descreptionEn,
        'descreptionFr': element.descreptionFr,
        'descreptionAr': element.descreptionAr,
        'stockageUrl': element.stockageUrl,
        'classes': element.classes,
        'questionsAnswers': _questionsAnswersMap,
      });
    });

    return await usersCollection.doc(useruid).update({
      'personalHybrids': result,
    });
  }

  // user data from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    return UserData(
      uid: useruid,
      user: _auth.currentUser,
      name: snapshot.data()['name'],
      email: snapshot.data()['email'],
      type: snapshot.data()['type'],
      language: snapshot.data()['language'],
      theme: snapshot.data()['theme'],
      imageUrl: snapshot.data()['imageUrl'],
      creationDate: snapshot.data()['creationDate'],
      lastSignIn: snapshot.data()['lastSignIn'],
      clinicName: snapshot.data().containsKey('clinicName')
          ? snapshot.data()['clinicName']
          : null,
      phone: snapshot.data().containsKey('phone')
          ? snapshot.data()['phone']
          : null,
      validated: snapshot.data().containsKey('validated')
          ? snapshot.data()['validated']
          : false,
      history: snapshot.data().containsKey('history')
          ? UserData.getList(snapshot.data()['history'])
          : null,
      personalQuestionnaires:
          snapshot.data().containsKey('personalQuestionnaires')
              ? UserData.getPersonalQuestionnaires(
                  snapshot.data()['personalQuestionnaires'])
              : null,
      personalHybrids: snapshot.data().containsKey('personalHybrids')
          ? UserData.getPersonalHybrids(snapshot.data()['personalHybrids'])
          : null,
    );
  }

  static Future<Widget> getUserImage(BuildContext context, String path) async {
    try {
      return await FirebaseStorage.instance
          .ref()
          .child(path)
          .getDownloadURL()
          .then((value) => Image.network(
                value.toString(),
                fit: BoxFit.cover,
              ));
    } catch (e) {
      return await FirebaseStorage.instance
          .ref()
          .child('avatar.png')
          .getDownloadURL()
          .then((value) => Image.network(
                value.toString(),
                fit: BoxFit.cover,
              ));
    }
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
