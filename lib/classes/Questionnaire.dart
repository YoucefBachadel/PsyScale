import 'package:psyscale/classes/QuestionAnswer.dart';

class Questionnaire {
  String uid;
  String troubleUid;
  String nameEn;
  String nameFr;
  String nameAr;
  String descreptionEn;
  String descreptionFr;
  String descreptionAr;
  String stockageUrl;
  String type;
  List<Map<String, Object>> questions;
  List<Map<String, Object>> answers;
  List<Map<String, Object>> classes;
  List<QuestionAnswer> questionsAnswers;
  List<Map<String, Object>> evaluations;
  bool isExpanded;

  Questionnaire({
    this.uid,
    this.troubleUid,
    this.nameEn,
    this.nameFr,
    this.nameAr,
    this.descreptionEn,
    this.descreptionFr,
    this.descreptionAr,
    this.stockageUrl,
    this.type,
    this.questions,
    this.answers,
    this.classes,
    this.questionsAnswers,
    this.evaluations,
    this.isExpanded = false,
  });

  static List<Map<String, Object>> getList(List<dynamic> list) {
    return list.map((item) => Map<String, Object>.from(item)).toList();
  }

  static List<QuestionAnswer> getQuestionAnswerList(List<dynamic> list) {
    List<QuestionAnswer> result = [];
    List<Map<String, Object>> dynamicList =
        list.map((item) => Map<String, Object>.from(item)).toList();
    dynamicList
        .map((element) => result.add(QuestionAnswer(
              questionEn: element['questionEn'],
              questionFr: element['questionFr'],
              questionAr: element['questionAr'],
              answers: (element['answers'] as List<dynamic>)
                  .map((item) => Map<String, Object>.from(item))
                  .toList(),
            )))
        .toList();
    return result;
  }

  String getName(String languge) {
    switch (languge) {
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

  String getDescreption(String languge) {
    switch (languge) {
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

  int getQuestionsCount() {
    switch (type) {
      case '1':
        return questions.length;
        break;
      case '2':
        return questionsAnswers.length;
        break;
      default:
        return questionsAnswers.length;
    }
  }

  List<String> getQuesionsList(String language) {
    List<String> questions = [];
    String questionLanguage = 'questionEn';

    switch (language) {
      case 'English':
        questionLanguage = 'questionEn';
        break;
      case 'Français':
        questionLanguage = 'questionFr';
        break;
      case 'العربية':
        questionLanguage = 'questionAr';
        break;
    }
    this.questions.forEach((element) {
      questions.add(element[questionLanguage]);
    });
    return questions;
  }

  String getQuesAnsQuestion(String language, int index) {
    switch (language) {
      case 'English':
        return this.questionsAnswers[index].questionEn;
      case 'Français':
        return this.questionsAnswers[index].questionFr;
      case 'العربية':
        return this.questionsAnswers[index].questionAr;
    }
    return this.questionsAnswers[index].questionEn;
  }

  List<Map<String, Object>> getAnswersList(String language, int index) {
    List<Map<String, Object>> _list;
    if (this.type == '1') {
      _list = this.answers;
    } else {
      _list = this.questionsAnswers[index].answers;
    }
    List<Map<String, Object>> answers = [];
    String answerLanguage = 'answerEn';

    switch (language) {
      case 'English':
        answerLanguage = 'answerEn';
        break;
      case 'Français':
        answerLanguage = 'answerFr';
        break;
      case 'العربية':
        answerLanguage = 'answerAr';
        break;
    }
    _list.forEach((element) {
      answers.add({
        'answer': element[answerLanguage],
        'score': element['score'],
      });
    });

    answers.sort((a, b) => (a['score'] as int).compareTo(b['score']));
    return answers;
  }

  List<Map<String, Object>> getHybridsAnswersList(String language, int index) {
    List<Map<String, Object>> _list;
    List<Map<String, Object>> answers = [];
    String answerLanguage;
    if (index == 0) {
      _list = this.classes;
      answerLanguage = 'classEn';
      switch (language) {
        case 'English':
          answerLanguage = 'classEn';
          break;
        case 'Français':
          answerLanguage = 'classFr';
          break;
        case 'العربية':
          answerLanguage = 'classAr';
          break;
      }
    } else {
      _list = this.questionsAnswers[index - 1].answers;
      answerLanguage = 'answerEn';
      switch (language) {
        case 'English':
          answerLanguage = 'answerEn';
          break;
        case 'Français':
          answerLanguage = 'answerFr';
          break;
        case 'العربية':
          answerLanguage = 'answerAr';
          break;
      }
    }

    _list.forEach((element) {
      answers.add({
        'answer': element[answerLanguage],
      });
    });
    return answers;
  }

  List<Map<String, Object>> getEvaluationList(String language) {
    List<Map<String, Object>> evaluations = [];
    String evaluationLanguage = 'messageEn';

    switch (language) {
      case 'English':
        evaluationLanguage = 'messageEn';
        break;
      case 'Français':
        evaluationLanguage = 'messageFr';
        break;
      case 'العربية':
        evaluationLanguage = 'messageAr';
        break;
    }
    this.evaluations.forEach((element) {
      evaluations.add({
        'from': element['from'],
        'to': element['to'],
        'message': element[evaluationLanguage],
      });
    });
    return evaluations;
  }
}
