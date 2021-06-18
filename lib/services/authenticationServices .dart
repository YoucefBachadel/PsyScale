import 'package:firebase_auth/firebase_auth.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/userServices.dart';

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
  Future registerWithEmailAndPassword(String type, String email,
      String password, String name, String clinicName, String phone) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      user.sendEmailVerification();

      // create a new document for the user with the uid
      UserData userData;
      if (type == 'user') {
        userData = UserData(
          name: name,
          email: email,
          language: 'English',
          theme: 'System',
        );
      } else {
        userData = UserData(
          name: name,
          clinicName: clinicName,
          email: email,
          phone: phone,
          language: 'English',
          theme: 'System',
        );
      }

      await UsersServices(useruid: user.uid).addUserData(userData, type);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return 'error:${e.toString()}';
    }
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
