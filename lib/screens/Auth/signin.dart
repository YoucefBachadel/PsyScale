import 'package:flutter/material.dart';
import 'package:psyscale/main.dart';
import 'package:psyscale/screens/Auth/signup.dart';

import 'package:psyscale/services/authenticationServices%20.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password;
  AuthService authService = AuthService();
  bool isLoading = false;

  signIn() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService
          .signInWithEmailAndPassword(email, password)
          .then((value) {
        if (value.toString().split(':')[0] != 'error') {
          setState(() {
            isLoading = false;
          });
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Wrapper()));
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 1.0,
            content: Text((value as String).split(':')[1].split(']')[1]),
            duration: Duration(seconds: 5),
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? signInForm()
        : Scaffold(body: desktopWidget(Container(), Container(), signInForm()));
  }

  Widget signInForm() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: Responsive.isMobile(context)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            )
          : null,
      body: isLoading
          ? loading(context)
          : Container(
              color: Theme.of(context).backgroundColor,
              child: Form(
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Spacer(flex: 1),
                      appBar(context, 'Sign', 'In'),
                      Spacer(flex: 5),
                      TextFormField(
                        initialValue: email,
                        validator: (value) =>
                            value.isEmpty ? 'Enter the Email' : null,
                        decoration: textInputDecoration(context, 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: [AutofillHints.email],
                        onChanged: (value) => email = value,
                      ),
                      SizedBox(height: 6.0),
                      TextFormField(
                        obscureText: true,
                        validator: (value) =>
                            value.isEmpty ? 'Enter the Password' : null,
                        decoration: textInputDecoration(context, 'Password'),
                        onChanged: (value) => password = value,
                      ),
                      SizedBox(
                        height: 14.0,
                      ),
                      InkWell(
                        onTap: () {
                          signIn();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 18.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          width: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width
                              : screenWidth * 0.2,
                          child: Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 18.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have  an account ? ',
                            style: TextStyle(fontSize: 15.5),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()));
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 15.5,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 80.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
