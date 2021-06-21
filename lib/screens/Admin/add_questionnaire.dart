import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psyscale/classes/QuestionAnswer.dart';
import 'package:psyscale/classes/Questionnaire.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/classes/User.dart';
import 'package:psyscale/services/questionnaireServices.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class AddQuestionnaire extends StatefulWidget {
  final Questionnaire questionnaire;
  final UserData userData;
  final Function changeTab;

  const AddQuestionnaire(
      {Key key, this.userData, this.questionnaire, this.changeTab})
      : super(key: key);
  @override
  _AddQuestionnaireState createState() => _AddQuestionnaireState();
}

class _AddQuestionnaireState extends State<AddQuestionnaire> {
  List<Trouble> troubles = [];
  bool isLoading = false;
  List<String> _steps = [
    'Questionnaire Informations',
    'List Of Questions',
    'List Of Answers',
    'List Of Evaluations'
  ];
  int _currentStep = 1;
  String _type = '1';
  String _troubleUid;
  String _nameEn = '';
  String _nameFr = '';
  String _nameAr = '';
  String _descreptionEn = '';
  String _descreptionFr = '';
  String _descreptionAr = '';
  int _localFrom = 0;
  String _localQuestionEn = '';
  String _localQuestionFr = '';
  String _localQuestionAr = '';
  List<Map<String, Object>> _questions = [];
  List<Map<String, Object>> _answers = [];
  List<QuestionAnswer> _questionsAnswers = [];
  List<Map<String, Object>> _localAnswers = [];
  List<Map<String, Object>> _evaluations = [];
  QuestionnairesServices questionnairesServices = QuestionnairesServices();

  getTroublesList(QuerySnapshot data) async {
    troubles.clear();
    if (data != null) {
      data.docs.map((doc) {
        troubles.add(Trouble.dropDown(
          uid: doc.id,
          nameEn: doc['nameEn'],
          nameFr: doc['nameFr'],
          nameAr: doc['nameAr'],
          imageUrl: doc['imageUrl'],
        ));
      }).toList();
    }
  }

  addQuestionnaire() async {
    setState(() {
      isLoading = true;
    });
    await questionnairesServices
        .addQuestionnaireData(Questionnaire(
      type: _type,
      troubleUid: _troubleUid,
      nameEn: _nameEn,
      nameFr: _nameFr,
      nameAr: _nameAr,
      descreptionEn: _descreptionEn,
      descreptionFr: _descreptionFr,
      descreptionAr: _descreptionAr,
      questions: _questions,
      answers: _answers,
      questionsAnswers: _questionsAnswers,
      evaluations: _evaluations,
    ))
        .then((value) {
      if (value != null) {
        setState(() {
          isLoading = false;
        });
        widget.changeTab(4, null);
      }
    });
  }

  updateQuestionnaire() async {
    setState(() {
      isLoading = true;
    });
    await questionnairesServices.updateQuestionnaireData(Questionnaire(
      uid: widget.questionnaire.uid,
      nameEn: _nameEn,
      nameFr: _nameFr,
      nameAr: _nameAr,
      descreptionEn: _descreptionEn,
      descreptionFr: _descreptionFr,
      descreptionAr: _descreptionAr,
      questions: _questions,
      answers: _answers,
      questionsAnswers: _questionsAnswers,
      evaluations: _evaluations,
    ));
    setState(() {
      isLoading = false;
    });
    widget.changeTab(4, null);
  }

  @override
  void initState() {
    if (widget.questionnaire != null) {
      _type = widget.questionnaire.type;
      _troubleUid = widget.questionnaire.troubleUid;
      _nameEn = widget.questionnaire.nameEn;
      _nameFr = widget.questionnaire.nameFr;
      _nameAr = widget.questionnaire.nameAr;
      _descreptionEn = widget.questionnaire.descreptionEn;
      _descreptionFr = widget.questionnaire.descreptionFr;
      _descreptionAr = widget.questionnaire.descreptionAr;
      _questions = widget.questionnaire.questions;
      _answers = widget.questionnaire.answers;
      _questionsAnswers = widget.questionnaire.questionsAnswers;
      _evaluations = widget.questionnaire.evaluations;

      if (_type == '1') {
        if (_steps.length == 3) {
          _steps[1] = 'List Of Questions';
          _steps[2] = 'List Of Answers';
          setState(() {
            _steps.add('List Of Evaluations');
          });
        }
      } else {
        if (_steps.length == 4) {
          _steps[1] = 'List Of Question/Answers ';
          _steps[2] = 'List Of Evaluations';
          setState(() {
            _steps.removeAt(3);
          });
        }
      }
      int _scortest = 0;
      widget.questionnaire.evaluations.forEach((element) {
        if (element['to'] as int > _scortest) {
          _scortest = element['to'];
        }
      });
      _localFrom = _scortest;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBar(
            context,
            widget.questionnaire == null
                ? 'Add Questionnaire'
                : 'Update Questionnaire',
            ''),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          widget.questionnaire != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: deleteButton(context, () {
                    createDialog(context,
                        delteQuestionnaire(widget.questionnaire.uid), true);
                  }, text: 'Delete', color: Colors.red, icon: Icons.delete),
                )
              : SizedBox(),
        ],
      ),
      body: Responsive.isMobile(context)
          ? _addQuestionnaireForm()
          : desktopWidget(
              Container(),
              Container(),
              _addQuestionnaireForm(),
            ),
    );
  }

  Widget _addQuestionnaireForm() {
    int index = 0;
    return isLoading
        ? loading(context)
        : Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(8.0),
                    children: _steps.map((element) {
                      index++;
                      return Card(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        margin: EdgeInsets.all(8.0),
                        shape: index < _currentStep
                            ? RoundedRectangleBorder(
                                side:
                                    BorderSide(color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(6.0),
                              )
                            : null,
                        elevation: 2.0,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: index < _currentStep
                                    ? CircleAvatar(
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.done,
                                          size: 30.0,
                                          color: Colors.white,
                                        ))
                                    : null,
                                title: Text(_steps[index - 1]),
                              ),
                            ),
                            index == _currentStep
                                ? index == 1
                                    ? _questionnaireInfo()
                                    : index == 2
                                        ? _type == '1'
                                            ? _questionsList()
                                            : _questionAnswerList()
                                        : index == 3
                                            ? _type == '1'
                                                ? _answersList()
                                                : _evaluationList()
                                            : index == 4
                                                ? _evaluationList()
                                                : SizedBox()
                                : SizedBox(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                _currentStep == 5 || (_currentStep == 4 && _type == '2')
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            button('Edit', () {
                              setState(() {
                                _currentStep--;
                              });
                            }),
                            SizedBox(width: 6.0),
                            button('Save', () {
                              int _testScore = 0;
                              _evaluations.forEach((evaluation) {
                                if (evaluation['to'] as int > _testScore) {
                                  _testScore = evaluation['to'];
                                }
                              });

                              widget.questionnaire == null
                                  ? addQuestionnaire()
                                  : updateQuestionnaire();
                            }),
                          ],
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          );
  }

  Widget _questionnaireInfo() {
    final _infoFormKey = GlobalKey<FormState>();
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Form(
            key: _infoFormKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(children: [
                SizedBox(height: 6.0),
                widget.questionnaire == null
                    ? DropdownButtonFormField(
                        decoration: textInputDecoration(context, 'Type'),
                        value: _type,
                        items: ['Static', 'Dynamic'].map((type) {
                          return DropdownMenuItem(
                            value: type == 'Static' ? '1' : '2',
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _type = value;
                          if (_type == '1') {
                            if (_steps.length == 3) {
                              _steps[1] = 'List Of Questions';
                              _steps[2] = 'List Of Answers';
                              setState(() {
                                _steps.add('List Of Evaluations');
                              });
                            }
                          } else {
                            if (_steps.length == 4) {
                              _steps[1] = 'List Of Question/Answers ';
                              _steps[2] = 'List Of Evaluations';
                              setState(() {
                                _steps.removeAt(3);
                              });
                            }
                          }
                        },
                      )
                    : SizedBox(),
                SizedBox(height: 6.0),
                widget.questionnaire == null
                    ? StreamBuilder(
                        stream: TroublesServices().troubleData,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            QuerySnapshot data = snapshot.data;
                            getTroublesList(data);
                            return DropdownButtonFormField(
                              decoration:
                                  textInputDecoration(context, 'Trouble'),
                              validator: (value) => _troubleUid == null
                                  ? 'Chose a trouble'
                                  : null,
                              value: _troubleUid,
                              items: troubles.map((trouble) {
                                return DropdownMenuItem(
                                  value: trouble.uid,
                                  child: Text(trouble
                                      .getName(widget.userData.language)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                _troubleUid = value;
                              },
                            );
                          } else {
                            return loading(context);
                          }
                        })
                    : SizedBox(),
                SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _nameEn,
                  validator: (value) => value.isEmpty ? 'Enter the Name' : null,
                  decoration: textInputDecoration(context, 'English Name'),
                  onChanged: (value) => _nameEn = value,
                ),
                SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _nameFr,
                  validator: (value) => value.isEmpty ? 'Enter the Name' : null,
                  decoration: textInputDecoration(context, 'Frensh Name'),
                  onChanged: (value) => _nameFr = value,
                ),
                SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _nameAr,
                  validator: (value) => value.isEmpty ? 'Enter the Name' : null,
                  decoration: textInputDecoration(context, 'Arabic Name'),
                  onChanged: (value) => _nameAr = value,
                ),
                SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _descreptionEn,
                  validator: (value) =>
                      value.isEmpty ? 'Enter the Descreption' : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      textInputDecoration(context, 'English Descreption'),
                  onChanged: (value) => _descreptionEn = value,
                ),
                SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _descreptionFr,
                  validator: (value) =>
                      value.isEmpty ? 'Enter the Descreption' : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      textInputDecoration(context, 'Frensh Descreption'),
                  onChanged: (value) => _descreptionFr = value,
                ),
                SizedBox(height: 6.0),
                TextFormField(
                  initialValue: _descreptionAr,
                  validator: (value) =>
                      value.isEmpty ? 'Enter the Descreption' : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      textInputDecoration(context, 'Arabic Descreption'),
                  onChanged: (value) => _descreptionAr = value,
                ),
                SizedBox(height: 6.0),
              ]),
            ),
          ),
          Row(
            children: [
              Spacer(),
              button('Next', () {
                if (_infoFormKey.currentState.validate()) {
                  setState(() {
                    _currentStep++;
                  });
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _questionsList() {
    final _questionsformKey = GlobalKey<FormState>();
    String _questionEn = '';
    String _questionFr = '';
    String _questionAr = '';

    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Column(
            children: _questions
                .map((question) => Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.myGrey, width: 1.0)),
                    child: ListTile(
                      title: Text(question['questionEn']),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _questions.remove(question);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constants.border,
                        ),
                      ),
                    )))
                .toList(),
          ),
          Form(
            key: _questionsformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _questionEn,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration:
                        textInputDecoration(context, 'English Question'),
                    onChanged: (value) => _questionEn = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _questionFr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Frensh Question'),
                    onChanged: (value) => _questionFr = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _questionAr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Arabic Question'),
                    onChanged: (value) => _questionAr = value,
                  ),
                  SizedBox(height: 6.0),
                ],
              ),
            ),
          ),
          button('Add Question', () {
            if (_questionsformKey.currentState.validate()) {
              setState(() {
                _questions.add({
                  'questionEn': _questionEn,
                  'questionFr': _questionFr,
                  'questionAr': _questionAr,
                });
                _questionEn = '';
                _questionFr = '';
                _questionAr = '';
              });
            }
          }),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Spacer(),
                button('Previos', () {
                  setState(() {
                    _currentStep--;
                  });
                }),
                SizedBox(width: 6.0),
                button('Next', () {
                  if (_questions.isEmpty) {
                    final snackBar = SnackBar(
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context).accentColor, width: 2.0),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      content: Text('At least one question'),
                      duration: Duration(seconds: 2),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    setState(() {
                      _currentStep++;
                    });
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answersList() {
    final _answersformKey = GlobalKey<FormState>();
    String _answerEn = '';
    String _answerFr = '';
    String _answerAr = '';
    String _score = '';

    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Column(
            children: _answers
                .map((answer) => Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.myGrey, width: 1.0)),
                    child: ListTile(
                      title: Text(answer['answerEn']),
                      subtitle: Text('score: ${answer['score']}'),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _answers.remove(answer);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constants.border,
                        ),
                      ),
                    )))
                .toList(),
          ),
          Form(
            key: _answersformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _answerEn,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'English Answer'),
                    onChanged: (value) => _answerEn = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _answerFr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Frensh Answer'),
                    onChanged: (value) => _answerFr = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _answerAr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Arabic Answer'),
                    onChanged: (value) => _answerAr = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _score,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    decoration: textInputDecoration(context, 'Score'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      return _score = value;
                    },
                  ),
                  SizedBox(height: 6.0),
                ],
              ),
            ),
          ),
          button('Add Answer', () {
            if (_answersformKey.currentState.validate()) {
              setState(() {
                _answers.add({
                  'answerEn': _answerEn,
                  'answerFr': _answerFr,
                  'answerAr': _answerAr,
                  'score': int.parse(_score),
                });
                _answerEn = '';
                _answerFr = '';
                _answerAr = '';
                _score = '';
              });
            }
          }),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Spacer(),
                button('Previos', () {
                  setState(() {
                    _currentStep--;
                  });
                }),
                SizedBox(width: 6.0),
                button('Next', () {
                  if (_answers.isEmpty) {
                    final snackBar = SnackBar(
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context).accentColor, width: 2.0),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      content: Text('At least one answer'),
                      duration: Duration(seconds: 2),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    setState(() {
                      _currentStep++;
                    });
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionAnswerList() {
    final _questionsformKey = GlobalKey<FormState>();
    final _answersformKey = GlobalKey<FormState>();

    String _answerEn = '';
    String _answerFr = '';
    String _answerAr = '';
    String _score = '';
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Column(
            children: _questionsAnswers.map((questionAnswer) {
              return Card(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Constants.myGrey, width: 1.0),
                    borderRadius: BorderRadius.circular(20.0)),
                child: Column(
                  children: [
                    ListTile(
                      shape: RoundedRectangleBorder(
                          side:
                              BorderSide(color: Constants.myGrey, width: 1.0)),
                      title: Text(questionAnswer.questionEn),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _questionsAnswers.remove(questionAnswer);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constants.border,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 30.0),
                      child: Column(
                        children: questionAnswer.answers
                            .map((answer) => Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Constants.myGrey,
                                              width: 1.0)),
                                      child: ListTile(
                                        title: Text(answer['answerEn']),
                                        subtitle:
                                            Text('score: ${answer['score']}'),
                                        trailing: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              questionAnswer.answers
                                                  .remove(answer);
                                            });
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Constants.border,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Form(
            key: _questionsformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _localQuestionEn,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration:
                        textInputDecoration(context, 'English Question'),
                    onChanged: (value) => _localQuestionEn = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _localQuestionFr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Frensh Question'),
                    onChanged: (value) => _localQuestionFr = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _localQuestionAr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Arabic Question'),
                    onChanged: (value) => _localQuestionAr = value,
                  ),
                  SizedBox(height: 6.0),
                ],
              ),
            ),
          ),
          Text(
            'Answers',
            style: TextStyle(fontSize: 20.0),
          ),
          Column(
            children: _localAnswers
                .map((answer) => Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.myGrey, width: 1.0)),
                    child: ListTile(
                      title: Text(answer['answerEn']),
                      subtitle: Text('score: ${answer['score']}'),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _localAnswers.remove(answer);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constants.border,
                        ),
                      ),
                    )))
                .toList(),
          ),
          Form(
            key: _answersformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _answerEn,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'English Answer'),
                    onChanged: (value) => _answerEn = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _answerFr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Frensh Answer'),
                    onChanged: (value) => _answerFr = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _answerAr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Arabic Answer'),
                    onChanged: (value) => _answerAr = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _score,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    decoration: textInputDecoration(context, 'Score'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      return _score = value;
                    },
                  ),
                  SizedBox(height: 6.0),
                ],
              ),
            ),
          ),
          button('Add Answer', () {
            if (_answersformKey.currentState.validate()) {
              setState(() {
                _localAnswers.add({
                  'answerEn': _answerEn,
                  'answerFr': _answerFr,
                  'answerAr': _answerAr,
                  'score': int.parse(_score),
                });
                _answerEn = '';
                _answerFr = '';
                _answerAr = '';
                _score = '';
              });
            }
          }),
          SizedBox(height: 8.0),
          button('Add Question', () {
            if (_questionsformKey.currentState.validate()) {
              if (_localAnswers.isNotEmpty) {
                QuestionAnswer questionAnswer = QuestionAnswer(
                  questionEn: _localQuestionEn,
                  questionFr: _localQuestionFr,
                  questionAr: _localQuestionAr,
                  answers: [],
                );
                questionAnswer.answers.addAll(_localAnswers);
                _questionsAnswers.add(questionAnswer);
                setState(() {
                  _localQuestionEn = '';
                  _localQuestionFr = '';
                  _localQuestionAr = '';
                  _localAnswers.clear();
                });
              } else {
                final snackBar = SnackBar(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).accentColor, width: 2.0),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  content: Text('At least one Answer'),
                  duration: Duration(seconds: 2),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }
          }),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Spacer(),
                button('Previos', () {
                  setState(() {
                    _currentStep--;
                  });
                }),
                SizedBox(width: 6.0),
                button('Next', () {
                  if (_questionsAnswers.isEmpty) {
                    final snackBar = SnackBar(
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context).accentColor, width: 2.0),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      content: Text('At least one question'),
                      duration: Duration(seconds: 2),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    setState(() {
                      _currentStep++;
                    });
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _evaluationList() {
    final _evaluationsformKey = GlobalKey<FormState>();
    String _from = '';
    String _to = '';
    String _messageEn = '';
    String _messageFr = '';
    String _messageAr = '';

    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Column(
            children: _evaluations
                .map((evaluation) => Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Constants.myGrey, width: 1.0)),
                    child: ListTile(
                      title: Text(
                          'From: ${evaluation['from']}, To: ${evaluation['to']}'),
                      subtitle: Text('message: ${evaluation['messageEn']}'),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _evaluations.remove(evaluation);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constants.border,
                        ),
                      ),
                    )))
                .toList(),
          ),
          Form(
            key: _evaluationsformKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _from,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    decoration: textInputDecoration(context, 'From').copyWith(
                        hintText: '${_localFrom == 0 ? 0 : _localFrom + 1}'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      return _from = value;
                    },
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _to,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    decoration: textInputDecoration(context, 'To'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (value) {
                      return _to = value;
                    },
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _messageEn,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'English Message'),
                    onChanged: (value) => _messageEn = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _messageFr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Frensh Message'),
                    onChanged: (value) => _messageFr = value,
                  ),
                  SizedBox(height: 6.0),
                  TextFormField(
                    initialValue: _messageAr,
                    validator: (value) =>
                        value.isEmpty ? 'Required field' : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: textInputDecoration(context, 'Arabic Message'),
                    onChanged: (value) => _messageAr = value,
                  ),
                  SizedBox(height: 6.0),
                ],
              ),
            ),
          ),
          button('Add Evaluation', () {
            if (_evaluationsformKey.currentState.validate()) {
              setState(() {
                _evaluations.add({
                  'messageEn': _messageEn,
                  'messageFr': _messageFr,
                  'messageAr': _messageAr,
                  'from': int.parse(_from),
                  'to': int.parse(_to),
                });
                _localFrom = int.parse(_to);
                _messageEn = '';
                _messageFr = '';
                _messageAr = '';
                _from = '';
                _to = '';
              });
            }
          }),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Spacer(),
                button('Previos', () {
                  setState(() {
                    _currentStep--;
                  });
                }),
                SizedBox(width: 6.0),
                button('Done', () {
                  if (_evaluations.isEmpty) {
                    final snackBar = SnackBar(
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context).accentColor, width: 2.0),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      content: Text('At least one evaluation'),
                      duration: Duration(seconds: 2),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    setState(() {
                      _currentStep++;
                    });
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget button(String text, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        width: 160,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget delteQuestionnaire(String questionnaireUid) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.0),
          Text(
            'Confirm Delete Questionnaire',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.0),
          Text(
            'Are you sure you want to delete this questionnaire?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          SizedBox(height: 12.0),
          Container(
            width: 100,
            child: InkWell(
              onTap: () {
                QuestionnairesServices().deleteQuestionnaire(questionnaireUid);
                Navigator.pop(context);
                widget.changeTab(4, null);
                snackBar(
                    context, 'The questionnaire has been deleted successfully');
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
