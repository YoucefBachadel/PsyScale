import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psyscale/classes/Questionnaire.dart';

class HybridServices {
// collection refrence
  final CollectionReference hybridsCollection =
      FirebaseFirestore.instance.collection('hybrids');

// get collection refrence
  CollectionReference getCollectionReference() => hybridsCollection;

// add questionnaire data
  Future addHybridData(Questionnaire questionnaire) async {
    List<Map<String, Object>> _questionsAnswersMap = [];

    questionnaire.questionsAnswers.forEach((element) {
      _questionsAnswersMap.add({
        'questionEn': element.questionEn,
        'questionFr': element.questionFr,
        'questionAr': element.questionAr,
        'answers': element.answers,
      });
    });

    return await hybridsCollection.add({
      'troubleUid': questionnaire.troubleUid,
      'nameEn': questionnaire.nameEn,
      'nameFr': questionnaire.nameFr,
      'nameAr': questionnaire.nameAr,
      'descreptionEn': questionnaire.descreptionEn,
      'descreptionFr': questionnaire.descreptionFr,
      'descreptionAr': questionnaire.descreptionAr,
      'stockageUrl': questionnaire.stockageUrl,
      'classes': questionnaire.classes,
      'questionsAnswers': _questionsAnswersMap,
    });
  }

  // update questionnaire data
  Future updateHybridData(Questionnaire questionnaire) async {
    List<Map<String, Object>> _questionsAnswersMap = [];

    questionnaire.questionsAnswers.forEach((element) {
      _questionsAnswersMap.add({
        'questionEn': element.questionEn,
        'questionFr': element.questionFr,
        'questionAr': element.questionAr,
        'answers': element.answers,
      });
    });

    return await hybridsCollection.doc(questionnaire.uid).update({
      'nameEn': questionnaire.nameEn,
      'nameFr': questionnaire.nameFr,
      'nameAr': questionnaire.nameAr,
      'descreptionEn': questionnaire.descreptionEn,
      'descreptionFr': questionnaire.descreptionFr,
      'descreptionAr': questionnaire.descreptionAr,
      'classes': questionnaire.classes,
      'questionsAnswers': _questionsAnswersMap,
    });
  }

  //  delete questionnaire data
  Future deleteHybrid(String uid) {
    return hybridsCollection
        .doc(uid)
        .delete()
        .catchError((error) => print("Failed to delete hybrid: $error"));
  }

  // get user data stream
  Stream<QuerySnapshot> get hybridData {
    return hybridsCollection.snapshots();
  }
}
