import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:psyscale/main.dart';
import 'package:psyscale/screens/Auth/signin.dart';
import 'package:psyscale/services/authenticationServices%20.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
            Navigator.pop(context);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Wrapper()));
          } else {
            setState(() {
              _isLoading = false;
            });
            snackBar(context, (value as String).split(':')[1].split(']')[1]);
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
            if (Responsive.isMobile(context)) {
              Navigator.pop(context);
            }
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Wrapper()));
          } else {
            setState(() {
              _isLoading = false;
            });
            snackBar(context, (value as String).split(':')[1].split(']')[1]);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isMobile(context)) {
      _isDoctor = true;
    }
    return Responsive.isMobile(context) ? mobileView() : desctopView();
  }

  Widget mobileView() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.0,
        ),
        body: signUpForm());
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
                Container(
                  width: 465,
                  child: signUpForm(),
                ),
                SizedBox(width: 35),
                Responsive.isdesktop(context)
                    ? Expanded(
                        child: Container(
                            child: Ink.image(
                                image: AssetImage('assets/signup.jpg'),
                                fit: BoxFit.contain)),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signUpForm() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return _isLoading
        ? loading(context)
        : Container(
            color: Theme.of(context).backgroundColor,
            child: Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    appBar(
                      context,
                      'Sign Up As ',
                      _isDoctor ? 'Doctor' : 'User',
                    ),
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
                    customButton(
                        context: context,
                        text: 'Sign Up',
                        icon: MdiIcons.account,
                        width: Responsive.isMobile(context)
                            ? MediaQuery.of(context).size.width
                            : screenWidth * 0.2,
                        onTap: () {
                          signUp();
                        }),
                    const SizedBox(height: 18.0),
                    Responsive.isMobile(context)
                        ? Row(
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
                          )
                        : const SizedBox(),
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
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          );
  }
}
