import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:seller/serverAddress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:io';

class MyCourseEdit extends StatefulWidget {
  Map<String, dynamic> course;
  Map<String, String> header;
  MyCourseEdit({@required this.course, @required this.header});
  @override
  MyCourseEditState createState() => MyCourseEditState();
}

class MyCourseEditState extends State<MyCourseEdit> {
  final _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  bool isLoading = false;
  String _name, _tools, _price, _description;
  Map<String, String> body = {};

  @override
  void initState() {
    super.initState();
  }

  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 500,
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
                        initialValue: widget.course['course_name'],
                        maxLength: 32,
                        onSaved: (value) {
                          body['course_name'] = value;
                        },
                        validator: validateName,
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Tutorial Name",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.video_label,
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
                        initialValue: widget.course['course_tools_required'],
                        maxLength: 60,
                        validator: validateTools,
                        style: TextStyle(color: Colors.red),
                        onSaved: (value) {
                          body['course_tools_required'] = value;
                        },
                        decoration: InputDecoration(
                            hintText: "Tools Required ",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.build,
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
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      initialValue: widget.course['course_price'].toString(),
                      validator: validatePrice,
                      onSaved: (value) {
                        body['course_price'] = value;
                      },
                      style: TextStyle(color: Colors.red),
                      decoration: InputDecoration(
                        hintText: "Price",
                        hintStyle: TextStyle(color: Colors.red.shade200),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.monetization_on,
                          color: Colors.red,
                        ),
                      ),
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
                    child: TextFormField(
                      maxLength: 300,
                      validator: validateDescription,
                      initialValue: widget.course['course_description'],
                      onSaved: (value) {
                        body['course_description'] = value;
                      },
                      style: TextStyle(color: Colors.red),
                      decoration: InputDecoration(
                        hintText: "Tutorial Description",
                        hintStyle: TextStyle(color: Colors.red.shade200),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.timelapse,
                          color: Colors.red,
                        ),
                      ),
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
            height: 500,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red))
                  : RaisedButton(
                      onPressed: submit,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: Text("Update",
                          style: TextStyle(color: Colors.white70)),
                      color: Colors.red,
                    ),
            ),
          )
        ],
      ),
    );
  }

  String validateName(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Name is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Name must be a-z and A-Z";
    }
    return null;
  }

  String validateDescription(String value) {
    String patttern = r'(^[a-zA-Z,. ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Description is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Description must be a-z or A-Z or ,.";
    }
    return null;
  }

  String validatePrice(String value) {
    if (value.length == 0) {
      return "Price is Required";
    } else if (value.length < 2) {
      return "Price must be more than 100";
    }
    return null;
  }

  String validateTools(String value) {
    String patttern = r'(^[a-zA-Z, ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Tools is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Tools must be a-z , A-Z and ,";
    }
    return null;
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      body['id'] = widget.course['id'].toString();
      body['user_id'] = widget.course['user_id'].toString();
      print('------------------------');
      print(body);
      print(widget.header);
      setState(() {
        isLoading = false;
      });
      http
          .patch(Server.courseUpdate + widget.course['id'].toString() + '/',
              body: json.encode(body), headers: widget.header)
          .then((http.Response response) {
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          Toast.show('Course Updated', context,
              gravity: Toast.BOTTOM, duration: Toast.LENGTH_SHORT);
          _formKey.currentState.reset();
          Navigator.of(context).pop();
        } else {
          setState(() {
            isLoading = false;
          });
          var msg = json.decode(response.body);
          Toast.show(msg['detail'], context,
              gravity: Toast.BOTTOM, duration: Toast.LENGTH_SHORT);
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
