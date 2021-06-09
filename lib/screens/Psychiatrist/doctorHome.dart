import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Psychiatrist/troubles.dart';
import 'package:psyscale/screens/Psychiatrist/questionnaires.dart';
import 'package:psyscale/screens/Psychiatrist/hybrids.dart';
import 'package:psyscale/screens/settings.dart';
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
    {'icon': MdiIcons.brain, 'title': 'Troubles', 'index': 1},
    {'icon': Icons.format_list_bulleted, 'title': 'Questionnaires', 'index': 2},
    {'icon': Icons.home, 'title': 'Hybrids', 'index': 3},
  ];
  List<Widget> _screens = [];
  int _selectedIndex = 1;
  TextEditingController _textFieldController = TextEditingController();
  FocusNode _textFieldFocusNode = FocusNode();
  final search = ValueNotifier('');
  bool updatedLastSignIn = false;
  String _appBarTitle = 'Troubles';

  @override
  void dispose() {
    _textFieldController.dispose();
    // Clean up the focus node when the Form is disposed.
    _textFieldFocusNode.dispose();
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
      Troubles(search: search),
      Questionnaires(search: search),
      Hybrids(search: search),
    ];

    return Responsive.isdesktop(context) ? desktopView() : mobileView();
  }

  Widget mobileView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        centerTitle: true,
      ),
      drawer: drawer(),
      body: _screens[_selectedIndex],
    );
  }

  Widget desktopView() {
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

  Widget drawer() {
    final userData = Provider.of<UserData>(context);
    return Drawer(
      child: Material(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            const SizedBox(height: 20),
            userData == null
                ? loading(context)
                : InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                        _appBarTitle = 'Account';
                        Navigator.pop(context);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/avatar.jpg'),
                          ),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: ListTile(
                              title: Text(userData.name),
                              subtitle: Text(userData.email),
                            ),
                          ),
                          Icon(
                            Icons.navigate_next,
                            size: 30.0,
                          ),
                        ],
                      ),
                    ),
                  ),
            SizedBox(height: 8.0),
            divider(),
            Expanded(
              child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  children: _tabs
                      .map((e) => ListTile(
                            leading: Icon(e['icon']),
                            title: Text(e['title']),
                            hoverColor: Constants.myGrey,
                            onTap: () {
                              setState(() {
                                _selectedIndex = e['index'];
                                _appBarTitle = e['title'];
                                Navigator.pop(context);
                              });
                            },
                          ))
                      .toList()),
            ),
          ],
        ),
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
