import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:http/http.dart' as http;
import 'package:seller/serverAddress.dart';
import 'dart:convert';
import 'package:toast/toast.dart';
import './uploadquiz.dart';

class TestPage extends StatefulWidget {
  final String courseId;
  final String userId;
  final String token;

  TestPage(
      {@required this.userId, @required this.courseId, @required this.token});

  @override
  State<StatefulWidget> createState() {
    return TestPageState();
  }
}

class TestPageState extends State<TestPage> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  Map<String, String> config = {'Content-Type': 'application/json'};
  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 150, bottom: 10.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 400,
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
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter Test Name';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.red),
                        onSaved: (String val) {
                          _name = val;
                        },
                        decoration: InputDecoration(
                            hintText: "Test Name",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
                              color: Colors.red,
                            )),
                      )),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 400,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RaisedButton(
                onPressed: submitTest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
                child: Text("Create Test",
                    style: TextStyle(color: Colors.white70)),
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }

  void submitTest() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      config['Authorization'] = widget.token;
      var body = {
        'user_id': widget.userId,
        'test_name': _name,
        'course_id': widget.courseId
      };
      http
          .post(Server.testAdd, body: json.encode(body), headers: config)
          .then((http.Response res) {
        if (res.statusCode == 201 || res.statusCode == 200) {
          String testId = json.decode(res.body)['id'].toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Quiz(
                    testId: testId,
                    token: widget.token,
                    userId: widget.userId,
                  ),
            ),
          );
        } else {
          Toast.show("Unable to Create Test", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
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
