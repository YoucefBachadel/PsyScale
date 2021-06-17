import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Psychiatrist/add_hybrid.dart';
import 'package:psyscale/screens/Psychiatrist/quiz.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class HybridsPersonal extends StatefulWidget {
  final ValueListenable<String> search;

  const HybridsPersonal({Key key, this.search}) : super(key: key);
  @override
  _HybridsPersonalState createState() => _HybridsPersonalState();
}

class _HybridsPersonalState extends State<HybridsPersonal> {
  List<Questionnaire> questionnaires = [];
  List<bool> troubleExpanded = [];

  getQuestionnairesList() async {
    final userData = Provider.of<UserData>(context);
    questionnaires.clear();
    if (userData.personalHybrids != null) {
      userData.personalHybrids.forEach((element) {
        if (element
            .getName(userData.language)
            .toLowerCase()
            .contains(widget.search.value.toLowerCase())) {
          questionnaires.add(element);
          troubleExpanded.add(false);
        }
      });

      questionnaires.sort((a, b) =>
          a.getName(userData.language).compareTo(b.getName(userData.language)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    getQuestionnairesList();
    return Scaffold(
        body: Responsive.isdesktop(context)
            ? desktopWidget(Container(), Container(), buildPanel())
            : buildPanel(),
        floatingActionButton: Responsive.isdesktop(context)
            ? FloatingActionButton(
                heroTag: null,
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Constants.navigationFunc(
                    context,
                    AddHybrid(
                      questionnaire: null,
                      userData: userData,
                    ),
                  );
                },
              )
            : null);
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
                                    Constants.navigationFunc(
                                        context,
                                        Quiz(
                                          questionnaire: questionnaire,
                                          type: 'dataCollection',
                                          languge: userData.language,
                                          history: userData.history,
                                          userUid: userData.uid,
                                        ));
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
                              Responsive.isdesktop(context)
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 50.0),
                                      child: InkWell(
                                        onTap: () {
                                          Constants.navigationFunc(
                                              context,
                                              AddHybrid(
                                                userData: userData,
                                                questionnaire: questionnaire,
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
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }
}
