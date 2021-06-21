import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/doctor/add_hybrid.dart';
import 'package:psyscale/screens/doctor/add_questionnaire.dart';
import 'package:psyscale/screens/doctor/hybridsPersonal.dart';
import 'package:psyscale/screens/doctor/questionnairesPersonal.dart';
import 'package:psyscale/screens/doctor/quizHybrid.dart';
import 'package:psyscale/screens/doctor/quizQuesionnaire.dart';
import 'package:psyscale/screens/doctor/trouble_details.dart';
import 'package:psyscale/screens/doctor/troubles.dart';
import 'package:psyscale/screens/doctor/questionnaires.dart';
import 'package:psyscale/screens/doctor/hybrids.dart';
import 'package:psyscale/screens/settings.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class DoctorHome extends StatefulWidget {
  @override
  _DoctorHomeState createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  List<Map<String, Object>> _tabs = [
    {'icon': MdiIcons.brain, 'title': 'Troubles', 'index': 6},
    {'icon': Icons.format_list_bulleted, 'title': 'Questionnaires', 'index': 7},
    {'icon': Icons.home, 'title': 'Hybrids', 'index': 8},
  ];
  List<Map<String, Object>> _tabsPerosnal = [
    {'icon': Icons.format_list_numbered, 'title': 'Questionnaires', 'index': 9},
    {'icon': Icons.home, 'title': 'Hybrids', 'index': 10},
  ];

  List<Widget> _screens = [];
  int _selectedIndex = 6;
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
  String _backAppbarTitle;

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
    _backIndex = backIndex ?? 6;
    _appBarTitle = backAppbarTitle;
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
      Setting(
        userData: userData,
        changeTab: changePage,
        backIndex: _backIndex,
        backappbarTitle: _backAppbarTitle,
      ),
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
        languge: _quizLanguage,
        changeTab: changePage,
        backIndex: _backIndex,
      ),
      QuizHybrid(
        questionnaire: _addQuestionnaireQuesionnaire,
        languge: _quizLanguage,
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
        title: !_isSearching
            ? Text(_appBarTitle)
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
                  }),
                  onChanged: (value) {
                    setState(() {
                      search.value = value;
                    });
                  },
                ),
              ),
        centerTitle: true,
        actions: [
          ![0, 1, 2, 3, 4, 5].contains(_selectedIndex)
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
                  ![0, 1, 2, 3, 4, 5].contains(_selectedIndex)
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
                        leading: Icon(
                          e['icon'],
                          color: e['index'] == selectedIndex
                              ? Theme.of(context).accentColor
                              : Colors.grey,
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
                        leading: Icon(
                          e['icon'],
                          color: e['index'] == selectedIndex
                              ? Theme.of(context).accentColor
                              : Colors.grey,
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
                  color: selectedIndex == 0
                      ? Theme.of(context).accentColor
                      : Colors.grey,
                ),
                title: Text(
                  'Setting',
                  style: TextStyle(
                      color: selectedIndex == 0
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      fontSize: selectedIndex == 0 ? 22.0 : 16.0),
                ),
                onTap: () {
                  if (!Responsive.isdesktop(context)) {
                    Navigator.pop(context);
                  }
                  Responsive.isMobile(context)
                      ? setState(() {
                          _backIndex = _selectedIndex;
                          _backAppbarTitle = _appBarTitle;
                          _selectedIndex = 0;
                          _appBarTitle = 'Setting';
                          _isSearching = false;
                        })
                      : createDialog(
                          context,
                          Container(
                            width: 700,
                            child: Setting(userData: userData),
                          ),
                          false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
