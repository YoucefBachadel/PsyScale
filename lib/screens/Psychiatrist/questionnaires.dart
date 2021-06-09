import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Psychiatrist/quiz.dart';
import 'package:psyscale/services/questionnaireServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/customSplashFactory.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class Questionnaires extends StatefulWidget {
  final ValueListenable<String> search;

  const Questionnaires({Key key, this.search}) : super(key: key);
  @override
  _QuestionnairesState createState() => _QuestionnairesState();
}

class _QuestionnairesState extends State<Questionnaires> {
  List<Questionnaire> allQuestionnaires = [];
  List<Questionnaire> questionnaires = [];
  String clickedQuestionnaire = '';

  getQuestionnairesList(QuerySnapshot data, String language) async {
    allQuestionnaires.clear();
    questionnaires.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        allQuestionnaires.add(Questionnaire(
          uid: doc.id,
          troubleUid: doc['troubleUid'],
          type: doc['type'],
          nameEn: doc['nameEn'],
          nameFr: doc['nameFr'],
          nameAr: doc['nameAr'],
          descreptionEn: doc['descreptionEn'],
          descreptionFr: doc['descreptionFr'],
          descreptionAr: doc['descreptionAr'],
          questions: doc['type'] == '1'
              ? Questionnaire.getList(doc['questions'])
              : null,
          answers:
              doc['type'] == '1' ? Questionnaire.getList(doc['answers']) : null,
          questionsAnswers: doc['type'] == '2'
              ? Questionnaire.getQuestionAnswerList(doc['questionsAnswers'])
              : null,
          evaluations: Questionnaire.getList(doc['evaluations']),
        ));
      });
      allQuestionnaires.forEach((element) {
        if (element
            .getName(language)
            .toLowerCase()
            .contains(widget.search.value)) {
          if (element.uid == clickedQuestionnaire) {
            element.isExpanded = true;
          }
          questionnaires.add(element);
        }
      });

      questionnaires
          .sort((a, b) => a.getName(language).compareTo(b.getName(language)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return StreamBuilder(
        stream: QuestionnairesServices().questionnaireData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            QuerySnapshot data = snapshot.data;
            getQuestionnairesList(data, userData.language);

            return Responsive.isdesktop(context)
                ? desktopWidget(Container(), Container(), questionnaireList())
                : questionnaireList();
          } else {
            return loading(context);
          }
        });
  }

  Widget questionnaireList() {
    final userData = Provider.of<UserData>(context);
    return questionnaires.isEmpty
        ? emptyList()
        : Container(
            color: Theme.of(context).backgroundColor,
            height: double.infinity,
            child: ListView(
              children: questionnaires
                  .map((questionnaire) => Card(
                        color: Constants.border,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                            side:
                                BorderSide(color: Constants.border, width: 2.0),
                            borderRadius: BorderRadius.circular(15.0)),
                        elevation: 2.0,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              clickedQuestionnaire == ''
                                  ? clickedQuestionnaire = questionnaire.uid
                                  : clickedQuestionnaire == questionnaire.uid
                                      ? clickedQuestionnaire = ''
                                      : clickedQuestionnaire =
                                          questionnaire.uid;
                            });
                          },
                          splashColor: Theme.of(context).accentColor,
                          splashFactory: CustomSplashFactory(),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  questionnaire.getName(userData.language),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${questionnaire.getQuestionsCount()} questions',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                          color: Constants.myGrey,
                                          fontWeight: FontWeight.w300),
                                ),
                              ),
                              questionnaire.isExpanded
                                  ? Container(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        questionnaire
                                            .getDescreption(userData.language),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(color: Colors.white),
                                      ),
                                    )
                                  : SizedBox(),
                              questionnaire.isExpanded
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 50.0),
                                      child: InkWell(
                                        onTap: () {
                                          Constants.navigationFunc(
                                              context,
                                              Quiz(
                                                questionnaire: questionnaire,
                                                type: 'screening',
                                                languge: userData.language,
                                                history: userData.history,
                                                userUid: userData.uid,
                                              ));
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).accentColor,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          alignment: Alignment.center,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Text(
                                            'Start Test',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
  }
}
