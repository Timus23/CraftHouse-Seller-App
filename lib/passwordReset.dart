import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:http/http.dart' as http;
import 'package:seller/serverAddress.dart';
import 'package:seller/verification.dart';
import 'dart:convert';
import 'package:toast/toast.dart';

class ResetPage extends StatefulWidget {
  @override
  ResetPageState createState() => ResetPageState();
}

class ResetPageState extends State<ResetPage> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String _email;
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
                      validator: validateEmail,
                      style: TextStyle(color: Colors.red),
                      onSaved: (String val) {
                        _email = val;
                      },
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.red.shade200),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.email,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
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
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black38))
                  : RaisedButton(
                      onPressed: submitReset,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Text("Reset",
                          style: TextStyle(color: Colors.white70)),
                      color: Colors.red,
                    ),
            ),
          )
        ],
      ),
    );
  }

  void submitReset() {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState.save();
      Map<String, String> formData = {'email': _email};
      http
          .post(Server.reset, headers: config, body: json.encode(formData))
          .then((http.Response response) {
        Map<String, dynamic> info = json.decode(response.body);
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 201) {
          Toast.show('Enter the verification code', context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Verify(
                    from: 'reset',
                  )));
        } else {
          if (info.containsKey('email')) {
            Toast.show(info['email'].toString(), context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          } else if (info.containsKey('detail')) {
            Toast.show(info['detail'].toString(), context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        }
      }).catchError((err) {
        Toast.show('Net Unavailable', context);
      });
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
            ],
          ),
        ),
      ),
    );
  }
}
