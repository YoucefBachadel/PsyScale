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
  final List<UserData> allUsers = [];
  final List<UserData> users = [];
  final List<UserData> psychiatrists = [];
  final List<UserData> admins = [];
  String _sortBy = '';
  String _lastStor = '';

  getAllUsers([QuerySnapshot data]) {
    allUsers.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        allUsers.add(UserData(
          uid: doc.id,
          type: doc['type'],
          name: doc['name'],
          email: doc['email'],
          language: doc['language'],
          creationDate: doc['creationDate'],
          lastSignIn: doc['lastSignIn'],
          // phone: doc['phone'] ?? null,
          // validated: doc['validated'] ?? false,
        ));
      });
    }
    listStor();
  }

  listStor() {
    _lastStor = 'Language';
    switch (_sortBy) {
      case 'User Name':
        if (_lastStor == _sortBy) {
          allUsers.sort((a, b) => a.name.compareTo(b.name));
        } else {
          allUsers.sort((a, b) => b.name.compareTo(a.name));
        }
        break;
      case 'Email':
        if (_lastStor == _sortBy) {
          allUsers.sort((a, b) => a.email.compareTo(b.email));
        } else {
          allUsers.sort((a, b) => b.email.compareTo(a.email));
        }
        break;
      case 'Creation Date':
        if (_lastStor == _sortBy) {
          allUsers.sort((a, b) => a.creationDate.compareTo(b.creationDate));
        } else {
          allUsers.sort((a, b) => b.creationDate.compareTo(a.creationDate));
        }
        break;
      case 'Last SignIn':
        if (_lastStor == _sortBy) {
          allUsers.sort((a, b) => a.lastSignIn.compareTo(b.lastSignIn));
        } else {
          allUsers.sort((a, b) => b.lastSignIn.compareTo(a.lastSignIn));
        }
        break;
      case 'Language':
        if (_lastStor == _sortBy) {
          allUsers.sort((a, b) => a.language.compareTo(b.language));
        } else {
          allUsers.sort((a, b) => b.language.compareTo(a.language));
        }
        break;
    }

    _lastStor = _lastStor;
  }

  getUsersList() {
    users.clear();
    allUsers.forEach((element) {
      if (element.name.toLowerCase().contains(widget.search.value) &&
          element.type == 'user') {
        users.add(element);
      }
    });
  }

  getPsychitristsList() {
    psychiatrists.clear();
    allUsers.forEach((element) {
      if (element.name.toLowerCase().contains(widget.search.value) &&
          element.type == 'doctor') {
        psychiatrists.add(element);
      }
    });
  }

  getAdminsList() {
    admins.clear();
    allUsers.forEach((element) {
      if (element.name.toLowerCase().contains(widget.search.value) &&
              (element.type == 'admin') ||
          element.type == 'superAdmin') {
        admins.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: UsersServices().allUserData,
          builder: (context, snapshot) {
            QuerySnapshot data = snapshot.data;

            getAllUsers(data);

            return widget.type == 'users'
                ? usersList()
                : widget.type == 'psychiatrists'
                    ? psychiatristsList()
                    : adminsList();
          }),
    );
  }

  Widget usersList() {
    getUsersList();
    return users.isEmpty
        ? loading(context)
        : DataTable(
            columns: [
              DataColumn(label: culomnItem('#', false)),
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
                DataCell(Text(
                    DateFormat('yyyy-MM-dd').format(e.creationDate.toDate()))),
                DataCell(Text(
                    DateFormat('yyyy-MM-dd').format(e.lastSignIn.toDate()))),
                DataCell(Text(e.language)),
                DataCell(deleteButton(context, () {})),
              ]);
            }).toList(),
          );
  }

  Widget psychiatristsList() {
    getPsychitristsList();
    return psychiatrists.isEmpty
        ? loading(context)
        : DataTable(
            columns: [
              DataColumn(label: culomnItem('#', false)),
              DataColumn(label: culomnItem('User Name', true)),
              DataColumn(label: culomnItem('Email', true)),
              DataColumn(label: culomnItem('Creation Date', true)),
              DataColumn(label: culomnItem('Last SignIn', true)),
              DataColumn(label: culomnItem('Language', true)),
              DataColumn(label: culomnItem('', false)),
            ],
            rows: psychiatrists.map((e) {
              return DataRow(cells: [
                DataCell(
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/avatar.jpg'),
                  ),
                ),
                DataCell(Text(e.name)),
                DataCell(Text(e.email)),
                DataCell(Text(
                    DateFormat('yyyy-MM-dd').format(e.creationDate.toDate()))),
                DataCell(Text(
                    DateFormat('yyyy-MM-dd').format(e.lastSignIn.toDate()))),
                DataCell(Text(e.language)),
                DataCell(deleteButton(context, () {})),
              ]);
            }).toList(),
          );
  }

  Widget adminsList() {
    getAdminsList();
    return admins.isEmpty
        ? loading(context)
        : DataTable(
            columns: [
              DataColumn(label: culomnItem('#', false)),
              DataColumn(label: culomnItem('User Name', true)),
              DataColumn(label: culomnItem('Email', true)),
              DataColumn(label: culomnItem('Creation Date', true)),
              DataColumn(label: culomnItem('Last SignIn', true)),
              DataColumn(label: culomnItem('Language', true)),
              DataColumn(label: culomnItem('', false)),
            ],
            rows: admins.map((e) {
              return DataRow(cells: [
                DataCell(
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/avatar.jpg'),
                  ),
                ),
                DataCell(Text(e.name)),
                DataCell(Text(e.email)),
                DataCell(Text(
                    DateFormat('yyyy-MM-dd').format(e.creationDate.toDate()))),
                DataCell(Text(
                    DateFormat('yyyy-MM-dd').format(e.lastSignIn.toDate()))),
                DataCell(Text(e.language)),
                DataCell(deleteButton(context, () {})),
              ]);
            }).toList(),
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
                    fontSize: 16.0,
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
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          );
  }
}
