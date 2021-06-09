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
    return Scaffold(
      body: Row(
        children: [
          sideMenu(
            tabs: _tabs,
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(child: _screens[_selectedIndex]),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      height: double.infinity,
      width: 280.0,
      color: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          appBar(context, 'Psy', 'Scale'),
          SizedBox(height: 8.0),
          ValueListenableBuilder(
            valueListenable: search,
            builder: (context, value, child) => TextField(
              controller: _textFieldController,
              focusNode: _textFieldFocusNode,
              decoration: searchTextInputDecoration(context).copyWith(
                suffixIcon: search.value.isNotEmpty
                    ? IconButton(
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.close,
                          size: 30.0,
                        ),
                        focusColor: Theme.of(context).accentColor,
                        onPressed: () {
                          _textFieldController.clear();
                          FocusScope.of(context).requestFocus(new FocusNode());
                          setState(() {
                            search.value = '';
                          });
                        })
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  search.value = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                controller: _scrollController,
                children: tabs
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
              ),
            ),
          ),
          userCard(context, userData, () {
            setState(() {
              _selectedIndex = 0;
            });
          }),
        ],
      ),
    );
  }
}
