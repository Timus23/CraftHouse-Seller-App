import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:seller/navigationbar.dart';
import 'package:seller/serverAddress.dart';
import 'package:seller/signup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './verification.dart';
import 'package:toast/toast.dart';
import './passwordReset.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginn extends StatefulWidget {
  const Loginn({Key key}) : super(key: key);
  @override
  _LoginnState createState() => _LoginnState();
}

class _LoginnState extends State<Loginn> {
  Response response;
  Dio dio = new Dio();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String email, password;
  Map<String, String> config = {'Content-Type': 'application/json'};

  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(20.0),
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
                        validator: validateEmail,
                        style: TextStyle(color: Colors.red),
                        onSaved: (String val) {
                          email = val;
                        },
                        decoration: InputDecoration(
                            hintText: "Email address",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.email,
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
                        obscureText: true,
                        style: TextStyle(color: Colors.red),
                        validator: (value) {
                          if (value.length < 5) {
                            return 'Password must be more than 5 character';
                          }
                        },
                        onSaved: (String val) {
                          password = val;
                        },
                        decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(color: Colors.black45),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ResetPage()));
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.red.shade600,
                child: Icon(Icons.person),
              ),
            ],
          ),
          Container(
            height: 420,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    )
                  : RaisedButton(
                      onPressed: loginButton,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: Text("Login",
                          style: TextStyle(color: Colors.white70)),
                      color: Colors.red,
                    ),
            ),
          )
        ],
      ),
    );
  }

  void loginButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      Map<String, String> formData = {
        "email": email,
        "password": password,
      };
      try {
        http
            .post(Server.login, body: json.encode(formData), headers: config)
            .then((http.Response response) async {
          setState(() {
            _isLoading = false;
          });
          if (response.statusCode == 200) {
            Map<String, dynamic> userData = json.decode(response.body);
            print(userData);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('token', userData['token']);
            prefs.setInt('id', userData['id']);
            prefs.setString('first_name', userData['first_name']);
            prefs.setString('last_name', userData['last_name']);
            prefs.setString('email', userData['email']);
            prefs.setString('phone_no', userData['phone_no']);
            prefs.setBool('is_seller', userData['is_seller']);
            Toast.show('Login Successful', context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => Navigationbar()));
          } else if (response.statusCode == 401) {
            Map<String, dynamic> info = json.decode(response.body);
            if (info.containsKey('detail')) {
              if (info['detail'].contains('User account not verified.')) {
                print(info['detail']);
                Toast.show(info['detail'], context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => Verify(
                          from: 'login',
                        ),
                  ),
                );
              } else {
                Toast.show(info['detail'], context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
              }
            }
          }
        }).catchError((err) {
          Toast.show('Net Unavailable', context);
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print(e);
      }
    }
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => Signup()));
                    },
                    child: Text("Sign Up!",
                        style: TextStyle(color: Colors.red, fontSize: 18.0)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
