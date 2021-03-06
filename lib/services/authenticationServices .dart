import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/widgets.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj base on FairebaseUser
  CurrentUser _userFromFirebaseUser(User user) {
    return user != null ? CurrentUser(uid: user.uid, email: user.email) : null;
  }

  // auth change user stream
  Stream<CurrentUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in with email/password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return 'error:${e.toString()}';
    }
  }

  // register with email/password
  Future registerWithEmailAndPassword(
      BuildContext context,
      String type,
      String email,
      String password,
      String name,
      String clinicName,
      String phone) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;

      // create a new document for the user with the uid
      UserData userData;
      if (type == 'user') {
        user.sendEmailVerification();
        userData = UserData(
          name: name,
          email: email,
          language: 'English',
        );
      } else {
        userData = UserData(
          name: name,
          clinicName: clinicName,
          email: email,
          phone: phone,
          language: 'English',
        );
      }

      await UsersServices(useruid: user.uid).addUserData(userData, type);

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return 'error:${e.toString()}';
    }
  }

  // send password changing email
  Future forgotPassword(BuildContext context, String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    snackBar(context, 'We have sent you an email, check your box!');
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
