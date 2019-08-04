import 'package:flutter/material.dart';
import 'package:seller/login.dart';
import 'package:seller/my_prod.dart';
import 'package:seller/product.dart';
import 'package:seller/serverAddress.dart';
import 'package:seller/video.dart';
import 'package:toast/toast.dart';
import './class.dart';
import './about.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Navigationbar extends StatefulWidget {
  @override
  NavigationbarState createState() => NavigationbarState();
}

class NavigationbarState extends State<Navigationbar> {
  SharedPreferences prefs;
  Map<String, String> head = {'Content-Type': 'application/json'};

  void getUserData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      head['Authorization'] = 'Token ' + prefs.getString('token');
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  final List<Widget> pages = [
    MyProd(
      key: PageStorageKey('Page1'),
    ),
    Product(
      key: PageStorageKey('Page2'),
    ),
    Video(
      key: PageStorageKey('Page4'),
    ),
  ];
  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex = 0;

  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box), title: Text('My Products')),
          BottomNavigationBarItem(
              icon: Icon(Icons.store), title: Text('Sell Craft')),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_library), title: Text('Sell Tutorials')),
        ],
      );

  void choiceAction(String choice) {
    if (choice == Constants.About) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => About()));
    } else if (choice == Constants.SignOut) {
      print(head);
      http.get(Server.logout, headers: head).then((http.Response response) {
        if (response.statusCode == 200) {
          prefs.remove('token');
          prefs.remove('id');
          prefs.remove('first_name');
          prefs.remove('last_name');
          prefs.remove('is_seller');
          prefs.remove('email');
          prefs.remove('phone_no');
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) => Loginn()));
        } else if (response.statusCode == 401) {
          Toast.show("Unauthorized Logout", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      }).catchError((err) {
        Toast.show('Net Unavailable', context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: new AppBar(
          leading: new Container(),
          title: new Text("Craft House"),
          backgroundColor: Colors.red,
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return Constants.choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
        body: PageStorage(
          child: pages[_selectedIndex],
          bucket: bucket,
        ),
      ),
    );
  }
}
