import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/constants.dart';

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

  getAllUsers([QuerySnapshot data]) {}
  getUsersList() {}
  getPsychitristsList() {}
  getAdminsList() {}
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
    return Column(
      children: [
        Container(
          height: 40.0,
          color: Constants.border,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              mainRowItem('#', false),
              mainRowItem('User Name', true),
              mainRowItem('Email', true),
              mainRowItem('Creation Date', true),
              SizedBox()
            ],
          ),
        )
      ],
    );
  }

  Widget psychiatristsList() {
    return Container(
      child: Text('Psychiatrists List'),
    );
  }

  Widget adminsList() {
    return Container(
      child: Text('Admins List'),
    );
  }

  Widget mainRowItem(String text, bool ordorable) {
    return Row(
      children: [
        ordorable
            ? Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              )
            : SizedBox(),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
