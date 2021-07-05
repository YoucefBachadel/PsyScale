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
  List<UserData> allUsers = [];
  List<UserData> users = [];
  int _sortColumnIndex = 0;
  bool _isAscending = false;
  String _sortBy = '';

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
            personalQuestionnaires:
                doc.data().containsKey('personalQuestionnaires')
                    ? UserData.getPersonalQuestionnaires(
                        doc['personalQuestionnaires'])
                    : [],
            personalHybrids: doc.data().containsKey('personalHybrids')
                ? UserData.getPersonalHybrids(doc['personalHybrids'])
                : [],
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
    listSort();
  }

  void listSort() {
    switch (_sortBy) {
      case 'User Name':
        users.sort((user1, user2) {
          return !_isAscending
              ? user1.name.compareTo(user2.name)
              : user2.name.compareTo(user1.name);
        });
        break;
      case 'Email':
        users.sort((user1, user2) {
          return !_isAscending
              ? user1.email.compareTo(user2.email)
              : user2.email.compareTo(user1.email);
        });
        break;
      case 'Creation Date':
        users.sort((user1, user2) {
          return !_isAscending
              ? user1.creationDate.compareTo(user2.creationDate)
              : user2.creationDate.compareTo(user1.creationDate);
        });
        break;
      case 'Last SignIn':
        users.sort((user1, user2) {
          return !_isAscending
              ? user1.lastSignIn.compareTo(user2.lastSignIn)
              : user2.lastSignIn.compareTo(user1.lastSignIn);
        });
        break;
      case 'Clinic Name':
        users.sort((user1, user2) {
          return !_isAscending
              ? user1.clinicName.compareTo(user2.clinicName)
              : user2.clinicName.compareTo(user1.clinicName);
        });
        break;
      case 'Validation':
        users.sort((user1, user2) {
          return !_isAscending ? 1 : -1;
        });
        break;
      case 'Type':
        users.sort((user1, user2) {
          return !_isAscending
              ? user1.type.compareTo(user2.type)
              : user2.type.compareTo(user1.type);
        });
        break;
    }
  }

  void onSort(int columnIndex, bool ascending, String sortby) {
    setState(() {
      _sortBy = sortby;
      _isAscending = ascending;
      _sortColumnIndex = columnIndex;
    });
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
              onPressed: () => createDialog(context, addAdmin(), false))
          : null,
    );
  }

  Widget addAdmin() {
    final _formKey = GlobalKey<FormState>();
    String _newUserName = '';
    String _newEmail = '';
    String _newPassword = '';
    String _newtype = '';

    return Container(
      height: 400.0,
      width: 700,
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
            height: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: Constants.border,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close_sharp,
                      color: Colors.white,
                      size: 30.0,
                    )),
                Expanded(
                  child: Text(
                    'Add New Admin',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
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
                    TextFormField(
                      obscureText: true,
                      initialValue: _newPassword,
                      validator: (value) =>
                          value.isEmpty ? 'Enter Password' : null,
                      decoration: textInputDecoration(context, 'Password'),
                      onChanged: (value) => _newPassword = value,
                    ),
                    SizedBox(height: 6.0),
                    DropdownButtonFormField(
                      decoration: textInputDecoration(context, 'Admin Type'),
                      validator: (value) =>
                          _newtype.isEmpty ? 'Chois the type' : null,
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
                    customButton(
                        context: context,
                        text: 'Add Admin',
                        icon: Icons.add,
                        width: MediaQuery.of(context).size.width * 0.2,
                        onTap: () async {
                          if (_formKey.currentState.validate()) {
                            UserData userData = UserData(
                              name: _newUserName,
                              email: _newEmail,
                              language: 'English',
                            );

                            await UsersServices(useruid: userData.uid)
                                .addUserData(userData, _newtype);

                            Navigator.pop(context);
                            snackBar(context,
                                'New admin account added successfully');
                          }
                        }),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget usersList() {
    List<DataColumn> columns = [
      DataColumn(
          label: culomnItem('User Name'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'User Name');
          }),
      DataColumn(
          label: culomnItem('Email'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Email');
          }),
      DataColumn(
          label: culomnItem('Creation Date'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Creation Date');
          }),
      DataColumn(
          label: culomnItem('Last SignIn'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Last SignIn');
          }),
      DataColumn(label: culomnItem('Language')),
    ];
    List<DataRow> rows = users.map((e) {
      return DataRow(
        onSelectChanged: (value) =>
            createDialog(context, userCardInfo(e), true),
        cells: [
          DataCell(Text(e.name)),
          DataCell(Text(e.email)),
          DataCell(
              Text(DateFormat('yyyy-MM-dd').format(e.creationDate.toDate()))),
          DataCell(Text(
              DateFormat('yyyy-MM-dd H:mm').format(e.lastSignIn.toDate()))),
          DataCell(Text(e.language)),
        ],
      );
    }).toList();
    return dataTable(columns, rows);
  }

  Widget psychiatristsList() {
    List<DataColumn> columns = [
      DataColumn(
          label: culomnItem('User Name'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'User Name');
          }),
      DataColumn(
          label: culomnItem('Clinic Name'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Clinic Name');
          }),
      DataColumn(
          label: culomnItem('Email'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Email');
          }),
      DataColumn(label: culomnItem('Phone')),
      DataColumn(
          label: culomnItem('Creation Date'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Creation Date');
          }),
      DataColumn(
          label: culomnItem('Last SignIn'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Last SignIn');
          }),
      DataColumn(label: culomnItem('Language')),
      DataColumn(
          label: culomnItem('Validation'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Validation');
          }),
    ];
    List<DataRow> rows = users.map((e) {
      return DataRow(
        onSelectChanged: (value) =>
            createDialog(context, userCardInfo(e), true),
        cells: [
          DataCell(Text(e.name)),
          DataCell(Text(e.clinicName)),
          DataCell(Text(e.email)),
          DataCell(Text(e.phone)),
          DataCell(
              Text(DateFormat('yyyy-MM-dd').format(e.creationDate.toDate()))),
          DataCell(Text(
              DateFormat('yyyy-MM-dd H:mm').format(e.lastSignIn.toDate()))),
          DataCell(Text(e.language)),
          DataCell(!e.validated
              ? deleteButton(context, () {
                  print(e.uid);
                  UsersServices().validateDoctor(e.uid);
                },
                  text: 'Validate', color: Colors.green, icon: Icons.cloud_done)
              : Icon(Icons.done)),
        ],
      );
    }).toList();
    return dataTable(columns, rows);
  }

  Widget adminsList() {
    List<DataColumn> columns = [
      DataColumn(
          label: culomnItem('User Name'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'User Name');
          }),
      DataColumn(
          label: culomnItem('Type'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Type');
          }),
      DataColumn(
          label: culomnItem('Email'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Email');
          }),
      DataColumn(
          label: culomnItem('Creation Date'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Creation Date');
          }),
      DataColumn(
          label: culomnItem('Last SignIn'),
          onSort: (int index, bool ascending) {
            onSort(index, ascending, 'Last SignIn');
          }),
      DataColumn(label: culomnItem('Language')),
    ];
    List<DataRow> rows = users.map((e) {
      return DataRow(
        onSelectChanged: (value) =>
            createDialog(context, userCardInfo(e), true),
        cells: [
          DataCell(Text(e.name)),
          DataCell(Text(e.type)),
          DataCell(Text(e.email)),
          DataCell(
              Text(DateFormat('yyyy-MM-dd').format(e.creationDate.toDate()))),
          DataCell(Text(
              DateFormat('yyyy-MM-dd H:mm').format(e.lastSignIn.toDate()))),
          DataCell(Text(e.language)),
        ],
      );
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
                        showCheckboxColumn: false,
                        sortAscending: _isAscending,
                        sortColumnIndex: _sortColumnIndex,
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

  Widget culomnItem(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget delteAccount(String userUid) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.0),
          Text(
            'Confirm Delete Account',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.0),
          Text(
            'Are you sure you want to delete this account? once you delete it the user will lose all his data and he will not be able to access this account anymore.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          SizedBox(height: 12.0),
          Container(
            width: 100,
            child: InkWell(
              onTap: () {
                UsersServices().deleteUser(userUid);
                Navigator.pop(context);
                Navigator.pop(context);
                snackBar(context, 'The account has been deleted successfully');
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.0),
        ],
      ),
    );
  }

  Widget userCardInfo(UserData userData) {
    String type = '';
    switch (userData.type) {
      case 'user':
        type = 'Simple User';
        break;
      case 'doctor':
        type = 'Doctor';
        break;
      case 'admin':
        type = 'Admin';
        break;
      case 'superAdmin':
        type = 'Super Admin';
        break;
    }
    return Container(
      width: 500,
      height: userData.type == 'doctor' ? 530 : 350,
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: Constants.border,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close_sharp,
                      color: Colors.white,
                      size: 30.0,
                    )),
                Expanded(
                  child: Text(
                    userData.type == 'user'
                        ? 'User Card'
                        : userData.type == 'doctor'
                            ? 'Doctor Card'
                            : 'Admin Card',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(color: Colors.white),
                  ),
                ),
                userData.type == 'doctor' && !userData.validated
                    ? deleteButton(context, () {
                        UsersServices().validateDoctor(userData.uid);
                        Navigator.pop(context);
                        userData.validated = true;
                        createDialog(context, userCardInfo(userData), false);
                      },
                        text: 'Validate',
                        color: Colors.green,
                        icon: Icons.cloud_done)
                    : SizedBox(),
                SizedBox(width: 8.0),
                deleteButton(context, () {
                  createDialog(context, delteAccount(userData.uid), true);
                }, text: 'Delete User', color: Colors.red, icon: Icons.delete)
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  userCardInfoItem('User Name :', userData.name),
                  userCardInfoItem('User Email :', userData.email),
                  userData.type == 'doctor'
                      ? userCardInfoItem('Clinic Name :', userData.clinicName)
                      : SizedBox(),
                  userCardInfoItem('Account Type :', type),
                  userData.type == 'doctor'
                      ? userCardInfoItem(
                          'Account Validated :', userData.validated.toString())
                      : SizedBox(),
                  userData.type == 'doctor'
                      ? userCardInfoItem('Phone Number :', userData.phone)
                      : SizedBox(),
                  userCardInfoItem(
                      'Creation Data :',
                      DateFormat('yyyy-MM-dd')
                          .format(userData.creationDate.toDate())),
                  userCardInfoItem(
                      'Last Sign In :',
                      DateFormat('yyyy-MM-dd H:mm')
                          .format(userData.lastSignIn.toDate())),
                  userData.type == 'doctor'
                      ? userCardInfoItem('Personal Questionnaire :',
                          userData.personalQuestionnaires.length.toString())
                      : SizedBox(),
                  userData.type == 'doctor'
                      ? userCardInfoItem('Personal Hybrid :',
                          userData.personalHybrids.length.toString())
                      : SizedBox(),
                  userCardInfoItem('Used Language :', userData.language),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget userCardInfoItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
