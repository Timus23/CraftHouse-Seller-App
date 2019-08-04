import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:seller/serverAddress.dart';
import 'package:toast/toast.dart';
import './verification.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  Response response;
  Dio dio = new Dio();
  bool isLoading = false;
  Map<String, String> config = {'Content-Type': 'application/json'};
  String fname, lname, email, password, phoneno;
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 900,
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
                        maxLength: 32,
                        validator: validateName,
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "First Name",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.perm_identity,
                              color: Colors.red,
                            )),
                        onSaved: (value) {
                          fname = value;
                        },
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
                        maxLength: 32,
                        validator: validateName,
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Last Name",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.perm_identity,
                              color: Colors.red,
                            )),
                        onSaved: (value) {
                          lname = value;
                        },
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
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 32,
                        validator: validateEmail,
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Email address",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.email,
                              color: Colors.red,
                            )),
                        onSaved: (value) {
                          email = value;
                        },
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
                        maxLength: 20,
                        validator: (String arg) {
                          if (arg.length < 5)
                            return 'Password must be more than 5 character';
                          else
                            return null;
                        },
                        controller: passwordController,
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
                              color: Colors.red,
                            )),
                        onSaved: (value) {
                          password = value;
                        },
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
                        maxLength: 20,
                        validator: (String arg) {
                          if (arg.length < 5)
                            return 'Password must be more than 5 character';
                          else if (arg != passwordController.text) {
                            return 'Password doesnot match';
                          } else
                            return null;
                        },
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Confirm password",
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
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: validateMobile,
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Phone Number",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.contact_phone,
                              color: Colors.red,
                            )),
                        onSaved: (value) {
                          phoneno = value;
                        },
                      )),
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
            height: 900,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {
                            isLoading = true;
                          });
                          Map<String, dynamic> formData = {
                            "email": email.toString(),
                            "password": password.toString(),
                            "first_name": fname.toString(),
                            "last_name": lname.toString(),
                            "is_seller": true,
                            "phoneno": phoneno.toString()
                          };
                          print('Form Data Saved');
                          try {
                            http
                                .post(Server.signup,
                                    body: json.encode(formData),
                                    headers: config)
                                .then((response) {
                              setState(() {
                                isLoading = false;
                              });
                              if (response.statusCode == 201) {
                                Toast.show('Verify Account', context,
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.BOTTOM);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => Verify(
                                          from: 'signup',
                                        )));
                              } else {
                                Map<String, dynamic> info =
                                    json.decode(response.body);
                                if (info.containsKey('email')) {
                                  Toast.show(info['email'].toString(), context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                } else if (info.containsKey('detail')) {
                                  print(info);
                                  Toast.show(info['detail'].toString(), context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                }
                              }
                            }).catchError((err) {
                              Toast.show('Net Unavailable', context);
                            });
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          return;
                        }
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: Text("Sign Up",
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

  String validateMobile(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Mobile is Required";
    } else if (value.length != 10) {
      return "Mobile number must 10 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Mobile Number must be digits";
    }
    return null;
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: Colors.red,
                    child: Icon(Icons.arrow_back),
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
