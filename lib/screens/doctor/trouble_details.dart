import 'package:flutter/material.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/screens/doctor/quizHybrid.dart';
import 'package:psyscale/screens/doctor/quizQuesionnaire.dart';
import 'package:psyscale/shared/customSplashFactory.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class TroubleDetails extends StatefulWidget {
  final Trouble trouble;
  final String language;
  final Function changeTab;

  const TroubleDetails({Key key, this.trouble, this.language, this.changeTab})
      : super(key: key);
  @override
  _TroubleDetailsState createState() => _TroubleDetailsState();
}

class _TroubleDetailsState extends State<TroubleDetails>
    with TickerProviderStateMixin {
  var _scrollController, _tabController;
  List<bool> troubleExpanded = [];

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 3);
    troubleExpanded = List.filled(widget.trouble.hybrids.length, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Responsive.isdesktop(context)
            ? desktopWidget(Container(), Container(), bodyView())
            : bodyView());
  }

  Widget bodyView() {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height / 3,
            floating: true,
            pinned: true,
            snap: true,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            title: Hero(
              tag: widget.trouble.getName(widget.language),
              child: Material(
                color: Colors.transparent,
                child: Text(
                  widget.trouble.getName(widget.language),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            actionsIconTheme: IconThemeData(opacity: 0.0),
            elevation: 2.0,
            flexibleSpace: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: widget.trouble.imageUrl,
                    child: loadingImage(context, widget.trouble.imageUrl),
                  ),
                ),
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
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Constants.border,
                      ],
                      stops: [0.7, 1],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      tileMode: TileMode.repeated,
                    ),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Hero(
                tag: 'tabbar',
                child: Material(
                  color: Constants.border,
                  child: TabBar(
                    indicatorColor: Theme.of(context).accentColor,
                    labelColor: Theme.of(context).accentColor,
                    unselectedLabelColor: Colors.white,
                    tabs: <Tab>[
                      Tab(text: "About"),
                      Tab(text: "Questionnaires"),
                      Tab(text: "Hybrid"),
                    ],
                    controller: _tabController,
                  ),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            troubleDescreption(),
            troubleQuestionnaireList(),
            troubleHybridList(),
          ],
        ),
      ),
    );
  }

  Widget troubleDescreption() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            text: widget.trouble.getDescreption(widget.language),
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ),
    );
  }

  Widget troubleQuestionnaireList() {
    return widget.trouble.questionnaires.isEmpty
        ? emptyList()
        : ListView(
            children: widget.trouble.questionnaires
                .map(
                  (questionnaire) => Card(
                    color: Constants.border,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.border, width: 2.0),
                        borderRadius: BorderRadius.circular(15.0)),
                    elevation: 2.0,
                    child: InkWell(
                      onTap: () {
                        bool _isExpanded = !questionnaire.isExpanded;
                        widget.trouble.questionnaires.forEach((element) {
                          element.isExpanded = false;
                        });

                        setState(() {
                          questionnaire.isExpanded = _isExpanded;
                        });
                      },
                      splashColor: Theme.of(context).accentColor,
                      splashFactory: CustomSplashFactory(),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              questionnaire.getName(widget.language),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${questionnaire.getQuestionsCount()} questions',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                      color: Constants.myGrey,
                                      fontWeight: FontWeight.w300),
                            ),
                          ),
                          questionnaire.isExpanded
                              ? Container(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    questionnaire
                                        .getDescreption(widget.language),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: Colors.white),
                                  ),
                                )
                              : SizedBox(),
                          questionnaire.isExpanded
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 50.0),
                                  child: InkWell(
                                    onTap: () {
                                      if (Responsive.isMobile(context)) {
                                        Constants.navigationFunc(
                                          context,
                                          QuizQuestionnaire(
                                            questionnaire: questionnaire,
                                            languge: widget.language,
                                          ),
                                        );
                                      } else {
                                        widget.changeTab(
                                          index: 2,
                                          questionnaire: questionnaire,
                                          language: widget.language,
                                          backIndex: 5,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).accentColor,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        'Start Test',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
  }

  Widget troubleHybridList() {
    int index = -1;
    return widget.trouble.hybrids.isEmpty
        ? emptyList()
        : Container(
            color: Theme.of(context).backgroundColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ExpansionPanelList(
                    animationDuration:
                        Duration(milliseconds: Constants.animationDuration),
                    expansionCallback: (panelIndex, isExpanded) {
                      setState(() {
                        troubleExpanded[panelIndex] = !isExpanded;
                      });
                    },
                    children: widget.trouble.hybrids
                        .map((Questionnaire questionnaire) {
                      index++;
                      return ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(
                              questionnaire.getName(widget.language),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            subtitle: Text(
                              '${questionnaire.getQuestionsCount() + 1} questions',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(fontWeight: FontWeight.w300),
                            ),
                          );
                        },
                        canTapOnHeader: true,
                        isExpanded: troubleExpanded[index],
                        body: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                questionnaire.getDescreption(widget.language),
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 50.0),
                                child: InkWell(
                                  onTap: () {
                                    if (Responsive.isMobile(context)) {
                                      Constants.navigationFunc(
                                        context,
                                        QuizHybrid(
                                          questionnaire: questionnaire,
                                          languge: widget.language,
                                        ),
                                      );
                                    } else {
                                      widget.changeTab(
                                        index: 3,
                                        questionnaire: questionnaire,
                                        language: widget.language,
                                        backIndex: 5,
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).accentColor,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      'Start Test',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }
}
