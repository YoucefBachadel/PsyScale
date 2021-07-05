import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/doctor/quizQuesionnaire.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/customSplashFactory.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class QuestionnairesPersonal extends StatefulWidget {
  final ValueListenable<String> search;
  final Function changeTab;

  const QuestionnairesPersonal({Key key, this.search, this.changeTab})
      : super(key: key);
  @override
  _QuestionnairesPersonalState createState() => _QuestionnairesPersonalState();
}

class _QuestionnairesPersonalState extends State<QuestionnairesPersonal> {
  List<Questionnaire> questionnaires = [];
  String clickedQuestionnaire = '';

  getQuestionnairesList() async {
    final userData = Provider.of<UserData>(context);
    questionnaires.clear();
    if (userData.personalQuestionnaires != null) {
      userData.personalQuestionnaires.forEach((element) {
        if (element
            .getName(element.defaultLanguage)
            .toLowerCase()
            .contains(widget.search.value)) {
          if (element.getName(element.defaultLanguage) ==
              clickedQuestionnaire) {
            element.isExpanded = true;
          } else {
            element.isExpanded = false;
          }
          questionnaires.add(element);
        }
      });

      questionnaires.sort((a, b) =>
          a.getName(a.defaultLanguage).compareTo(b.getName(b.defaultLanguage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    getQuestionnairesList();
    return Scaffold(
        body: !Responsive.isMobile(context)
            ? desktopWidget(Container(), Container(), questionnaireList())
            : questionnaireList(),
        floatingActionButton: !Responsive.isMobile(context)
            ? FloatingActionButton(
                heroTag: null,
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  widget.changeTab(index: 0);
                },
              )
            : null);
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
                                  ? clickedQuestionnaire = questionnaire
                                      .getName(questionnaire.defaultLanguage)
                                  : clickedQuestionnaire ==
                                          questionnaire.getName(
                                              questionnaire.defaultLanguage)
                                      ? clickedQuestionnaire = ''
                                      : clickedQuestionnaire =
                                          questionnaire.getName(
                                              questionnaire.defaultLanguage);
                            });
                          },
                          splashColor: Theme.of(context).accentColor,
                          splashFactory: CustomSplashFactory(),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  questionnaire.getName(questionnaire
                                          .supportedLanguages
                                          .contains(userData.language)
                                      ? userData.language
                                      : questionnaire.defaultLanguage),
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
                                        questionnaire.getDescreption(
                                            questionnaire.supportedLanguages
                                                    .contains(userData.language)
                                                ? userData.language
                                                : questionnaire
                                                    .defaultLanguage),
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
                                          if (Responsive.isMobile(context)) {
                                            Constants.navigationFunc(
                                              context,
                                              QuizQuestionnaire(
                                                questionnaire: questionnaire,
                                              ),
                                            );
                                          } else {
                                            widget.changeTab(
                                              index: 2,
                                              questionnaire: questionnaire,
                                              language: userData.language,
                                              backIndex: 8,
                                            );
                                          }
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
                              questionnaire.isExpanded &&
                                      Responsive.isdesktop(context)
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 50.0),
                                      child: InkWell(
                                        onTap: () {
                                          widget.changeTab(
                                            index: 0,
                                            questionnaire: questionnaire,
                                          );
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
                                            'Update Questionnaire',
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
