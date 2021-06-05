import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Admin/dashboard.dart';
import 'package:psyscale/screens/Admin/hybrid.dart';
import 'package:psyscale/screens/Admin/questionnaires.dart';
import 'package:psyscale/screens/Admin/troubles.dart';
import 'package:psyscale/screens/Admin/users.dart';
import 'package:psyscale/screens/settings.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  TextEditingController _textFieldController = TextEditingController();
  FocusNode _textFieldFocusNode = FocusNode();
  bool isSearching = false;
  final search = ValueNotifier('');

  List<Widget> _screens = [];
  List<String> _tabs = [
    'Home',
    'Troubles',
    'Questionnaires',
    'Hybrids',
    'Psychiatrists',
    'Users',
  ];
  int _selectedIndex = 0;

  @override
  void dispose() {
    _textFieldController.dispose();
    // Clean up the focus node when the Form is disposed.
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final userData = Provider.of<UserData>(context);
    _screens = [
      Dashboard(),
      Troubles(search: search),
      Questionnaires(search: search),
      Hybrid(search: search),
      Users(search: search, type: 'psychiatrists'),
      Users(search: search, type: 'users'),
      userData != null && userData.type == 'superAdmin'
          ? Users(search: search, type: 'admins')
          : SizedBox(),
    ];
    if (userData != null && userData.type == 'superAdmin' && _tabs.length < 7) {
      _screens.add(
        Users(search: search, type: 'admins'),
      );
      _tabs.add('Admins');
    }

    return Scaffold(
      body: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: Responsive.isMobile(context)
              ? null
              : PreferredSize(
                  preferredSize: Size(screenWidth, 100.0),
                  child: customAppBar(
                    tabs: _tabs,
                    selectedIndex: _selectedIndex,
                    onTap: (index) => setState(() => _selectedIndex = index),
                  ),
                ),
          body: Responsive.isMobile(context)
              ? Center(child: Text('Admin Home Page'))
              : IndexedStack(
                  index: _selectedIndex,
                  children: _screens,
                ),
        ),
      ),
    );
  }

  Widget customAppBar({
    List<String> tabs,
    int selectedIndex,
    Function(int) onTap,
  }) {
    final userData = Provider.of<UserData>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      height: 65.0,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 0.5),
            blurRadius: 2.0,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Responsive.isdesktop(context)
              ? Expanded(flex: 1, child: appBar(context, 'Psy', 'Scale'))
              : SizedBox(),
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              width: 600.0,
              child: customTapBar(
                tabs: tabs,
                selectedIndex: selectedIndex,
                onTap: onTap,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          isSearching
              ? ValueListenableBuilder(
                  valueListenable: search,
                  builder: (context, value, child) => Expanded(
                    flex: 2,
                    child: TextField(
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
                )
              : IconButton(
                  color: Constants.myGrey,
                  icon: Icon(
                    Icons.search,
                    size: 30.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _textFieldFocusNode.requestFocus();
                      isSearching = true;
                    });
                  },
                ),
          const SizedBox(width: 16.0),
          Responsive.isdesktop(context) || !isSearching
              ? Center(
                  child: userCard(user: userData),
                )
              : SizedBox(width: 8.0),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  Widget customTapBar({
    List<String> tabs,
    int selectedIndex,
    Function(int) onTap,
  }) {
    return TabBar(
      indicatorPadding: EdgeInsets.zero,
      isScrollable: true,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      tabs: tabs
          .asMap()
          .map((i, e) => MapEntry(
              i,
              Tab(
                icon: Text(
                  e,
                  style: TextStyle(
                      color: i == selectedIndex
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      fontSize: 16.0),
                ),
              )))
          .values
          .toList(),
      onTap: onTap,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar.jpg'),
                ),
                const SizedBox(width: 6.0),
                // Responsive.isdesktop(context)
                //     ? Flexible(
                //         child: Text(
                //           user.name,
                //           style: const TextStyle(fontSize: 16.0),
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       )
                //     : SizedBox(),
              ],
            ),
          );
  }
}
