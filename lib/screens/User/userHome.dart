import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psyscale/screens/Auth/signin.dart';
import 'package:psyscale/screens/User/quiz.dart';
import 'package:psyscale/screens/User/trouble_details.dart';
import 'package:psyscale/screens/settings.dart';
import 'package:psyscale/services/questionnaireServices.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/customSplashFactory.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class UserHome extends StatefulWidget {
  final UserData userData;

  const UserHome({Key key, this.userData}) : super(key: key);
  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> with TickerProviderStateMixin {
  List<Trouble> troubles = [];
  List<Trouble> allTroubles = [];
  List<Questionnaire> questionnaires = [];
  List<Questionnaire> allQuestionnaires = [];
  List<Map<String, Object>> historys = [];
  var _scrollController, _tabController, _textFieldController;
  String search = '';

  List<String> tabs = ['Categories', 'All Tests'];

  String clickedQuestionnaire = '';
  bool updatedLastSignIn = false;

  @override
  void initState() {
    if (widget.userData.uid != 'gest' && tabs.length != 3) {
      tabs.add('History');
    }
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: tabs.length);
    _textFieldController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

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
        if (element.getName(language).toLowerCase().contains(search)) {
          troubles.add(element);
        }
      });
      troubles
          .sort((a, b) => a.getName(language).compareTo(b.getName(language)));
    }
  }

  getQuestionnairesList(QuerySnapshot data, String language) {
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
        if (element.getName(language).toLowerCase().contains(search)) {
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

  getHestoryList() {
    historys.clear();
    if (widget.userData.history != null) {
      widget.userData.history.forEach((element) {
        if ((element['name'] as String).toLowerCase().contains(search)) {
          historys.add({
            'name': element['name'],
            'date': (element['date'] as Timestamp).toDate(),
            'score': element['score'],
            'message': element['message'],
          });
          historys.sort((a, b) => (b['date'] as DateTime).compareTo(a['date']));
        }
      });
    }
    UsersServices(useruid: widget.userData.uid)
        .updateHestoryList(historys, widget.userData.uid);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userData != null &&
        !updatedLastSignIn &&
        widget.userData.uid != 'gest') {
      UsersServices(useruid: widget.userData.uid).updatelastSignIn();
      updatedLastSignIn = true;
    }
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Responsive.isMobile(context)
            ? mobileView()
            : kIsWeb
                ? unsupportedScreenSize(
                    context, 'The user interface is not supported on web', true)
                : unsupportedScreenSize(
                    context,
                    'The user interface is not supported in this screen size',
                    false,
                  ));
  }

  Widget mobileView() {
    List<Widget> widgets = [];

    widgets.add(getTroubles());
    widgets.add(getAllQuestionnaires());

    if (widget.userData.uid != 'gest') {
      widgets.add(getHestory());
    }

    return Column(
      children: [
        Expanded(
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 2.0,
                  title: appBar(
                      context,
                      widget.userData.uid == 'gest'
                          ? 'Welcome'
                          : 'Hello ${widget.userData.name}',
                      ''),
                  bottom: PreferredSize(
                      preferredSize: Size.fromHeight(71.0),
                      child: Column(
                        children: [
                          SizedBox(height: 4.0),
                          Material(
                            color: Colors.transparent,
                            elevation: 5.0,
                            child: TextFormField(
                              controller: _textFieldController,
                              decoration:
                                  searchTextInputDecoration(context, () {
                                _textFieldController.clear();
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                setState(() {
                                  search = '';
                                });
                              }),
                              onChanged: (value) {
                                setState(() {
                                  widgets.clear();
                                  search = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 5.0),
                        ],
                      )),
                  actions: [
                    SizedBox(width: 4.0),
                    InkWell(
                        onTap: () {
                          widget.userData.uid == 'gest'
                              ? Constants.navigationFunc(context, SignIn())
                              : createDialog(
                                  context,
                                  Container(
                                      child:
                                          Setting(userData: widget.userData)),
                                  false,
                                );
                        },
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar.jpg'),
                        )),
                    SizedBox(width: 16.0),
                  ],
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: widgets,
            ),
          ),
        ),
        Hero(
          tag: 'tabbar',
          child: Material(
            color: Constants.border,
            child: TabBar(
              indicatorColor: Theme.of(context).accentColor,
              labelColor: Theme.of(context).accentColor,
              unselectedLabelColor: Colors.white,
              tabs: tabs.map((e) => Tab(text: e)).toList(),
              controller: _tabController,
            ),
          ),
        ),
      ],
    );
  }

  Widget getTroubles() {
    return StreamBuilder(
        stream: TroublesServices().troubleData,
        builder: (context, snapshot) {
          QuerySnapshot data = snapshot.data;
          getTroublesList(data, widget.userData.language);

          return StreamBuilder(
              stream: QuestionnairesServices().questionnaireData,
              builder: (context, snapshot) {
                QuerySnapshot data = snapshot.data;
                getQuestionnairesList(data, widget.userData.language);
                questionnaires.sort((a, b) => a
                    .getName(widget.userData.language)
                    .compareTo(b.getName(widget.userData.language)));

                return troubles.isEmpty
                    ? emptyList()
                    : GridView.count(
                        crossAxisCount: Responsive.isMobile(context) ? 1 : 2,
                        childAspectRatio: 1.8,
                        children: troubles.map(
                          (trouble) {
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Constants.border, width: 0.5),
                                  borderRadius: BorderRadius.circular(15.0)),
                              elevation: 2.0,
                              child: InkWell(
                                // splashFactory: CustomSplashFactory(),
                                // splashColor: Theme.of(context).accentColor,
                                onTap: () async {
                                  trouble.questionnaires = [];
                                  questionnaires.forEach((questionnaire) {
                                    if (questionnaire.troubleUid ==
                                        trouble.uid) {
                                      trouble.questionnaires.add(questionnaire);
                                    }
                                  });
                                  Constants.navigationFunc(
                                    context,
                                    TroubleDetails(
                                      trouble: trouble,
                                      userData: widget.userData,
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Hero(
                                            tag: trouble.imageUrl,
                                            child: loadingImage(
                                                context, trouble.imageUrl),
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
                                              tag: trouble.getName(
                                                  widget.userData.language),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: Text(
                                                  trouble.getName(
                                                      widget.userData.language),
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
                      );
              });
        });
  }

  Widget getAllQuestionnaires() {
    return StreamBuilder(
        stream: QuestionnairesServices().questionnaireData,
        builder: (context, snapshot) {
          QuerySnapshot data = snapshot.data;
          getQuestionnairesList(data, widget.userData.language);

          return questionnaires.isEmpty
              ? emptyList()
              : ListView(
                  children: questionnaires
                      .map((questionnaire) => Card(
                            color: Constants.border,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Constants.border, width: 2.0),
                                borderRadius: BorderRadius.circular(15.0)),
                            elevation: 2.0,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  clickedQuestionnaire == ''
                                      ? clickedQuestionnaire = questionnaire.uid
                                      : clickedQuestionnaire ==
                                              questionnaire.uid
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
                                      questionnaire
                                          .getName(widget.userData.language),
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
                                                widget.userData.language),
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
                                                    questionnaire:
                                                        questionnaire,
                                                    languge: widget
                                                        .userData.language,
                                                    history:
                                                        widget.userData.history,
                                                    userUid:
                                                        widget.userData.uid,
                                                  ));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 16.0),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .accentColor,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
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
                );
        });
  }

  Widget getHestory() {
    getHestoryList();
    return historys.isEmpty
        ? emptyList()
        : ListView(
            children: historys
                .map((e) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            e['name'],
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Score: ${e['score']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(fontWeight: FontWeight.w300),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd').format(e['date']),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            e['message'],
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(fontWeight: FontWeight.w300),
                          ),
                          SizedBox(height: 8.0),
                          divider(),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ))
                .toList(),
          );
  }
}
