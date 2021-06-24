import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/doctor/trouble_details.dart';
import 'package:psyscale/services/hybridServices.dart';
import 'package:psyscale/services/questionnaireServices.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class Troubles extends StatefulWidget {
  final ValueListenable<String> search;
  final Function changeTab;
  const Troubles({Key key, this.search, this.changeTab}) : super(key: key);
  @override
  _TroublesState createState() => _TroublesState();
}

class _TroublesState extends State<Troubles> {
  List<Trouble> allTroubles = [];
  List<Trouble> troubles = [];
  List<Questionnaire> questionnaires = [];
  List<Questionnaire> hybrids = [];
  String clickedQuestionnaire = '';

  getTroublesList(QuerySnapshot data, String language) async {
    allTroubles.clear();
    troubles.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        allTroubles.add(Trouble(
          uid: doc.id,
          nameEn: doc['nameEn'],
          nameFr: doc['nameFr'],
          nameAr: doc['nameAr'],
          questionnaresCount: doc['questionnaresCount'],
          descreptionEn: doc['descreptionEn'],
          descreptionFr: doc['descreptionFr'],
          descreptionAr: doc['descreptionAr'],
          imageUrl: doc['imageUrl'],
        ));
      });
      allTroubles.forEach((element) {
        if (element
            .getName(language)
            .toLowerCase()
            .contains(widget.search.value.toLowerCase())) {
          troubles.add(element);
        }
      });
      troubles
          .sort((a, b) => a.getName(language).compareTo(b.getName(language)));
    }
  }

  getQuestionnairesList(QuerySnapshot data, String language) async {
    questionnaires.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        questionnaires.add(Questionnaire(
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
      questionnaires.forEach((element) {
        if (element.uid == clickedQuestionnaire) {
          element.isExpanded = true;
        }
      });
    }
  }

  getHybridsList(QuerySnapshot data, String language) async {
    hybrids.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        hybrids.add(Questionnaire(
            uid: doc.id,
            troubleUid: doc['troubleUid'],
            nameEn: doc['nameEn'],
            nameFr: doc['nameFr'],
            nameAr: doc['nameAr'],
            descreptionEn: doc['descreptionEn'],
            descreptionFr: doc['descreptionFr'],
            descreptionAr: doc['descreptionAr'],
            stockageUrl: doc['stockageUrl'],
            classes: Questionnaire.getList(doc['classes']),
            questionsAnswers:
                Questionnaire.getQuestionAnswerList(doc['questionsAnswers'])));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return StreamBuilder(
        stream: TroublesServices().troubleData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            QuerySnapshot data = snapshot.data;
            getTroublesList(data, userData.language);
            return StreamBuilder(
                stream: QuestionnairesServices().questionnaireData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot data = snapshot.data;
                    getQuestionnairesList(data, userData.language);
                    return StreamBuilder(
                        stream: HybridServices().hybridData,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            QuerySnapshot data = snapshot.data;
                            getHybridsList(data, userData.language);

                            return Responsive.isdesktop(context)
                                ? desktopWidget(
                                    Container(), Container(), troublesList())
                                : troublesList();
                          } else {
                            return loading(context);
                          }
                        });
                  } else {
                    return loading(context);
                  }
                });
          } else {
            return loading(context);
          }
        });
  }

  Widget troublesList() {
    final userData = Provider.of<UserData>(context);
    return troubles.isEmpty
        ? emptyList()
        : Material(
            color: Theme.of(context).backgroundColor,
            child: GridView.count(
              crossAxisCount: Responsive.isMobile(context) ? 1 : 2,
              childAspectRatio: 1.8,
              children: troubles.map(
                (trouble) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.border, width: 0.5),
                        borderRadius: BorderRadius.circular(15.0)),
                    elevation: 2.0,
                    child: InkWell(
                      // splashFactory: CustomSplashFactory(),
                      // splashColor: Theme.of(context).accentColor,
                      onTap: () async {
                        trouble.questionnaires = [];
                        questionnaires.forEach((questionnaire) {
                          if (questionnaire.troubleUid == trouble.uid) {
                            trouble.questionnaires.add(questionnaire);
                          }
                        });
                        trouble.hybrids = [];
                        hybrids.forEach((hybrid) {
                          if (hybrid.troubleUid == trouble.uid) {
                            trouble.hybrids.add(hybrid);
                          }
                        });
                        if (Responsive.isMobile(context)) {
                          Constants.navigationFunc(
                            context,
                            TroubleDetails(
                              trouble: trouble,
                              language: userData.language,
                            ),
                          );
                        } else {
                          widget.changeTab(
                            index: 4,
                            trouble: trouble,
                            language: userData.language,
                          );
                        }
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Hero(
                                  tag: trouble.imageUrl,
                                  child:
                                      loadingImage(context, trouble.imageUrl),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Constants.border,
                                      ],
                                      stops: [0.5, 1],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      tileMode: TileMode.repeated,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0.0,
                                  child: Hero(
                                    tag: trouble.getName(userData.language),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        trouble.getName(userData.language),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          );
  }
}
