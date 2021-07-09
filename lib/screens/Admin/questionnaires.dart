import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/questionnaireServices.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/widgets.dart';

class Questionnaires extends StatefulWidget {
  final ValueListenable<String> search;
  final Function changeTab;

  const Questionnaires({Key key, this.search, this.changeTab})
      : super(key: key);
  @override
  _QuestionnairesState createState() => _QuestionnairesState();
}

class _QuestionnairesState extends State<Questionnaires> {
  List<Questionnaire> allQuestionnaires = [];
  final List<Trouble> allTroubles = [];
  List<Questionnaire> questionnaires = [];

  List<bool> troubleExpanded = [];

  getTroublesList(QuerySnapshot data, String language) async {
    allTroubles.clear();
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
        troubleExpanded.add(false);
      });
      allTroubles
          .sort((a, b) => a.getName(language).compareTo(b.getName(language)));
    }
  }

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
            .contains(widget.search.value.toLowerCase())) {
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
    return Scaffold(
        body: StreamBuilder(
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
                        return desktopWidget(
                          Container(),
                          Container(),
                          Container(
                            alignment: questionnaires.isEmpty
                                ? Alignment.center
                                : Alignment.topCenter,
                            color: Theme.of(context).backgroundColor,
                            height: double.infinity,
                            child: CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: _buildPanel(),
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        return loading(context);
                      }
                    });
              } else {
                return loading(context);
              }
            }),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            widget.changeTab(index: 0);
          },
        ));
  }

  Widget _buildPanel() {
    final userData = Provider.of<UserData>(context);
    int index = -1;
    return widget.search.value != ''
        ? questionnaires.isEmpty
            ? emptyList()
            : GridView.count(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 3.0,
                children: questionnaires.map((questionnaire) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.myGrey, width: 1.0),
                        borderRadius: BorderRadius.circular(24.0)),
                    elevation: 2.0,
                    child: InkWell(
                      onTap: () {
                        widget.changeTab(
                            index: 0, questionnaire: questionnaire);
                      },
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(questionnaire.getName(userData.language)),
                        ),
                        subtitle: Text(
                          questionnaire.getDescreption(userData.language),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
        : ExpansionPanelList(
            animationDuration:
                Duration(milliseconds: Constants.animationDuration),
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                troubleExpanded[panelIndex] = !isExpanded;
              });
            },
            children: allTroubles.map((Trouble trouble) {
              index++;
              List<Questionnaire> _localQuestionnaires = [];
              questionnaires.forEach((questionnaire) {
                if (questionnaire.troubleUid == trouble.uid) {
                  _localQuestionnaires.add(questionnaire);
                }
              });
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      trouble.getName(userData.language),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle:
                        Text('${_localQuestionnaires.length} questionnaires'),
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(trouble.imageUrl)),
                  );
                },
                canTapOnHeader: true,
                isExpanded: troubleExpanded[index],
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: _localQuestionnaires.isEmpty
                        ? emptyList()
                        : GridView.count(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            childAspectRatio: 3.0,
                            children: _localQuestionnaires.map((questionnaire) {
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Constants.myGrey, width: 1.0),
                                    borderRadius: BorderRadius.circular(24.0)),
                                elevation: 2.0,
                                child: InkWell(
                                  onTap: () {
                                    widget.changeTab(
                                        index: 0, questionnaire: questionnaire);
                                  },
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(questionnaire
                                          .getName(userData.language)),
                                    ),
                                    subtitle: Text(
                                      questionnaire
                                          .getDescreption(userData.language),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              );
            }).toList(),
          );
  }
}
