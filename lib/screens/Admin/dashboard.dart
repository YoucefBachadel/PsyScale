import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/hybridServices.dart';
import 'package:psyscale/services/questionnaireServices.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/widgets.dart';

class Dashboard extends StatefulWidget {
  final Function changeTab;
  final UserData userData;
  const Dashboard({key, this.changeTab, this.userData}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _troublesCount;
  int _questionnairesCount;
  int _hybridsCount;
  int _usersCount;
  int _psychiatristsCount;
  int _adminsCount;
  int _superAdminsCount;
  List<Trouble> troubles = [];
  List<Questionnaire> questionnaires = [];
  List<Questionnaire> hybrides = [];
  int _sortColumnIndex = 0;
  bool _isAscending = false;
  String _sortBy = 'Trouble Name';

  getTroublesList(QuerySnapshot data) async {
    troubles.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        troubles.add(Trouble(
          uid: doc.id,
          nameEn: doc['nameEn'],
          nameFr: doc['nameFr'],
          nameAr: doc['nameAr'],
          imageUrl: doc['imageUrl'],
        ));
      });
    }
  }

  getQuestionnairesList(QuerySnapshot data) async {
    questionnaires.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        questionnaires.add(Questionnaire(
          uid: doc.id,
          troubleUid: doc['troubleUid'],
        ));
      });
    }
    troubles.forEach((trouble) {
      trouble.questionnaresCount = 0;
      questionnaires.forEach((questionnaire) {
        if (questionnaire.troubleUid == trouble.uid) {
          trouble.questionnaresCount++;
        }
      });
    });
  }

  getHybridsList(QuerySnapshot data) async {
    hybrides.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        hybrides.add(Questionnaire(
          uid: doc.id,
          troubleUid: doc['troubleUid'],
        ));
      });
    }
    troubles.forEach((trouble) {
      trouble.hybridesCount = 0;
      hybrides.forEach((hybrid) {
        if (hybrid.troubleUid == trouble.uid) {
          trouble.hybridesCount++;
        }
      });
    });
    onSort();
  }

  void onSort() {
    switch (_sortBy) {
      case 'Trouble Name':
        troubles.sort((trouble1, trouble2) {
          return !_isAscending
              ? trouble1
                  .getName(widget.userData.language)
                  .compareTo(trouble2.getName(widget.userData.language))
              : trouble2
                  .getName(widget.userData.language)
                  .compareTo(trouble1.getName(widget.userData.language));
        });
        break;
      case 'Questionnaires':
        troubles.sort((trouble1, trouble2) {
          return !_isAscending
              ? trouble1.questionnaresCount
                  .compareTo(trouble2.questionnaresCount)
              : trouble2.questionnaresCount
                  .compareTo(trouble1.questionnaresCount);
        });
        break;
      case 'Hybrides':
        troubles.sort((trouble1, trouble2) {
          return !_isAscending
              ? trouble1.hybridesCount.compareTo(trouble2.hybridesCount)
              : trouble2.hybridesCount.compareTo(trouble1.hybridesCount);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _troublesCount = 0;
    _questionnairesCount = 0;
    _hybridsCount = 0;

    return Scaffold(
      body: Row(
        children: [
          Flexible(
            flex: 2,
            child: StreamBuilder(
                stream: TroublesServices().troubleData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot data = snapshot.data;
                    _troublesCount = data.docs.length;
                    getTroublesList(data);
                    return StreamBuilder(
                        stream: QuestionnairesServices().questionnaireData,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            QuerySnapshot data = snapshot.data;
                            _questionnairesCount = data.docs.length;
                            getQuestionnairesList(data);
                            return StreamBuilder(
                                stream: HybridServices().hybridData,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    QuerySnapshot data = snapshot.data;
                                    _hybridsCount = data.docs.length;
                                    getHybridsList(data);
                                    return Column(
                                      children: [
                                        Flexible(
                                          flex: 2,
                                          child: ressources(),
                                        ),
                                        Flexible(
                                          flex: 5,
                                          child: troublesDetailes(),
                                        ),
                                      ],
                                    );
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
                }),
          ),
          Flexible(
            child: allUsers(),
          ),
        ],
      ),
    );
  }

  Widget allUsers() {
    return StreamBuilder(
        stream: UsersServices().allUserData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            QuerySnapshot data = snapshot.data;
            _usersCount = 0;
            _psychiatristsCount = 0;
            _adminsCount = 0;
            _superAdminsCount = 0;
            data.docs.forEach((element) {
              switch (element['type']) {
                case 'user':
                  _usersCount++;
                  break;
                case 'doctor':
                  _psychiatristsCount++;
                  break;
                case 'admin':
                  _adminsCount++;
                  break;
                case 'superAdmin':
                  _superAdminsCount++;
                  break;
              }
            });
            return Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Users Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  chart(context),
                  userCardInfo(Icons.supervised_user_circle_rounded, 'Users',
                      _usersCount, Constants.border, 6),
                  userCardInfo(MdiIcons.doctor, 'Doctors', _psychiatristsCount,
                      Color(0xFF26E5FF), 7),
                  userCardInfo(Icons.admin_panel_settings, 'Admins',
                      _adminsCount, Color(0xFFFFCF26), 8),
                  userCardInfo(Icons.add_moderator_outlined, 'Super Admins',
                      _superAdminsCount, Color(0xFFEE2727), 8),
                ],
              ),
            );
          } else {
            return loading(context);
          }
        });
  }

  Widget ressources() {
    List<Map<String, Object>> items = [
      {
        'title': 'Troubles',
        'icon': MdiIcons.brain,
        'count': _troublesCount.toString(),
        'index': 3,
      },
      {
        'title': 'Questionnaires',
        'icon': Icons.format_list_bulleted,
        'count': _questionnairesCount.toString(),
        'index': 4,
      },
      {
        'title': 'Hybrides',
        'icon': Icons.home,
        'count': _hybridsCount.toString(),
        'index': 5,
      }
    ];
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: GridView.count(
        childAspectRatio: 1.5,
        crossAxisSpacing: 16.0,
        children: items
            .map((e) => InkWell(
                  onTap: () {
                    widget.changeTab(e['index'], null);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Constants.border),
                      color: Theme.of(context).primaryColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          leading: Icon(
                            e['icon'],
                            size: 30.0,
                            color: Colors.black,
                          ),
                          title: Text(e['title'],
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Text(e['count'],
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                .copyWith(fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ))
            .toList(),
        crossAxisCount: 3,
      ),
    );
  }

  Widget troublesDetailes() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('List Of Troubles', style: Theme.of(context).textTheme.headline6),
        SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: DataTable(
            sortAscending: _isAscending,
            sortColumnIndex: _sortColumnIndex,
            dataRowHeight: 60.0,
            horizontalMargin: 0,
            columnSpacing: 8.0,
            columns: [
              DataColumn(
                  onSort: (int columnIndex, bool ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _isAscending = ascending;
                      _sortBy = 'Trouble Name';
                    });
                  },
                  label: Text(
                    'Trouble Name',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontWeight: FontWeight.w900),
                  )),
              DataColumn(
                  onSort: (int columnIndex, bool ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _isAscending = ascending;
                      _sortBy = 'Questionnaires';
                    });
                  },
                  label: Text(
                    'Questionnaires',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontWeight: FontWeight.w900),
                  )),
              DataColumn(
                onSort: (int columnIndex, bool ascending) {
                  setState(() {
                    _sortColumnIndex = columnIndex;
                    _isAscending = ascending;
                    _sortBy = 'Hybrides';
                  });
                },
                label: Text(
                  'Hybrides',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
            rows: troubles.map((trouble) {
              int _troubleQuestionnaires = 0;
              int _troubleHybrides = 0;
              questionnaires.forEach((element) {
                if (element.troubleUid == trouble.uid) {
                  _troubleQuestionnaires++;
                }
              });
              hybrides.forEach((element) {
                if (element.troubleUid == trouble.uid) {
                  _troubleHybrides++;
                }
              });
              return DataRow(
                  color: MaterialStateProperty.all(Colors.white),
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(trouble.imageUrl)),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            trouble.getName(widget.userData.language),
                            style: Theme.of(context).textTheme.subtitle2,
                          )
                        ],
                      ),
                    ),
                    DataCell(Text(
                      _troubleQuestionnaires.toString(),
                      style: Theme.of(context).textTheme.headline6,
                    )),
                    DataCell(Text(
                      _troubleHybrides.toString(),
                      style: Theme.of(context).textTheme.headline6,
                    )),
                  ]);
            }).toList(),
          ),
        )
      ]),
    );
  }

  Widget chart(BuildContext context) {
    List<PieChartSectionData> paiChartSelectionDatas = [
      PieChartSectionData(
        color: Constants.border,
        value: _usersCount.toDouble(),
        showTitle: true,
        radius: 33,
      ),
      PieChartSectionData(
        color: Color(0xFF26E5FF),
        value: _psychiatristsCount.toDouble(),
        showTitle: true,
        radius: 30,
      ),
      PieChartSectionData(
        color: Color(0xFFFFCF26),
        value: _adminsCount.toDouble(),
        showTitle: true,
        radius: 27,
      ),
      PieChartSectionData(
        color: Color(0xFFEE2727),
        value: _superAdminsCount.toDouble(),
        showTitle: true,
        radius: 24,
      ),
    ];

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: paiChartSelectionDatas,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 8.0),
                Text(
                  'of ${_usersCount + _psychiatristsCount + _adminsCount + _superAdminsCount}',
                  style: Theme.of(context).textTheme.headline4.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        height: 0.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userCardInfo(
      IconData icon, String title, int numOfUsers, Color color, int tapIndex) {
    return InkWell(
      onTap: () {
        widget.changeTab(tapIndex, null);
      },
      child: Container(
        margin: EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: color),
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 30.0,
            color: color,
          ),
          title: Text(title),
          subtitle: Text(numOfUsers.toString()),
        ),
      ),
    );
  }
}
