import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/classes/Language.dart';
import 'package:psyscale/main.dart';
import 'package:psyscale/services/authenticationServices%20.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/theme_provider.dart';
import 'package:psyscale/shared/widgets.dart';

class ProfileDoctor extends StatefulWidget {
  final UserData userData;

  const ProfileDoctor({Key key, this.userData}) : super(key: key);

  @override
  _ProfileDoctorState createState() => _ProfileDoctorState();
}

class _ProfileDoctorState extends State<ProfileDoctor> {
  String _userName, _language, _phone, _clinicName;
  AuthService _auth = AuthService();
  bool isLoading = false;
  bool changeUserName = false;
  save(UserData userData) async {
    if (_userName != widget.userData.name ||
        _clinicName != widget.userData.clinicName ||
        _phone != widget.userData.phone ||
        _language != widget.userData.language) {
      setState(() {
        isLoading = true;
      });

      await UsersServices(useruid: widget.userData.uid).updateUserData(
          UserData(
            uid: widget.userData.uid,
            name: _userName == null ? widget.userData.name : _userName,
            clinicName:
                _clinicName == null ? widget.userData.clinicName : _clinicName,
            phone: _phone == null ? widget.userData.phone : _phone,
            email: widget.userData.email,
            type: widget.userData.type,
            language: _language == null ? widget.userData.language : _language,
            history: widget.userData.history,
          ),
          'doctor');

      setState(() {
        isLoading = false;
      });
    }
    Navigator.pop(context);
  }

  logout() async {
    await _auth.signOut();
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Wrapper()),
    );
  }

  @override
  void initState() {
    _userName = widget.userData.name;
    _language = widget.userData.language;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return isLoading
        ? loading(context)
        : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                width: 0.5,
                color: Constants.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                          'Settings',
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Name:',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          decoration: textInputDecoration(
                              context, widget.userData.name),
                          onChanged: (value) => value.isEmpty
                              ? _userName = widget.userData.name
                              : _userName = value,
                        ),
                        Text(
                          'Clinic Name:',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          decoration: textInputDecoration(
                              context, widget.userData.clinicName),
                          onChanged: (value) => value.isEmpty
                              ? _clinicName = widget.userData.clinicName
                              : _clinicName = value,
                        ),
                        Text(
                          'Phone:',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          decoration: textInputDecoration(
                              context, widget.userData.phone),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) => value.isEmpty
                              ? _phone = widget.userData.phone
                              : _phone = value,
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          'Theme:',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 60.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              width: 2,
                              color: Constants.myGrey,
                            ),
                          ),
                          child: themes(),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          'Language:',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 60.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border:
                                Border.all(width: 2, color: Constants.myGrey),
                          ),
                          child: languages(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                customButton(
                    context: context,
                    text: 'Save',
                    icon: Icons.save,
                    width: Responsive.isMobile(context)
                        ? screenWidth
                        : screenWidth * 0.2,
                    onTap: () {
                      save(widget.userData);
                    }),
                const SizedBox(height: 10),
                customButton(
                    context: context,
                    text: 'Logout',
                    icon: Icons.logout,
                    width: Responsive.isMobile(context)
                        ? screenWidth
                        : screenWidth * 0.2,
                    onTap: () {
                      logout();
                    }),
                const SizedBox(height: 10),
              ],
            ),
          );
  }

  Widget themes() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              themeProvider.toggleTheme('System');
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0)),
                color: themeProvider.themeMode == ThemeMode.system
                    ? Theme.of(context).accentColor
                    : Theme.of(context).backgroundColor,
              ),
              child: Text(
                'System',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              themeProvider.toggleTheme('Light');
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              color: themeProvider.themeMode == ThemeMode.light
                  ? Theme.of(context).accentColor
                  : Theme.of(context).backgroundColor,
              child: Text(
                'Light',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              themeProvider.toggleTheme('Dark');
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0)),
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Theme.of(context).accentColor
                    : Theme.of(context).backgroundColor,
              ),
              child: Text(
                'Dark',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget languages() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _language = 'English';
              });
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0)),
                color: _language == 'English'
                    ? Theme.of(context).accentColor
                    : Theme.of(context).backgroundColor,
              ),
              child: Text(
                'English',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _language = 'Français';
              });
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              color: _language == 'Français'
                  ? Theme.of(context).accentColor
                  : Theme.of(context).backgroundColor,
              child: Text(
                'Français',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _language = 'العربية';
              });
            },
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0)),
                color: _language == 'العربية'
                    ? Theme.of(context).accentColor
                    : Theme.of(context).backgroundColor,
              ),
              child: Text(
                'العربية',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
