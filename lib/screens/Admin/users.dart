import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/constants.dart';
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
  bool _isAddingAdmin = false;

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
            clinicName: doc['clinicName'],
            email: doc['email'],
            phone: doc['phone'],
            language: doc['language'],
            creationDate: doc['creationDate'],
            lastSignIn: doc['lastSignIn'],
            validated: doc['validated'],
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
              return Stack(
                children: [
                  widget.type == 'users'
                      ? usersList()
                      : widget.type == 'psychiatrists'
                          ? psychiatristsList()
                          : adminsList(),
                  _isAddingAdmin ? addAdmin() : SizedBox(),
                ],
              );
            } else {
              return loading(context);
            }
          }),
      floatingActionButton: widget.type == 'admins' && !_isAddingAdmin
          ? FloatingActionButton(
              heroTag: null,
              backgroundColor: Theme.of(context).accentColor,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isAddingAdmin = true;
                });
              },
            )
          : null,
    );
  }

  Widget addAdmin() {
    String _newUserName = '';
    String _newEmail = '';
    String _newtype = '';
    return Positioned(
      bottom: 8.0,
      right: 8.0,
      child: Container(
        height: 400.0,
        width: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            width: 0.5,
            color: Constants.border,
          ),
        ),
        child: Column(
          children: [
            Container(
              color: Constants.border,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Admin',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(color: Colors.white),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _isAddingAdmin = false;
                        });
                      },
                      icon: Icon(
                        Icons.close_sharp,
                        color: Colors.white,
                        size: 30.0,
                      ))
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Form(
                  child: Column(
                    children: [
                      Spacer(),
                      TextFormField(
                        initialValue: _newUserName,
                        validator: (value) =>
                            value.isEmpty ? 'Enter Admin Name' : null,
                        decoration: textInputDecoration(context, 'Admin Name'),
                        onChanged: (value) => _newUserName = value,
                      ),
                      SizedBox(height: 6.0),
                      TextFormField(
                        initialValue: _newEmail,
                        validator: (value) =>
                            value.isEmpty ? 'Enter Email' : null,
                        decoration: textInputDecoration(context, 'Email'),
                        onChanged: (value) => _newEmail = value,
                      ),
                      SizedBox(height: 6.0),
                      DropdownButtonFormField(
                        decoration: textInputDecoration(context, 'Admin Type'),
                        items: ['Super Admin', 'Admin'].map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _newtype =
                              value == 'Super Admin' ? 'superAdmin' : 'admin';
                        },
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () async {
                          UserData userData = UserData(
                            name: _newUserName,
                            email: _newEmail,
                            language: 'English',
                            theme: 'System',
                          );

                          await UsersServices(useruid: userData.uid)
                              .addUserData(userData, _newtype);
                          setState(() {
                            _isAddingAdmin = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 18.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget usersList() {
    List<DataColumn> columns = [
      DataColumn(label: culomnItem('User Name', true)),
      DataColumn(label: culomnItem('Email', true)),
      DataColumn(label: culomnItem('Creation Date', true)),
      DataColumn(label: culomnItem('Last SignIn', true)),
      DataColumn(label: culomnItem('Language', true)),
      DataColumn(label: culomnItem('', false)),
    ];
    List<DataRow> rows = users.map((e) {
      return DataRow(cells: [
        DataCell(Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.jpg'),
            ),
            SizedBox(width: 8.0),
            Text(e.name),
          ],
        )),
        DataCell(Text(e.email)),
        DataCell(
            Text(DateFormat('yyyy-MM-dd').format(e.creationDate.toDate()))),
        DataCell(
            Text(DateFormat('yyyy-MM-dd H:mm').format(e.lastSignIn.toDate()))),
        DataCell(Text(e.language)),
        DataCell(deleteButton(context, () {},
            text: 'Delete', color: Colors.red, icon: Icons.delete)),
      ]);
    }).toList();
    return dataTable(columns, rows);
  }

  Widget psychiatristsList() {
    List<DataColumn> columns = [
      DataColumn(label: culomnItem('User Name', true)),
      DataColumn(label: culomnItem('Clinic Name', true)),
      DataColumn(label: culomnItem('Email', true)),
      DataColumn(label: culomnItem('Phone', false)),
      DataColumn(label: culomnItem('Creation Date', true)),
      DataColumn(label: culomnItem('Last SignIn', true)),
      DataColumn(label: culomnItem('Language', true)),
      DataColumn(label: culomnItem('Validation', true)),
      DataColumn(label: culomnItem('', false)),
    ];
    List<DataRow> rows = users.map((e) {
      return DataRow(cells: [
        DataCell(Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.jpg'),
            ),
            SizedBox(width: 8.0),
            Text(e.name),
          ],
        )),
        DataCell(Text(e.clinicName)),
        DataCell(Text(e.email)),
        DataCell(Text(e.phone)),
        DataCell(
            Text(DateFormat('yyyy-MM-dd').format(e.creationDate.toDate()))),
        DataCell(
            Text(DateFormat('yyyy-MM-dd H:mm').format(e.lastSignIn.toDate()))),
        DataCell(Text(e.language)),
        DataCell(!e.validated
            ? deleteButton(context, () {
                print(e.uid);
                UsersServices().validateDoctor(e.uid);
              }, text: 'Validate', color: Colors.green, icon: Icons.cloud_done)
            : Icon(Icons.done)),
        DataCell(deleteButton(context, () {},
            text: 'Delete', color: Colors.red, icon: Icons.delete)),
      ]);
    }).toList();
    return dataTable(columns, rows);
  }

  Widget adminsList() {
    List<DataColumn> columns = [
      DataColumn(label: culomnItem('User Name', true)),
      DataColumn(label: culomnItem('Type', true)),
      DataColumn(label: culomnItem('Email', true)),
      DataColumn(label: culomnItem('Creation Date', true)),
      DataColumn(label: culomnItem('Last SignIn', true)),
      DataColumn(label: culomnItem('Language', true)),
      DataColumn(label: culomnItem('', false)),
    ];
    List<DataRow> rows = users.map((e) {
      return DataRow(cells: [
        DataCell(Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.jpg'),
            ),
            SizedBox(width: 8.0),
            Text(e.name),
          ],
        )),
        DataCell(Text(e.type)),
        DataCell(Text(e.email)),
        DataCell(
            Text(DateFormat('yyyy-MM-dd').format(e.creationDate.toDate()))),
        DataCell(
            Text(DateFormat('yyyy-MM-dd H:mm').format(e.lastSignIn.toDate()))),
        DataCell(Text(e.language)),
        DataCell(deleteButton(context, () {},
            text: 'Delete', color: Colors.red, icon: Icons.delete)),
      ]);
    }).toList();
    return dataTable(columns, rows);
  }

  Widget dataTable(List<DataColumn> columns, List<DataRow> rows) {
    return users.isEmpty && allUsers.isEmpty
        ? loading(context)
        : users.isEmpty && allUsers.isNotEmpty
            ? emptyList()
            : Center(
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      height: double.infinity,
                      child: DataTable(
                        columnSpacing: 22.0,
                        dataRowHeight: 40.0,
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Theme.of(context).accentColor),
                        columns: columns,
                        rows: rows,
                      ),
                    ),
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
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                ),
              ],
            ),
          )
        : Text(
            text,
            style: TextStyle(
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          );
  }
}
