import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psyscale/classes/Trouble.dart';

class TroublesServices {
// collection refrence
  final CollectionReference troublesCollection =
      FirebaseFirestore.instance.collection('troubles');

// get collection refrence
  CollectionReference getCollectionReference() => troublesCollection;

// add trouble data
  Future addTroubleData(Trouble trouble) async {
    return await troublesCollection.add({
      'nameEn': trouble.nameEn,
      'nameFr': trouble.nameFr,
      'nameAr': trouble.nameAr,
      'imageUrl': trouble.imageUrl,
      'questionnaresCount': trouble.questionnaresCount,
      'descreptionEn': trouble.descreptionEn,
      'descreptionFr': trouble.descreptionFr,
      'descreptionAr': trouble.descreptionAr,
    });
  }

  // update trouble data
  Future updateTroubleData(Trouble trouble) async {
    return await troublesCollection.doc(trouble.uid).update({
      'nameEn': trouble.nameEn,
      'nameFr': trouble.nameFr,
      'nameAr': trouble.nameAr,
      'imageUrl': trouble.imageUrl,
      'questionnaresCount': trouble.questionnaresCount,
      'descreptionEn': trouble.descreptionEn,
      'descreptionFr': trouble.descreptionFr,
      'descreptionAr': trouble.descreptionAr,
    });
  }

  //  delete trouble data
  Future deleteTrouble(String uid) {
    return troublesCollection
        .doc(uid)
        .delete()
        .catchError((error) => print("Failed to delete trouble: $error"));
  }

  // get user data stream
  Stream<QuerySnapshot> get troubleData {
    return troublesCollection.snapshots();
  }
}
