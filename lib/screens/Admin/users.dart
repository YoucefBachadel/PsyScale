import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/widgets.dart';

class Users extends StatefulWidget {
  final ValueListenable<String> search;
  final String type;

  const Users({Key key, this.search, this.type}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  String _sortBy = 'User Name';
  String _lastStore = '';
  List<UserData> allUsers = [];
  List<UserData> users = [];

  getUsersList(QuerySnapshot data, String type) {
    allUsers.clear();
    users.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        if (type == 'users' && doc['type'] == 'user') {
          allUsers.add(UserData(
            uid: doc.id,
            type: doc['type'],
            name: doc['name'],
            email: doc['email'],
            language: doc['language'],
            creationDate: doc['creationDate'],
            lastSignIn: doc['lastSignIn'],
          ));
        } else if (type == 'psychiatrists' && doc['type'] == 'doctor') {
          allUsers.add(UserData(
            uid: doc.id,
            type: doc['type'],
            name: doc['name'],
            email: doc['email'],
            language: doc['language'],
            creationDate: doc['creationDate'],
            lastSignIn: doc['lastSignIn'],
          ));
        } else if (type == 'admins' &&
            (doc['type'] == 'admin' || doc['type'] == 'superAdmin')) {
          allUsers.add(UserData(
            uid: doc.id,
            type: doc['type'],
            name: doc['name'],
            email: doc['email'],
            language: doc['language'],
            creationDate: doc['creationDate'],
            lastSignIn: doc['lastSignIn'],
          ));
        }
      });
    }
    allUsers.forEach((element) {
      if (element.name
          .toLowerCase()
          .contains(widget.search.value.toLowerCase())) {
        users.add(element);
      }
    });
    listStor();
  }

  listStor() {
    switch (_sortBy) {
      case 'User Name':
        users.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'Email':
        users.sort(
            (a, b) => a.email.toLowerCase().compareTo(b.email.toLowerCase()));
        break;
      case 'Creation Date':
        users.sort((a, b) => a.creationDate.compareTo(b.creationDate));
        break;
      case 'Last SignIn':
        users.sort((a, b) => a.lastSignIn.compareTo(b.lastSignIn));
        break;
      case 'Language':
        users.sort((a, b) => a.language.compareTo(b.language));
        break;
    }
    if (_lastStore == _sortBy) {
      users.reversed.toList();
      _lastStore = '';
    } else {
      _lastStore = _sortBy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: UsersServices().allUserData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              QuerySnapshot data = snapshot.data;
              getUsersList(data, widget.type);
              return widget.type == 'users'
                  ? usersList()
                  : widget.type == 'psychiatrists'
                      ? psychiatristsList()
                      : adminsList();
            } else {
              return loading(context);
            }
          }),
      floatingActionButton: widget.type == 'admins'
          ? FloatingActionButton(
              heroTag: null,
              backgroundColor: Theme.of(context).accentColor,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {},
            )
          : null,
    );
  }

  Widget usersList() {
    return users.isEmpty
        ? emptyList()
        : Center(
            child: Container(
              color: Theme.of(context).backgroundColor,
              height: double.infinity,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Theme.of(context).accentColor),
                columns: [
                  DataColumn(label: culomnItem('', false)),
                  DataColumn(label: culomnItem('User Name', true)),
                  DataColumn(label: culomnItem('Email', true)),
                  DataColumn(label: culomnItem('Creation Date', true)),
                  DataColumn(label: culomnItem('Last SignIn', true)),
                  DataColumn(label: culomnItem('Language', true)),
                  DataColumn(label: culomnItem('', false)),
                ],
                rows: users.map((e) {
                  return DataRow(cells: [
                    DataCell(
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar.jpg'),
                      ),
                    ),
                    DataCell(Text(e.name)),
                    DataCell(Text(e.email)),
                    DataCell(Text(DateFormat('yyyy-MM-dd')
                        .format(e.creationDate.toDate()))),
                    DataCell(Text(DateFormat('yyyy-MM-dd H:mm')
                        .format(e.lastSignIn.toDate()))),
                    DataCell(Text(e.language)),
                    DataCell(deleteButton(context, () {})),
                  ]);
                }).toList(),
              ),
            ),
          );
  }

  Widget psychiatristsList() {
    return users.isEmpty
        ? emptyList()
        : Center(
            child: Container(
              color: Theme.of(context).backgroundColor,
              height: double.infinity,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Theme.of(context).accentColor),
                columns: [
                  DataColumn(label: culomnItem('', false)),
                  DataColumn(label: culomnItem('User Name', true)),
                  DataColumn(label: culomnItem('Email', true)),
                  DataColumn(label: culomnItem('Creation Date', true)),
                  DataColumn(label: culomnItem('Last SignIn', true)),
                  DataColumn(label: culomnItem('Language', true)),
                  DataColumn(label: culomnItem('', false)),
                ],
                rows: users.map((e) {
                  return DataRow(cells: [
                    DataCell(
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar.jpg'),
                      ),
                    ),
                    DataCell(Text(e.name)),
                    DataCell(Text(e.email)),
                    DataCell(Text(DateFormat('yyyy-MM-dd')
                        .format(e.creationDate.toDate()))),
                    DataCell(Text(DateFormat('yyyy-MM-dd H:mm')
                        .format(e.lastSignIn.toDate()))),
                    DataCell(Text(e.language)),
                    DataCell(deleteButton(context, () {})),
                  ]);
                }).toList(),
              ),
            ),
          );
  }

  Widget adminsList() {
    return users.isEmpty
        ? emptyList()
        : Center(
            child: Container(
              color: Theme.of(context).backgroundColor,
              height: double.infinity,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Theme.of(context).accentColor),
                columns: [
                  DataColumn(label: culomnItem('', false)),
                  DataColumn(label: culomnItem('User Name', true)),
                  DataColumn(label: culomnItem('Email', true)),
                  DataColumn(label: culomnItem('Creation Date', true)),
                  DataColumn(label: culomnItem('Last SignIn', true)),
                  DataColumn(label: culomnItem('Language', true)),
                  DataColumn(label: culomnItem('', false)),
                ],
                rows: users.map((e) {
                  return DataRow(cells: [
                    DataCell(
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar.jpg'),
                      ),
                    ),
                    DataCell(Text(e.name)),
                    DataCell(Text(e.email)),
                    DataCell(Text(DateFormat('yyyy-MM-dd')
                        .format(e.creationDate.toDate()))),
                    DataCell(Text(DateFormat('yyyy-MM-dd H:mm')
                        .format(e.lastSignIn.toDate()))),
                    DataCell(Text(e.language)),
                    DataCell(deleteButton(context, () {})),
                  ]);
                }).toList(),
              ),
            ),
          );
  }

  Widget culomnItem(String text, bool ordorable) {
    return ordorable
        ? InkWell(
            onTap: () {
              setState(() {
                _sortBy = text;
              });
            },
            child: Row(
              children: [
                ordorable
                    ? Icon(
                        Icons.keyboard_arrow_down,
                      )
                    : SizedBox(),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          )
        : Row(
            children: [
              ordorable
                  ? Icon(
                      Icons.keyboard_arrow_down,
                    )
                  : SizedBox(),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
  }
}
