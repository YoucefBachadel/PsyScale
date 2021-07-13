import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/doctor/quizHybrid.dart';
import 'package:psyscale/services/hybridServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class Hybrids extends StatefulWidget {
  final ValueListenable<String> search;
  final Function changeTab;

  const Hybrids({Key key, this.search, this.changeTab}) : super(key: key);
  @override
  _HybridsState createState() => _HybridsState();
}

class _HybridsState extends State<Hybrids> {
  List<Questionnaire> allQuestionnaires = [];
  List<Questionnaire> questionnaires = [];
  List<bool> troubleExpanded = [];

  getQuestionnairesList(QuerySnapshot data, String language) async {
    allQuestionnaires.clear();
    questionnaires.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        allQuestionnaires.add(Questionnaire(
            uid: doc.id,
            troubleUid: doc['troubleUid'],
            nameEn: doc['nameEn'],
            nameFr: doc['nameFr'],
            nameAr: doc['nameAr'],
            defaultLanguage: doc['defaultLanguage'],
            supportedLanguages:
                Questionnaire.getStringList(doc['supportedLanguages']),
            descreptionEn: doc['descreptionEn'],
            descreptionFr: doc['descreptionFr'],
            descreptionAr: doc['descreptionAr'],
            stockageUrl: doc['stockageUrl'],
            classes: Questionnaire.getList(doc['classes']),
            questionsAnswers:
                Questionnaire.getQuestionAnswerList(doc['questionsAnswers'])));
      });
      allQuestionnaires.forEach((element) {
        if (element
            .getName(language)
            .toLowerCase()
            .contains(widget.search.value.toLowerCase())) {
          questionnaires.add(element);
          troubleExpanded.add(false);
        }
      });

      questionnaires
          .sort((a, b) => a.getName(language).compareTo(b.getName(language)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      body: StreamBuilder(
          stream: HybridServices().hybridData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              QuerySnapshot data = snapshot.data;
              getQuestionnairesList(data, userData.language);

              return !Responsive.isMobile(context)
                  ? desktopWidget(
                      Container(),
                      Container(),
                      Container(
                        alignment: questionnaires.isEmpty
                            ? Alignment.center
                            : Alignment.topCenter,
                        color: Theme.of(context).backgroundColor,
                        height: double.infinity,
                        child: buildPanel(),
                      ),
                    )
                  : buildPanel();
            } else {
              return loading(context);
            }
          }),
    );
  }

  Widget buildPanel() {
    final userData = Provider.of<UserData>(context);
    int index = -1;
    return questionnaires.isEmpty
        ? emptyList()
        : Container(
            color: Theme.of(context).backgroundColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ExpansionPanelList(
                    animationDuration:
                        Duration(milliseconds: Constants.animationDuration),
                    expansionCallback: (panelIndex, isExpanded) {
                      setState(() {
                        troubleExpanded[panelIndex] = !isExpanded;
                      });
                    },
                    children: questionnaires.map((Questionnaire questionnaire) {
                      index++;
                      return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(
                              questionnaire.getName(userData.language),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            subtitle: Text(
                              '${questionnaire.getQuestionsCount()} questions',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(fontWeight: FontWeight.w300),
                            ),
                          );
                        },
                        canTapOnHeader: true,
                        isExpanded: troubleExpanded[index],
                        body: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                questionnaire.getDescreption(userData.language),
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 50.0),
                                child: InkWell(
                                  onTap: () {
                                    if (Responsive.isMobile(context)) {
                                      Constants.navigationFunc(
                                        context,
                                        QuizHybrid(
                                          questionnaire: questionnaire,
                                        ),
                                      );
                                    } else {
                                      widget.changeTab(
                                        index: 3,
                                        questionnaire: questionnaire,
                                        language: userData.language,
                                        backIndex: 7,
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).accentColor,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      'Start Test',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }
}
