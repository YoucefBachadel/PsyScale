import 'package:flutter/material.dart';
import 'package:psyscale/services/auth.dart';

class DoctorHome extends StatefulWidget {
  @override
  _DoctorHomeState createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor'),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: Text(
              'logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text('Doctor Home Page'),
      ),
    );
  }
}
