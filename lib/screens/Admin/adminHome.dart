import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Admin/dashboard.dart';
import 'package:psyscale/screens/Admin/hybrid.dart';
import 'package:psyscale/screens/Admin/questionnaires.dart';
import 'package:psyscale/screens/Admin/troubles.dart';
import 'package:psyscale/screens/Admin/users.dart';
import 'package:psyscale/screens/settings.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/widgets.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Widget> _screens = [];
  List<Map<String, Object>> _tabs = [
    {'icon': Icons.home, 'title': 'Home', 'index': 1},
    {'icon': MdiIcons.brain, 'title': 'Troubles', 'index': 2},
    {'icon': Icons.format_list_bulleted, 'title': 'Questionnaires', 'index': 3},
    {'icon': Icons.home, 'title': 'Hybrids', 'index': 4},
    {
      'icon': Icons.supervised_user_circle_rounded,
      'title': 'Users',
      'index': 5
    },
    {'icon': MdiIcons.doctor, 'title': 'Psychiatrists', 'index': 6},
  ];
  int _selectedIndex = 1;
  TextEditingController _textFieldController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode _textFieldFocusNode = FocusNode();
  final search = ValueNotifier('');
  bool updatedLastSignIn = false;

  @override
  void dispose() {
    _textFieldController.dispose();
    // Clean up the focus node when the Form is disposed.
    _textFieldFocusNode.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    if (userData != null && !updatedLastSignIn) {
      UsersServices(useruid: userData.uid).updatelastSignIn();
      updatedLastSignIn = true;
    }
    _screens = [
      Setting(userData: userData),
      Dashboard(),
      Troubles(search: search),
      Questionnaires(
        search: search,
      ),
      Hybrid(search: search),
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
      _tabs.add(
          {'icon': Icons.admin_panel_settings, 'title': 'Admins', 'index': 7});
    }
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
                  ![0, 1].contains(_selectedIndex) ? header() : SizedBox(),
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
            _tabs[_selectedIndex - 1]['title'],
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
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
