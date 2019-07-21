import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';
import './login.dart';
import 'serverAddress.dart';

class ChangePassword extends StatefulWidget {
  final String code;
  ChangePassword({@required this.code});
  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  String password1;
  TextEditingController _passwordController = TextEditingController();
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
                        maxLength: 20,
                        validator: (String arg) {
                          if (arg.length < 5)
                            return 'Password must be more than 5 character';
                          else
                            return null;
                        },
                        style: TextStyle(color: Colors.red),
                        controller: _passwordController,
                        onSaved: (String val) {
                          password1 = val;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: "New password",
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
                      maxLength: 20,
                      obscureText: true,
                      validator: (String arg) {
                        if (arg.length < 5)
                          return 'Password must be more than 5 character';
                        else if (arg != _passwordController.text) {
                          return 'Password does not match';
                        } else
                          return null;
                      },
                      style: TextStyle(color: Colors.red),
                      decoration: InputDecoration(
                          hintText: "Confirm Password",
                          hintStyle: TextStyle(color: Colors.red.shade200),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.lock,
                            color: Colors.red,
                          )),
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
              child: RaisedButton(
                onPressed: submitResetButton,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
                child: Text("Reset", style: TextStyle(color: Colors.white70)),
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }

  void submitResetButton() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Map<String, String> formData = {
        'code': widget.code,
        'password': password1
      };
      http
          .post(Server.resetCodeVerifed,
              headers: config, body: json.encode(formData))
          .then((http.Response response) {
        Map<String, dynamic> info = json.decode(response.body);
        if (response.statusCode == 200) {
          Toast.show(info['success'].toString(), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) => Loginn()));
        }
        else{
          if(info.containsKey('password')){
            Toast.show(info['password'].toString(), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
          else if(info.containsKey('detail')){
            Toast.show(info['detail'].toString(), context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
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
