import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Admin/add_hybrid.dart';
import 'package:psyscale/screens/Admin/add_questionnaire.dart';
import 'package:psyscale/screens/Admin/dashboard.dart';
import 'package:psyscale/screens/Admin/hybrid.dart';
import 'package:psyscale/screens/Admin/profileAdmin.dart';
import 'package:psyscale/screens/Admin/questionnaires.dart';
import 'package:psyscale/screens/Admin/troubles.dart';
import 'package:psyscale/screens/Admin/users.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Widget> _screens = [];
  List<Map<String, Object>> _tabs = [
    {'icon': 'assets/dashboard.svg', 'title': 'Dashboard', 'index': 2},
    {'icon': 'assets/trouble.svg', 'title': 'Troubles', 'index': 3},
    {'icon': 'assets/questionnaire.svg', 'title': 'Questionnaires', 'index': 4},
    {'icon': 'assets/hybrid.svg', 'title': 'Hybrid', 'index': 5},
    {'icon': 'assets/user.svg', 'title': 'Users', 'index': 6},
    {'icon': 'assets/doctor.svg', 'title': 'Doctors', 'index': 7},
  ];
  int _selectedIndex = 2;
  TextEditingController _textFieldController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode _textFieldFocusNode = FocusNode();
  final search = ValueNotifier('');
  bool updatedLastSignIn = false;
  bool themeChanged = false;
  String _appBarTitle = 'Dashboard';
  bool _isSearching = false;

  Questionnaire _addQuestionnaireQuesionnaire;

  @override
  void dispose() {
    _textFieldController.dispose();
    // Clean up the focus node when the Form is disposed.
    _textFieldFocusNode.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  void changePage({
    int index,
    Questionnaire questionnaire,
    String backAppbarTitle,
  }) {
    _addQuestionnaireQuesionnaire = questionnaire;
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
      AddQuestionnaire(
          changeTab: changePage,
          userData: userData,
          questionnaire: _addQuestionnaireQuesionnaire),
      AddHybrid(
          changeTab: changePage,
          userData: userData,
          questionnaire: _addQuestionnaireQuesionnaire),
      Dashboard(
        changeTab: changePage,
        userData: userData,
      ),
      Troubles(search: search),
      Questionnaires(
        changeTab: changePage,
        search: search,
      ),
      Hybrid(
        changeTab: changePage,
        search: search,
      ),
      Users(
        search: search,
        type: 'users',
      ),
      Users(
        search: search,
        type: 'psychiatrists',
      ),
      userData != null && userData.type == 'superAdmin'
          ? Users(
              search: search,
              type: 'admins',
            )
          : SizedBox(),
    ];
    if (userData != null && userData.type == 'superAdmin' && _tabs.length < 7) {
      _screens.add(
        Users(search: search, type: 'admins'),
      );
      _tabs.add({'icon': 'assets/admin.svg', 'title': 'Admins', 'index': 8});
    }

    return Responsive.isdesktop(context)
        ? desktopView()
        : Responsive.isMobile(context)
            ? kIsWeb
                ? unsupportedScreenSize(
                    context,
                    'The admin interface is not supported in this screen size',
                    false,
                  )
                : unsupportedScreenSize(
                    context,
                    'The admin interface is not supported on mobile',
                    true,
                  )
            : tabletView();
  }

  Widget tabletView() {
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
          ![0, 1, 2].contains(_selectedIndex)
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
          Expanded(
            child: sideMenu(
              tabs: _tabs,
              selectedIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ),
          Expanded(
              flex: 5,
              child: Column(
                children: [
                  ![0, 1, 2].contains(_selectedIndex) ? header() : SizedBox(),
                  Expanded(child: _screens[_selectedIndex]),
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
          Expanded(
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
                            if ([2].contains(_selectedIndex)) {
                              _isSearching = false;
                            }
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
                  createDialog(
                    context,
                    Container(
                      height: 500,
                      width: 700,
                      child: ProfileAdmin(userData: userData),
                    ),
                    false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
