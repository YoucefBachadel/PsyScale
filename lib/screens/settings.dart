import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/classes/Language.dart';
import 'package:psyscale/main.dart';
import 'package:psyscale/services/auth.dart';
import 'package:psyscale/services/userServices.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/theme_provider.dart';
import 'package:psyscale/shared/widgets.dart';

class Setting extends StatefulWidget {
  final UserData userData;

  const Setting({Key key, this.userData}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final List<String> themes = ['System', 'Light', 'Dark'];
  String _userName, _language, _theme;
  AuthService _auth = AuthService();
  bool isLoading = false;
  bool changeUserName = false;

  save(UserData userData) async {
    if (_userName != widget.userData.name ||
        _language != widget.userData.language ||
        _theme != widget.userData.theme) {
      setState(() {
        isLoading = true;
      });
      await UsersServices(useruid: widget.userData.uid).updateUserData(UserData(
        uid: widget.userData.uid,
        name: _userName == null ? widget.userData.name : _userName,
        email: widget.userData.email,
        type: widget.userData.type,
        language: _language == null ? widget.userData.language : _language,
        theme: _theme == null ? widget.userData.theme : _theme,
        history: widget.userData.history,
      ));
      setState(() {
        isLoading = false;
      });
    }
    if (Responsive.isMobile(context)) {
      Navigator.pop(context);
    }
  }

  logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Wrapper()),
    );
  }

  @override
  void initState() {
    _userName = widget.userData.name;
    _language = widget.userData.language;
    _theme = widget.userData.theme;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? Scaffold(
            appBar: widget.userData.type != 'doctor'
                ? AppBar(
                    title: appBar(context, 'Settings', ''),
                    centerTitle: true,
                  )
                : null,
            body: settingContainer(),
          )
        : Scaffold(
            body: desktopWidget(
              Container(),
              Container(),
              settingContainer(),
            ),
          );
  }

  Widget settingContainer() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    return isLoading
        ? loading(context)
        : Container(
            color: Theme.of(context).backgroundColor,
            child: Padding(
              padding: EdgeInsets.fromLTRB(30, 40, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Hero(
                      tag: widget.userData.name,
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar.jpg'),
                        radius: 80.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  changeUserName
                      ? TextFormField(
                          decoration: textInputDecoration(
                              context, widget.userData.name),
                          onChanged: (value) => value.isEmpty
                              ? _userName = widget.userData.name
                              : _userName = value,
                        )
                      : InkWell(
                          onTap: () {
                            setState(() {
                              changeUserName = true;
                            });
                          },
                          child: Text(
                            widget.userData.name,
                            style: TextStyle(
                              color: Colors.amberAccent[200],
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userData.email,
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(flex: 1),
                  divider(),
                  const Spacer(flex: 2),
                  Responsive.isMobile(context)
                      ? DropdownButtonFormField(
                          decoration: textInputDecoration(context, 'Theme'),
                          items: themes.map((themes) {
                            return DropdownMenuItem(
                              value: themes,
                              child: Text(themes),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _theme = value;
                            themeProvider.toggleTheme(value);
                          },
                        )
                      : const SizedBox(),
                  const SizedBox(height: 10.0),
                  DropdownButtonFormField(
                    decoration: textInputDecoration(context, 'Language'),
                    items: Language.languageList().map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Row(
                          children: [
                            Responsive.isMobile(context)
                                ? Text(
                                    language.flag,
                                    style: TextStyle(fontSize: 20),
                                  )
                                : const SizedBox(),
                            const SizedBox(width: 6.0),
                            Text(language.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Language language) {
                      _language = language.name;
                    },
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      save(widget.userData);
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
                        'Save',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      logout();
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
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
  }
}
