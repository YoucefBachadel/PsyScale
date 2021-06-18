import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psyscale/main.dart';
import 'package:psyscale/screens/Auth/signin.dart';
import 'package:psyscale/services/authenticationServices%20.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? SignUpForm()
        : Scaffold(body: desktopWidget(Container(), Container(), SignUpForm()));
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '', clinicName = '', phone, email = '', password;
  AuthService authService = AuthService();
  bool _isLoading = false;
  bool _isDoctor = false;

  signUp() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      if (_isDoctor) {
        await authService
            .registerWithEmailAndPassword(
                'doctor', email, password, name, clinicName, phone)
            .then((value) {
          if (value.toString().split(':')[0] != 'error') {
            setState(() {
              _isLoading = false;
            });
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Wrapper()));
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              elevation: 1.0,
              content: Text((value as String).split(':')[1].split(']')[1]),
              duration: Duration(seconds: 5),
            ));
          }
        });
      } else {
        await authService
            .registerWithEmailAndPassword(
                'user', email, password, name, null, null)
            .then((value) {
          if (value.toString().split(':')[0] != 'error') {
            setState(() {
              _isLoading = false;
            });
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Wrapper()));
          } else {
            setState(() {
              _isLoading = false;
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
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: Responsive.isMobile(context)
          ? AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              elevation: 0.0,
            )
          : null,
      body: _isLoading
          ? loading(context)
          : Container(
              color: Theme.of(context).backgroundColor,
              child: Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),
                      appBar(context, 'Sign', 'Up'),
                      const Spacer(flex: 5),
                      TextFormField(
                        initialValue: name,
                        validator: (value) =>
                            value.isEmpty ? 'Enter the Name' : null,
                        decoration: textInputDecoration(context, 'Name'),
                        onChanged: (value) => name = value,
                      ),
                      const SizedBox(height: 6.0),
                      _isDoctor
                          ? TextFormField(
                              initialValue: clinicName,
                              decoration:
                                  textInputDecoration(context, 'Clinic Name'),
                              onChanged: (value) => clinicName = value,
                            )
                          : const SizedBox(),
                      _isDoctor
                          ? const SizedBox(height: 6.0)
                          : const SizedBox(height: 0.0),
                      _isDoctor
                          ? TextFormField(
                              initialValue: phone,
                              validator: (value) => value.length != 10
                                  ? 'Enter correct phone number'
                                  : null,
                              decoration:
                                  textInputDecoration(context, 'Phone number'),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) => phone = value,
                            )
                          : const SizedBox(),
                      _isDoctor
                          ? const SizedBox(height: 6.0)
                          : const SizedBox(height: 0.0),
                      TextFormField(
                        initialValue: email,
                        validator: (value) => value.isEmpty
                            ? 'Enter the Email'
                            : !['gmail.com', 'yahoo.com', 'hotmail.com']
                                    .contains(value.split('@')[1].toLowerCase())
                                ? 'Enter a valid email format'
                                : null,
                        decoration: textInputDecoration(context, 'Email'),
                        onChanged: (value) => email = value,
                      ),
                      const SizedBox(height: 6.0),
                      TextFormField(
                        obscureText: true,
                        validator: (value) =>
                            value.isEmpty ? 'Enter the Password' : null,
                        decoration: textInputDecoration(context, 'Password'),
                        onChanged: (value) => password = value,
                      ),
                      const SizedBox(height: 14.0),
                      InkWell(
                        onTap: () {
                          signUp();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          width: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width
                              : screenWidth * 0.2,
                          child: Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isDoctor
                                ? 'You are a user ? '
                                : 'You are a doctor ? ',
                            style: TextStyle(fontSize: 15.5),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isDoctor = !_isDoctor;
                              });
                            },
                            child: Text(
                              _isDoctor
                                  ? 'Create a user account'
                                  : 'Create a doctor account',
                              style: TextStyle(
                                fontSize: 15.5,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'or',
                        style: TextStyle(fontSize: 15.5),
                      ),
                      const SizedBox(height: 6.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have  an account ? ',
                            style: TextStyle(fontSize: 15.5),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignIn()));
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 15.5,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 80.0),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
