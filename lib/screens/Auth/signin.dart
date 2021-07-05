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
  bool emailSended = false;

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
          if (Responsive.isMobile(context)) {
            Navigator.pop(context);
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Wrapper()));
        } else {
          setState(() {
            isLoading = false;
          });
          snackBar(context, (value as String).split(':')[1].split(']')[1]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context) ? mobileView() : desctopView();
  }

  Widget mobileView() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.0,
        ),
        body: signInForm());
  }

  Widget desctopView() {
    return Scaffold(
      body: Container(
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 200),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.0)),
          child: Container(
            width: double.infinity,
            height: 650,
            padding: const EdgeInsets.all(35.0),
            child: Row(
              children: [
                Responsive.isdesktop(context)
                    ? Expanded(
                        child: Container(
                            child: Ink.image(
                                image: AssetImage('assets/signin.jpg'),
                                fit: BoxFit.contain)),
                      )
                    : SizedBox(),
                SizedBox(width: 35),
                Container(
                  width: 465,
                  child: signInForm(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signInForm() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return isLoading
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
                      // autofillHints: [AutofillHints.email],
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
                    SizedBox(height: 14.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t remember your password ? ',
                          style: TextStyle(fontSize: 15.5),
                        ),
                        InkWell(
                          onTap: () async {
                            if (!emailSended) {
                              if (email.isNotEmpty) {
                                authService.forgotPassword(context, email);
                                emailSended = true;
                              } else {
                                snackBar(context, 'First, Enter your email!!');
                              }
                            } else {
                              snackBar(context,
                                  'We\'ve already sent you an email!!');
                            }
                          },
                          child: Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 15.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 14.0),
                    customButton(
                        context: context,
                        text: 'Sign In',
                        icon: Icons.login,
                        width: Responsive.isMobile(context)
                            ? MediaQuery.of(context).size.width
                            : screenWidth * 0.2,
                        onTap: () {
                          signIn();
                        }),
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
          );
  }
}
