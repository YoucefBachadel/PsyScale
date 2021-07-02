import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psyscale/classes/Questionnaire.dart';

class QuestionnairesServices {
// collection refrence
  final CollectionReference questionnairesCollection =
      FirebaseFirestore.instance.collection('questionnaires');

// get collection refrence
  CollectionReference getCollectionReference() => questionnairesCollection;

// add questionnaire data
  Future addQuestionnaireData(Questionnaire questionnaire) async {
    List<Map<String, Object>> _questionsAnswersMap = [];
    if (questionnaire.questionsAnswers.isNotEmpty) {
      questionnaire.questionsAnswers.forEach((element) {
        _questionsAnswersMap.add({
          'questionEn': element.questionEn,
          'questionFr': element.questionFr,
          'questionAr': element.questionAr,
          'answers': element.answers,
        });
      });
    }
    return await questionnairesCollection.add({
      'type': questionnaire.type,
      'troubleUid': questionnaire.troubleUid,
      'nameEn': questionnaire.nameEn,
      'nameFr': questionnaire.nameFr,
      'nameAr': questionnaire.nameAr,
      'defaultLanguage': questionnaire.defaultLanguage,
      'supportedLanguages': questionnaire.supportedLanguages,
      'descreptionEn': questionnaire.descreptionEn,
      'descreptionFr': questionnaire.descreptionFr,
      'descreptionAr': questionnaire.descreptionAr,
      'questions': questionnaire.questions,
      'answers': questionnaire.answers,
      'questionsAnswers': _questionsAnswersMap,
      'evaluations': questionnaire.evaluations,
    });
  }

  // update questionnaire data
  Future updateQuestionnaireData(Questionnaire questionnaire) async {
    List<Map<String, Object>> _questionsAnswersMap = [];
    if (questionnaire.questionsAnswers != null &&
        questionnaire.questionsAnswers.isNotEmpty) {
      questionnaire.questionsAnswers.forEach((element) {
        _questionsAnswersMap.add({
          'questionEn': element.questionEn,
          'questionFr': element.questionFr,
          'questionAr': element.questionAr,
          'answers': element.answers,
        });
      });
    }
    return await questionnairesCollection.doc(questionnaire.uid).update({
      'nameEn': questionnaire.nameEn,
      'nameFr': questionnaire.nameFr,
      'nameAr': questionnaire.nameAr,
      'defaultLanguage': questionnaire.defaultLanguage,
      'supportedLanguages': questionnaire.supportedLanguages,
      'descreptionEn': questionnaire.descreptionEn,
      'descreptionFr': questionnaire.descreptionFr,
      'descreptionAr': questionnaire.descreptionAr,
      'questions': questionnaire.questions,
      'answers': questionnaire.answers,
      'questionsAnswers': _questionsAnswersMap,
      'evaluations': questionnaire.evaluations,
    });
  }

  //  delete questionnaire data
  Future deleteQuestionnaire(String uid) {
    return questionnairesCollection
        .doc(uid)
        .delete()
        .catchError((error) => print("Failed to delete questionnaire: $error"));
  }

  // get user data stream
  Stream<QuerySnapshot> get questionnaireData {
    return questionnairesCollection.snapshots();
  }
}
