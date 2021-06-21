import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/User.dart';
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
            .getName(userData.language)
            .toLowerCase()
            .contains(widget.search.value)) {
          if (element.nameEn == clickedQuestionnaire) {
            element.isExpanded = true;
          } else {
            element.isExpanded = false;
          }
          questionnaires.add(element);
        }
      });

      questionnaires.sort((a, b) =>
          a.getName(userData.language).compareTo(b.getName(userData.language)));
    }
  }

  @override
  Widget build(BuildContext context) {
    getQuestionnairesList();
    return Scaffold(
        body: Responsive.isdesktop(context)
            ? desktopWidget(Container(), Container(), questionnaireList())
            : questionnaireList(),
        floatingActionButton: Responsive.isdesktop(context)
            ? FloatingActionButton(
                heroTag: null,
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  widget.changeTab(index: 1);
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
                                  ? clickedQuestionnaire = questionnaire.nameEn
                                  : clickedQuestionnaire == questionnaire.nameEn
                                      ? clickedQuestionnaire = ''
                                      : clickedQuestionnaire =
                                          questionnaire.nameEn;
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
                                          widget.changeTab(
                                            index: 3,
                                            questionnaire: questionnaire,
                                            language: userData.language,
                                            backIndex: 9,
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
                                            index: 1,
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
