import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/classes/Language.dart';
import 'package:psyscale/main.dart';
import 'package:psyscale/services/authenticationServices%20.dart';
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
  File _image;
  String imageUrl;
  UploadTask task;
  save(UserData userData) async {
    if (_userName != widget.userData.name ||
        _language != widget.userData.language ||
        _theme != widget.userData.theme ||
        _image != null) {
      setState(() {
        isLoading = true;
      });
      await UsersServices(useruid: widget.userData.uid).updateUserData(
          UserData(
            uid: widget.userData.uid,
            name: _userName == null ? widget.userData.name : _userName,
            email: widget.userData.email,
            imageUrl:
                _image != null ? 'users/${widget.userData.uid}' : 'avatar.png',
            type: widget.userData.type,
            language: _language == null ? widget.userData.language : _language,
            theme: _theme == null ? widget.userData.theme : _theme,
            history: widget.userData.history,
          ),
          'user');
      setState(() {
        isLoading = false;
      });
    }
    if (Responsive.isMobile(context)) {
      Navigator.pop(context);
    }
  }

  Future saveImage(UserData userData) async {
    if (_image != null) {
      await uploadFile().whenComplete(() => save(userData));
    } else {
      return save(userData);
    }
  }

  logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Wrapper()),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (result == null) return;
    final path = result.files.single.path;

    setState(() {
      _image = File(path);
    });
  }

  Future uploadFile() async {
    final destination = 'users/${widget.userData.uid}';
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      // task = ref.putFile(_image);
      ref.putFile(_image);
    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }

    setState(() {});

    if (task == null) return;

    await task.whenComplete(() {});
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              'uploading image: $percentage %',
            );
          } else {
            return Container();
          }
        },
      );

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
                  Responsive.isMobile(context)
                      ? Center(
                          child: Hero(
                            tag: widget.userData.name,
                            child: Stack(
                              children: [
                                _image != null
                                    ? CircleAvatar(
                                        radius: 100,
                                        backgroundImage: FileImage(_image))
                                    : FutureBuilder(
                                        future: UsersServices.getUserImage(
                                            context, widget.userData.imageUrl),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return ClipOval(
                                              child: Container(
                                                width: 200,
                                                height: 200,
                                                child: snapshot.data,
                                              ),
                                            );
                                          } else {
                                            return SpinKitPulse(
                                              color:
                                                  Theme.of(context).accentColor,
                                              size: 50.0,
                                            );
                                          }
                                        },
                                      ),
                                Positioned(
                                  bottom: 0,
                                  right: 4,
                                  child: ClipOval(
                                    child: Container(
                                      padding: const EdgeInsets.all(3.0),
                                      color: Colors.white,
                                      child: InkWell(
                                        onTap: () => selectFile(),
                                        child: ClipOval(
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            color:
                                                Theme.of(context).accentColor,
                                            child: Icon(
                                              Icons.edit,
                                              size: 20.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                  const SizedBox(height: 4),
                  task != null ? buildUploadStatus(task) : const SizedBox(),
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userData.email,
                    style: TextStyle(color: Colors.grey),
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
                      saveImage(widget.userData);
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
