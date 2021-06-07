import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Admin/dashboard.dart';
import 'package:psyscale/screens/Admin/hybrid.dart';
import 'package:psyscale/screens/Admin/questionnaires.dart';
import 'package:psyscale/screens/Admin/troubles.dart';
import 'package:psyscale/screens/Admin/users.dart';
import 'package:psyscale/screens/settings.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/widgets.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Widget> _screens = [];
  List<Map<String, Object>> _tabs = [
    {'icon': Icons.home, 'title': 'Home', 'index': 0},
    {'icon': Icons.home, 'title': 'Troubles', 'index': 1},
    {'icon': Icons.home, 'title': 'Questionnaires', 'index': 2},
    {'icon': Icons.home, 'title': 'Hybrids', 'index': 3},
    {
      'icon': Icons.supervised_user_circle_rounded,
      'title': 'Users',
      'index': 4
    },
    {'icon': Icons.person, 'title': 'Psychiatrists', 'index': 5},
  ];
  int _selectedIndex = 0;
  TextEditingController _textFieldController = TextEditingController();
  FocusNode _textFieldFocusNode = FocusNode();
  bool isSearching = false;
  final search = ValueNotifier('');
  final ScrollController _scrollController = ScrollController();
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
      // Setting(userData: userData),
      Dashboard(),
      Troubles(search: search),
      Questionnaires(search: search),
      Hybrid(search: search),
      Users(search: search, type: 'users'),
      Users(search: search, type: 'psychiatrists'),
      userData != null && userData.type == 'superAdmin'
          ? Users(search: search, type: 'admins')
          : SizedBox(),
    ];
    if (userData != null && userData.type == 'superAdmin' && _tabs.length < 7) {
      _screens.add(
        Users(search: search, type: 'admins'),
      );
      _tabs.add(
          {'icon': Icons.admin_panel_settings, 'title': 'Admins', 'index': 6});
    }
    return Scaffold(
      body: Row(
        children: [
          sideMenu(
            tabs: _tabs,
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
              decoration: searchTextInputDecoration(
                context,
                () {
                  _textFieldController.clear();
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() {
                    search.value = '';
                    isSearching = false;
                  });
                },
              ),
              onChanged: (value) {
                setState(() {
                  search.value = value;
                });
              },
            ),
          ),
          SizedBox(height: 8.0),
          divider(),
          DefaultTabController(
            length: _screens.length,
            child: customTapBar(
              tabs: tabs,
              selectedIndex: selectedIndex,
              onTap: onTap,
            ),
          ),
          userCard(user: userData),
        ],
      ),
    );
  }

  Widget customTapBar({
    List<Map<String, Object>> tabs,
    int selectedIndex,
    Function(int) onTap,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView(
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
                          fontSize: e['index'] == selectedIndex ? 22.0 : 16.0),
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
    );
  }

  Widget userCard({UserData user}) {
    final userData = Provider.of<UserData>(context);
    return user == null
        ? loading(context)
        : InkWell(
            onTap: () {
              Constants.navigationFunc(
                context,
                Setting(
                  userData: userData,
                ),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar.jpg'),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    user.name,
                    style: const TextStyle(fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.navigate_next,
                  size: 30.0,
                ),
              ],
            ),
          );
  }
}
