import 'package:psyscale/classes/Questionnaire.dart';

class Trouble {
  String uid;
  String nameEn;
  String nameFr;
  String nameAr;
  String imageUrl;
  int questionnaresCount;
  int hybridesCount;
  String descreptionEn;
  String descreptionFr;
  String descreptionAr;
  bool isExpanded;
  List<Questionnaire> questionnaires = [];
  List<Questionnaire> hybrids = [];

  Trouble(
      {this.uid,
      this.nameEn,
      this.nameFr,
      this.nameAr,
      this.imageUrl,
      this.questionnaresCount,
      this.hybridesCount,
      this.descreptionEn,
      this.descreptionFr,
      this.descreptionAr,
      this.questionnaires,
      this.hybrids});

  Trouble.expandable(
      {this.uid,
      this.nameEn,
      this.nameFr,
      this.nameAr,
      this.imageUrl,
      this.questionnaresCount,
      this.descreptionEn,
      this.descreptionFr,
      this.descreptionAr,
      this.isExpanded = false});
  Trouble.dropDown({
    this.uid,
    this.nameEn,
    this.nameFr,
    this.nameAr,
    this.imageUrl,
  });

  String getName(String language) {
    switch (language) {
      case 'English':
        return this.nameEn;
        break;
      case 'Français':
        return this.nameFr;
        break;
      case 'العربية':
        return this.nameAr;
        break;
    }
    return this.nameEn;
  }

  String getDescreption(String language) {
    switch (language) {
      case 'English':
        return this.descreptionEn;
        break;
      case 'Français':
        return this.descreptionFr;
        break;
      case 'العربية':
        return this.descreptionAr;
        break;
    }
    return this.descreptionEn;
  }
}
