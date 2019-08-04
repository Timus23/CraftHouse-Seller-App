import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:seller/serverAddress.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:seller/navigationbar.dart';

class Quiz extends StatefulWidget {
  final String userId;
  final String testId;
  final String token;

  Quiz({@required this.userId, @required this.testId, @required this.token});

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  final _formKey = GlobalKey<FormState>();
  String question, option1, option2, option3, option4;
  Map<String, String> config = {'Content-Type': 'application/json'};
  List<String> _answers = ['Option1', 'Option2', 'Option3', 'Option4'];
  String _selectedanswers;

  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 800,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 90.0,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        maxLength: 100,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter the question.';
                          }
                          return null;
                        },
                        onSaved: (String val) {
                          question = val;
                        },
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Question",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.question_answer,
                              color: Colors.red,
                            )),
                      )),
                  Container(
                    child: Divider(
                      color: Colors.red.shade400,
                    ),
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        maxLength: 60,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter option1';
                          }
                          return null;
                        },
                        onSaved: (String val) {
                          option1 = val;
                        },
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Option1 ",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.list,
                              color: Colors.red,
                            )),
                      )),
                  Container(
                    child: Divider(
                      color: Colors.red.shade400,
                    ),
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        maxLength: 60,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter option2';
                          }
                          return null;
                        },
                        onSaved: (String val) {
                          option2 = val;
                        },
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Option2",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.list,
                              color: Colors.red,
                            )),
                      )),
                  Container(
                    child: Divider(
                      color: Colors.red.shade400,
                    ),
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        maxLength: 60,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'option3';
                          }
                          return null;
                        },
                        onSaved: (String val) {
                          option3 = val;
                        },
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Option3",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.list,
                              color: Colors.red,
                            )),
                      )),
                  Container(
                    child: Divider(
                      color: Colors.red.shade400,
                    ),
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        maxLength: 60,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter option4';
                          }
                          return null;
                        },
                        onSaved: (String val) {
                          option4 = val;
                        },
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Option4",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.list,
                              color: Colors.red,
                            )),
                      )),
                  Container(
                    child: Divider(
                      color: Colors.red.shade400,
                    ),
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: DropdownButton(
                      hint: Text(
                        'Provide Correct Answer',
                        style: TextStyle(color: Colors.red.shade200),
                      ), // Not necessary for Option 1
                      value: _selectedanswers,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedanswers = newValue;
                        });
                      },
                      items: _answers.map((category) {
                        return DropdownMenuItem(
                          child: new Text(
                            category,
                            style: TextStyle(color: Colors.red.shade200),
                          ),
                          value: category,
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    child: Divider(
                      color: Colors.red.shade400,
                    ),
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: RaisedButton(
                      onPressed: submitQuiz,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: Text("Next Question",
                          style: TextStyle(color: Colors.white70)),
                      color: Colors.red,
                    ),
                  ),
                  Container(
                    child: Divider(
                      color: Colors.red.shade400,
                    ),
                    padding:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 800,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RaisedButton(
                onPressed: () {
                  Toast.show('Course Created Successfully', context,
                      duration: Toast.BOTTOM, gravity: Toast.LENGTH_SHORT);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Navigationbar()));
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
                child: Text("Finish", style: TextStyle(color: Colors.white70)),
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }

  void submitQuiz() {
    if (_formKey.currentState.validate()) {
      if (_selectedanswers == null) {
        Toast.show("Select Correct Answer", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        return;
      }
      _formKey.currentState.save();
      config['Authorization'] = widget.token;
      var body = {
        'test_id': widget.testId,
        'question': question,
        'option1': option1,
        'option2': option2,
        'option3': option3,
        'option4': option4,
        'correct_answer':
            _selectedanswers.substring(_selectedanswers.length - 1).trim(),
      };
      print('----------------------------');
      print(config);
      print(body);
      http
          .post(Server.questionAdd, headers: config, body: json.encode(body))
          .then((http.Response res) {
        if (res.statusCode == 201 || res.statusCode == 200) {
          setState(() {
            _selectedanswers = null;
            _formKey.currentState.reset();
          });
          Toast.show("Question Uploaded", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        } else {
          Toast.show("Unable to Upload Question", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      }).catchError((err) {
        Toast.show('Net Unavailable', context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.red.shade100,
          child: ListView(
            children: <Widget>[
              _buildLoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
