import 'package:flutter/material.dart';
import 'package:seller/login.dart';
import './navigationbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(Homepage());

class Homepage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<Homepage> {
  bool authenticate;

  Future<void> checkAuthentication() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString('token') == null){
      setState(() {
       authenticate = false; 
      });
    }
    else{
      setState(() {
       authenticate = true; 
      });
    }
  }

  @override
  void initState() {
    super.initState();
    authenticate = false;
    checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Craft Home ',
      home: authenticate ? Navigationbar() : Loginn(),
    );
  }
}
