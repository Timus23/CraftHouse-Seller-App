import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:http/http.dart' as http;
import 'package:seller/changePassword.dart';
import 'package:seller/serverAddress.dart';
import 'dart:convert';
import 'package:toast/toast.dart';

class Verify extends StatefulWidget {
  final String from;
  Verify({@required this.from});
  @override
  VerifyState createState() => VerifyState();
}

class VerifyState extends State<Verify> {
  final _formKey = GlobalKey<FormState>();
  String _code;
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
                            return 'Enter Verification Code';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.red),
                        onSaved: (String val) {
                          _code = val;
                        },
                        decoration: InputDecoration(
                            hintText: "Verification code",
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
                onPressed: submitverify,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
                child: Text("Verify", style: TextStyle(color: Colors.white70)),
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }

  void submitverify() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (widget.from == 'signup' || widget.from == 'login') {
        http
            .get(Server.signupVerify + _code, headers: config)
            .then((http.Response response) {
          Map<String, dynamic> info = json.decode(response.body);
          if (response.statusCode == 200) {
            Toast.show(info['success'].toString(), context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          } else {
            Toast.show(info['detail'].toString(), context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        });
      }
      if (widget.from == 'reset') {
        http
            .get(Server.resetCodeVerify + _code, headers: config)
            .then((http.Response response) {
          Map<String, dynamic> info = json.decode(response.body);
          if (response.statusCode == 200) {
            Toast.show(info['success'].toString(), context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => ChangePassword(
                      code: _code,
                    ),
              ),
            );
          } else {
            if (info.containsKey('detail')) {
              Toast.show(info['detail'].toString(), context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            } else if (info.containsKey('password')) {
              Toast.show(info['password'].toString(), context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            }
          }
        });
      }
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
