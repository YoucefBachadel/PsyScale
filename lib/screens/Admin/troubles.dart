import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/screens/Admin/add_troubles.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class Troubles extends StatefulWidget {
  final ValueListenable<String> search;
  const Troubles({Key key, this.search}) : super(key: key);
  @override
  _TroublesState createState() => _TroublesState();
}

class _TroublesState extends State<Troubles> {
  List<Trouble> allTroubles = [];
  List<Trouble> troubles = [];

  getTroublesList(QuerySnapshot data, String language) async {
    allTroubles.clear();
    troubles.clear();
    if (data != null) {
      data.docs.forEach((doc) {
        allTroubles.add(Trouble(
          uid: doc.id,
          nameEn: doc['nameEn'],
          nameFr: doc['nameFr'],
          nameAr: doc['nameAr'],
          questionnaresCount: doc['questionnaresCount'],
          descreptionEn: doc['descreptionEn'],
          descreptionFr: doc['descreptionFr'],
          descreptionAr: doc['descreptionAr'],
          imageUrl: doc['imageUrl'],
        ));
      });
      allTroubles.forEach((element) {
        if (element
            .getName(language)
            .toLowerCase()
            .contains(widget.search.value.toLowerCase())) {
          troubles.add(element);
        }
      });
      troubles
          .sort((a, b) => a.getName(language).compareTo(b.getName(language)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      body: StreamBuilder(
          stream: TroublesServices().troubleData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              QuerySnapshot data = snapshot.data;
              getTroublesList(data, userData.language);
              return desktopWidget(
                Container(),
                Container(),
                troublesList(),
              );
            } else {
              return loading(context);
            }
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          createDialog(
              context,
              Container(
                width: 700.0,
                child: AddTroubles(trouble: null),
              ),
              false);
        },
      ),
    );
  }

  Widget troublesList() {
    final userData = Provider.of<UserData>(context);
    return Container(
        child: troubles.isEmpty
            ? emptyList()
            : Material(
                color: Theme.of(context).backgroundColor,
                child: GridView.count(
                  crossAxisCount: Responsive.isMobile(context) ? 1 : 2,
                  childAspectRatio: 1.8,
                  children: troubles
                      .map(
                        (trouble) => Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Constants.border, width: 3.0),
                              borderRadius: BorderRadius.circular(15.0)),
                          elevation: 2.0,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                bottom: 0.0,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    loadingImage(context, trouble.imageUrl),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Constants.border,
                                          ],
                                          stops: [0.6, 1],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          tileMode: TileMode.repeated,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 10.0,
                                        child: Text(
                                          trouble.getName(userData.language),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24.0),
                                        )),
                                  ],
                                ),
                              ),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      splashColor:
                                          Theme.of(context).accentColor,
                                      onTap: () {
                                        createDialog(
                                            context,
                                            Container(
                                                width: 700.0,
                                                child: AddTroubles(
                                                    trouble: trouble)),
                                            false);
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ));
  }
}
