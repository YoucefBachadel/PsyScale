import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/doctor/add_hybrid.dart';
import 'package:psyscale/screens/doctor/add_questionnaire.dart';
import 'package:psyscale/screens/doctor/hybridsPersonal.dart';
import 'package:psyscale/screens/doctor/profileDoctor.dart';
import 'package:psyscale/screens/doctor/questionnairesPersonal.dart';
import 'package:psyscale/screens/doctor/quizHybrid.dart';
import 'package:psyscale/screens/doctor/quizQuesionnaire.dart';
import 'package:psyscale/screens/doctor/trouble_details.dart';
import 'package:psyscale/screens/doctor/troubles.dart';
import 'package:psyscale/screens/doctor/questionnaires.dart';
import 'package:psyscale/screens/doctor/hybrids.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class DoctorHome extends StatefulWidget {
  @override
  _DoctorHomeState createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  List<Map<String, Object>> _tabs = [
    {'icon': 'assets/trouble.svg', 'title': 'Troubles', 'index': 5},
    {'icon': 'assets/questionnaire.svg', 'title': 'Questionnaires', 'index': 6},
    {'icon': 'assets/hybrid.svg', 'title': 'Hybrid', 'index': 7},
  ];
  List<Map<String, Object>> _tabsPerosnal = [
    {
      'icon': 'assets/questionnaire_p.svg',
      'title': 'Questionnaires',
      'index': 8
    },
    {'icon': 'assets/hybrid_p.svg', 'title': 'Hybrid', 'index': 9},
  ];

  List<Widget> _screens = [];
  int _selectedIndex = 5;
  TextEditingController _textFieldController = TextEditingController();
  FocusNode _textFieldFocusNode = FocusNode();
  final search = ValueNotifier('');
  bool updatedLastSignIn = false;
  String _appBarTitle = 'Troubles';
  bool _isSearching = false;

  Questionnaire _addQuestionnaireQuesionnaire;
  Trouble _troubleDetailTrouble;
  String _quizLanguage;
  int _backIndex;

  @override
  void dispose() {
    _textFieldController.dispose();
    // Clean up the focus node when the Form is disposed.
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void changePage({
    @required int index,
    int backIndex,
    Questionnaire questionnaire,
    Trouble trouble,
    String language,
    String backAppbarTitle,
  }) {
    _addQuestionnaireQuesionnaire = questionnaire ?? null;
    _troubleDetailTrouble = trouble ?? null;
    _quizLanguage = language ?? null;
    _backIndex = backIndex ?? 5;
    _appBarTitle = backAppbarTitle ?? '';
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    if (userData != null && !updatedLastSignIn) {
      UsersServices(useruid: userData.uid).updatelastSignIn();
      updatedLastSignIn = true;
    }
    _screens = [
      AddQuestionnaire(
        userData: userData,
        questionnaire: _addQuestionnaireQuesionnaire,
        changeTab: changePage,
      ),
      AddHybrid(
        userData: userData,
        questionnaire: _addQuestionnaireQuesionnaire,
        changeTab: changePage,
      ),
      QuizQuestionnaire(
        questionnaire: _addQuestionnaireQuesionnaire,
        changeTab: changePage,
        backIndex: _backIndex,
      ),
      QuizHybrid(
        questionnaire: _addQuestionnaireQuesionnaire,
        changeTab: changePage,
        backIndex: _backIndex,
      ),
      TroubleDetails(
        trouble: _troubleDetailTrouble,
        language: _quizLanguage,
        changeTab: changePage,
      ),
      Troubles(changeTab: changePage, search: search),
      Questionnaires(changeTab: changePage, search: search),
      Hybrids(changeTab: changePage, search: search),
      QuestionnairesPersonal(changeTab: changePage, search: search),
      HybridsPersonal(changeTab: changePage, search: search),
    ];

    return Responsive.isdesktop(context)
        ? desktopView()
        : Responsive.isMobile(context)
            ? kIsWeb
                ? unsupportedScreenSize(
                    context,
                    'The doctor interface is not supported on the web for this screen size',
                    false,
                  )
                : mobileTabletView()
            : mobileTabletView();
  }

  Widget mobileTabletView() {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isSearching ? 60.0 : 0.0),
          child: !_isSearching
              ? SizedBox()
              : ValueListenableBuilder(
                  valueListenable: search,
                  builder: (context, value, child) => TextField(
                    controller: _textFieldController,
                    focusNode: _textFieldFocusNode,
                    decoration: searchTextInputDecoration(context, () {
                      _textFieldController.clear();
                      FocusScope.of(context).requestFocus(new FocusNode());
                      setState(() {
                        search.value = '';
                        _isSearching = false;
                      });
                    }).copyWith(),
                    onChanged: (value) {
                      setState(() {
                        search.value = value;
                      });
                    },
                  ),
                ),
        ),
        title: Text(_appBarTitle),
        centerTitle: true,
        actions: [
          ![0, 1, 2, 3, 4].contains(_selectedIndex)
              ? !_isSearching
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                      icon: Icon(Icons.search),
                    )
                  : SizedBox()
              : SizedBox(),
        ],
      ),
      drawer: sideMenu(
        tabs: _tabs,
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
      ),
      body: _screens[_selectedIndex],
    );
  }

  Widget desktopView() {
    return Material(
      child: Row(
        children: [
          Flexible(
            child: sideMenu(
              tabs: _tabs,
              selectedIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ),
          Flexible(
              flex: 5,
              child: Column(
                children: [
                  ![0, 1, 2, 3, 4].contains(_selectedIndex)
                      ? header()
                      : SizedBox(),
                  Flexible(child: _screens[_selectedIndex]),
                ],
              )),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          Text(
            _appBarTitle,
            style: Theme.of(context).textTheme.headline6,
          ),
          Spacer(flex: 2),
          Flexible(
            child: ValueListenableBuilder(
              valueListenable: search,
              builder: (context, value, child) => TextField(
                controller: _textFieldController,
                focusNode: _textFieldFocusNode,
                decoration: searchTextInputDecoration(context, () {
                  _textFieldController.clear();
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() {
                    search.value = '';
                  });
                }),
                onChanged: (value) {
                  setState(() {
                    search.value = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sideMenu({
    List<Map<String, Object>> tabs,
    int selectedIndex,
    Function(int) onTap,
  }) {
    final userData = Provider.of<UserData>(context);
    return Drawer(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DrawerHeader(child: appBar(context, 'Psy', 'Scale')),
              ...tabs
                  .map((e) => ListTile(
                        leading: SvgPicture.asset(
                          e['icon'],
                          color: e['index'] == selectedIndex
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                          height: 23.0,
                          width: 23.0,
                        ),
                        title: Text(
                          e['title'],
                          style: TextStyle(
                              color: e['index'] == selectedIndex
                                  ? Theme.of(context).accentColor
                                  : Colors.grey,
                              fontSize:
                                  e['index'] == selectedIndex ? 22.0 : 16.0),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedIndex = e['index'];
                            _appBarTitle = e['title'];
                            if (!Responsive.isdesktop(context)) {
                              Navigator.pop(context);
                            }
                          });
                        },
                      ))
                  .toList(),
              divider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Personal',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.grey),
                ),
              ),
              SizedBox(height: 8.0),
              ..._tabsPerosnal
                  .map((e) => ListTile(
                        leading: SvgPicture.asset(
                          e['icon'],
                          color: e['index'] == selectedIndex
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                          height: 23.0,
                          width: 23.0,
                        ),
                        title: Text(
                          e['title'],
                          style: TextStyle(
                              color: e['index'] == selectedIndex
                                  ? Theme.of(context).accentColor
                                  : Colors.grey,
                              fontSize:
                                  e['index'] == selectedIndex ? 22.0 : 16.0),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedIndex = e['index'];
                            _appBarTitle = e['title'];
                            if (!Responsive.isdesktop(context)) {
                              Navigator.pop(context);
                            }
                          });
                        },
                      ))
                  .toList(),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Colors.grey,
                ),
                title: Text(
                  'Setting',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
                onTap: () {
                  if (!Responsive.isdesktop(context)) {
                    Navigator.pop(context);
                  }
                  if (Responsive.isMobile(context)) {
                    Constants.navigationFunc(
                        context,
                        Scaffold(
                            body: SafeArea(
                          child: ProfileDoctor(userData: userData),
                        )));
                  } else {
                    createDialog(
                      context,
                      Container(
                        width: 700,
                        child: ProfileDoctor(userData: userData),
                      ),
                      false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
