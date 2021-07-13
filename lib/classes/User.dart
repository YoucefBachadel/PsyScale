import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:psyscale/classes/Questionnaire.dart';

class CurrentUser {
  final String uid;
  final String email;

  CurrentUser({this.uid, this.email});
}

class UserData {
  final String uid;
  final User user;
  final String name;
  final String clinicName;
  final String email;
  final String phone;
  final String type;
  final String language;
  final Timestamp creationDate;
  final Timestamp lastSignIn;
  bool validated;
  List<Map<String, Object>> history;
  List<Questionnaire> personalQuestionnaires;
  List<Questionnaire> personalHybrids;

  UserData(
      {this.uid,
      this.name,
      this.user,
      this.clinicName,
      this.email,
      this.phone,
      this.type,
      this.language,
      this.creationDate,
      this.lastSignIn,
      this.validated,
      this.history,
      this.personalQuestionnaires,
      this.personalHybrids});

  // tronsform List<dynamic> to List<Map<String, Object>>
  static List<Map<String, Object>> getList(List<dynamic> list) {
    return list == null
        ? null
        : list.map((item) => Map<String, Object>.from(item)).toList();
  }

  // get list of personal questionnaires for doctor account
  static List<Questionnaire> getPersonalQuestionnaires(List<dynamic> list) {
    List<Questionnaire> result = [];
    if (list != null) {
      list.map((item) {
        result.add(Questionnaire(
          troubleUid: item['troubleUid'],
          type: item['type'],
          nameEn: item['nameEn'],
          nameFr: item['nameFr'],
          nameAr: item['nameAr'],
          defaultLanguage: item['defaultLanguage'],
          supportedLanguages:
              Questionnaire.getStringList(item['supportedLanguages']),
          descreptionEn: item['descreptionEn'],
          descreptionFr: item['descreptionFr'],
          descreptionAr: item['descreptionAr'],
          questions: item['type'] == '1'
              ? Questionnaire.getList(item['questions'])
              : null,
          answers: item['type'] == '1'
              ? Questionnaire.getList(item['answers'])
              : null,
          questionsAnswers: item['type'] == '2'
              ? Questionnaire.getQuestionAnswerList(item['questionsAnswers'])
              : null,
          evaluations: Questionnaire.getList(item['evaluations']),
        ));
      }).toList();
    }
    return result;
  }

  // get list of personal hybrid questionnaires for doctor account
  static List<Questionnaire> getPersonalHybrids(List<dynamic> list) {
    List<Questionnaire> result = [];
    if (list != null) {
      list.map((item) {
        result.add(Questionnaire(
            troubleUid: item['troubleUid'],
            nameEn: item['nameEn'],
            nameFr: item['nameFr'],
            nameAr: item['nameAr'],
            defaultLanguage: item['defaultLanguage'],
            supportedLanguages:
                Questionnaire.getStringList(item['supportedLanguages']),
            descreptionEn: item['descreptionEn'],
            descreptionFr: item['descreptionFr'],
            descreptionAr: item['descreptionAr'],
            classes: Questionnaire.getList(item['classes']),
            stockageUrl: item['stockageUrl'],
            questionsAnswers:
                Questionnaire.getQuestionAnswerList(item['questionsAnswers'])));
      }).toList();
    }
    return result;
  }
}
