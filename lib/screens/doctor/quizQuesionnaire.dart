import 'package:flutter/material.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class QuizQuestionnaire extends StatefulWidget {
  final Questionnaire questionnaire;
  final String languge;
  final Function changeTab;
  final int backIndex;

  const QuizQuestionnaire({
    Key key,
    this.questionnaire,
    this.languge,
    this.changeTab,
    this.backIndex,
  }) : super(key: key);
  @override
  _QuizQuestionnaireState createState() => _QuizQuestionnaireState();
}

class _QuizQuestionnaireState extends State<QuizQuestionnaire> {
  int _currentQuestionIndex = 1;
  List<int> _choises;
  int _maxScore = 0;
  int _totalScore = 0;
  bool isLoading = false;

  @override
  void initState() {
    _choises = List<int>.filled(widget.questionnaire.getQuestionsCount(), -1);

    // get the max score
    getMaxScore();

    super.initState();
  }

  getMaxScore() {
    int _maxAnswerScore = 0;
    if (widget.questionnaire.type == '2') {
      int _localmaxAnswerScore = 0;
      widget.questionnaire.questionsAnswers.forEach((questionsAnswer) {
        questionsAnswer.answers.forEach((element) {
          if ((element['score'] as int) > _maxAnswerScore) {
            _localmaxAnswerScore = element['score'];
          }
        });
        _maxScore += _localmaxAnswerScore;
      });
    } else {
      widget.questionnaire.answers.forEach((element) {
        if ((element['score'] as int) > _maxAnswerScore) {
          _maxAnswerScore = element['score'];
        }
      });
      _maxScore = _maxAnswerScore * widget.questionnaire.questions.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? mainView()
        : desktopWidget(Container(), Container(), mainView());
  }

  Widget mainView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.border,
        iconTheme: IconThemeData(color: Constants.myGrey),
        elevation: 0.0,
      ),
      body: isLoading
          ? loading(context)
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              color: Constants.border,
              child: Column(
                children: [
                  Text(
                    widget.questionnaire.getName(widget.languge),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 35,
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff3f4768), width: 3),
                        borderRadius: BorderRadius.circular(50)),
                    child: Stack(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) => Container(
                            width: constraints.maxWidth *
                                ((_currentQuestionIndex - 1) /
                                    widget.questionnaire
                                        .getQuestionsCount()), //cover 50%
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).accentColor,
                                  Colors.white
                                ],
                                stops: [0.6, 1],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                tileMode: TileMode.repeated,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text.rich(
                    _currentQuestionIndex <=
                            widget.questionnaire.getQuestionsCount()
                        ? TextSpan(
                            text: 'Question $_currentQuestionIndex',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(color: Constants.myGrey),
                            children: [
                                TextSpan(
                                    text:
                                        '/${widget.questionnaire.getQuestionsCount()}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        .copyWith(color: Constants.myGrey))
                              ])
                        : TextSpan(
                            text: 'Done!!',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(color: Constants.myGrey),
                          ),
                  ),
                  Spacer(flex: 1),
                  divider(),
                  Spacer(flex: 2),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: _currentQuestionIndex <=
                            widget.questionnaire.getQuestionsCount()
                        ? questionsQuiz()
                        : score(),
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),
    );
  }

  Widget questionsQuiz() {
    String _question = '';
    List<Map<String, Object>> _answers = [];

    if (widget.questionnaire.type == '1') {
      _question = widget.questionnaire
          .getQuesionsList(widget.languge)[_currentQuestionIndex - 1];
      _answers = widget.questionnaire.getAnswersList(widget.languge, 0);
    } else {
      _question = widget.questionnaire
          .getQuesAnsQuestion(widget.languge, _currentQuestionIndex - 1);
      _answers = widget.questionnaire
          .getAnswersList(widget.languge, _currentQuestionIndex - 1);
    }

    return Column(
      children: [
        Text(
          _question,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10.0),
        Column(
          children: _answers
              .map(
                (answer) => InkWell(
                  onTap: () {
                    setState(() {
                      _choises[_currentQuestionIndex - 1] = answer['score'];
                    });
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width - 100,
                      margin: EdgeInsets.only(top: 10.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 2.0,
                            color: _choises[_currentQuestionIndex - 1] ==
                                    answer['score']
                                ? Theme.of(context).accentColor
                                : Constants.myGrey),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        answer['answer'],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Constants.myGrey,
                            fontWeight: FontWeight.w400),
                      )),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _currentQuestionIndex == 1
                ? SizedBox()
                : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_outlined),
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        }),
                  ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: IconButton(
                  icon: Icon(_currentQuestionIndex ==
                          widget.questionnaire.getQuestionsCount()
                      ? Icons.done
                      : Icons.arrow_forward_ios_outlined),
                  onPressed: () {
                    _choises[_currentQuestionIndex - 1] != -1
                        ? setState(() {
                            _currentQuestionIndex++;
                          })
                        : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            elevation: 1.0,
                            content: Text('You have to choise'),
                            duration: Duration(seconds: 2),
                          ));
                  }),
            ),
          ],
        )
      ],
    );
  }

  Widget score() {
    String _message = '';

    // get the total score
    _totalScore = 0;
    _choises.forEach((element) {
      _totalScore += element;
    });

    // get the right message for the total score
    widget.questionnaire.getEvaluationList(widget.languge).forEach((element) {
      if (_totalScore >= element['from'] && _totalScore <= element['to']) {
        _message = element['message'];
      }
    });

    return Column(
      children: [
        Text(
          'Score:',
          style: Theme.of(context)
              .textTheme
              .headline3
              .copyWith(color: Constants.myGrey),
        ),
        Text('$_totalScore/$_maxScore',
            style: Theme.of(context)
                .textTheme
                .headline2
                .copyWith(color: Colors.black)),
        SizedBox(height: 15.0),
        Text(_message,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.black)),
        SizedBox(height: MediaQuery.of(context).size.height / 5),
        InkWell(
          onTap: () {
            if (Responsive.isMobile(context)) {
              Navigator.pop(context);
            } else {
              widget.changeTab(
                index: widget.backIndex,
                backAppbarTitle:
                    widget.backIndex == 5 ? 'Troubles' : 'Questionnaires',
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18.0),
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            child: Text(
              'Done',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
