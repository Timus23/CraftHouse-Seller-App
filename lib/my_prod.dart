import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:seller/login.dart';
import 'package:seller/myCoursesEdit.dart';
import 'package:seller/product.dart';
import 'package:seller/serverAddress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import './editprod.dart';

class MyProd extends StatefulWidget {
  const MyProd({Key key}) : super(key: key);
  @override
  MyProdState createState() => MyProdState();
}

class MyProdState extends State<MyProd> {
  bool connectionState;
  List<dynamic> _products, _courses;
  Map<String, String> head = {'Content-Type': 'application/json'};
  String token;
  void checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() {
        connectionState = false;
      });
    }
    if (result == ConnectivityResult.wifi) {
      setState(() {
        connectionState = true;
      });
    }
  }

  void getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      head['Authorization'] = 'Token ' + pref.getString('token');
    });
  }

  @override
  void initState() {
    super.initState();
    connectionState = false;
    checkConnection();
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Colors.white54,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: TabBar(
                          tabs: [
                            Text(
                              "Products",
                              style: TextStyle(color: Colors.black45),
                            ),
                            Text("Courses",
                                style: TextStyle(color: Colors.black45))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: <Widget>[productDisplay(), courseDisplay()],
          )),
    );
  }

  Widget productDisplay() {
    return connectionState
        ? FutureBuilder(
            future: http
                .get(Server.products, headers: head)
                .timeout(Duration(seconds: 10)),
            builder: (BuildContext context, AsyncSnapshot snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snap.connectionState == ConnectionState.done) {
                if (snap.data == null) {
                  return reconnect('Connection TimeOut');
                }
                if (snap.data.statusCode == 401) {
                  return unAuthorizedLogin();
                }
                _products = json.decode(snap.data.body);
                if (_products.length == 0) {
                  return Container(
                    child: Center(
                      child: Text('No Item'),
                    ),
                  );
                }
                return ListView.builder(
                  itemBuilder: buildProductList,
                  itemCount: _products.length,
                );
              } else {
                return reconnect("No Connection");
              }
            },
          )
        : reconnect("No Connection");
  }

  Widget unAuthorizedLogin() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('Login Failed!!')],
        ),
        RaisedButton(
          color: Colors.red,
          child: Text(
            'Re-Login',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Loginn())),
        )
      ],
    ));
  }

  Widget courseDisplay() {
    return connectionState
        ? FutureBuilder(
            future: http
                .get(Server.courses, headers: head)
                .timeout(Duration(seconds: 10)),
            builder: (BuildContext context, AsyncSnapshot snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snap.connectionState == ConnectionState.done) {
                if (snap.data == null) {
                  return reconnect('Connection TimeOut');
                }
                if (snap.data.statusCode == 401) {
                  return unAuthorizedLogin();
                }
                _courses = json.decode(snap.data.body);
                if (_courses.length == 0) {
                  return Container(
                    child: Center(
                      child: Text('No Courses'),
                    ),
                  );
                }
                return ListView.builder(
                  itemBuilder: buildCoursesList,
                  itemCount: _courses.length,
                );
              } else {
                return reconnect("No Connection");
              }
            },
          )
        : reconnect("No Connection");
  }

  Widget reconnect(msg) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(msg),
          ),
          Center(
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  checkConnection();
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildProductList(BuildContext context, int index) {
    return GestureDetector(
      child: Dismissible(
        key: Key(_products[index]['id'].toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (DismissDirection d) {
          print(token);
          http
              .delete(
                  Server.productDelete +
                      _products[index]['id'].toString() +
                      '/',
                  headers: head)
              .then((http.Response response) {
            if (response.statusCode == 204) {
              Toast.show('Product Deleted', context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            } else {
              var error = json.decode(response.body);
              Toast.show(error['detail'], context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            }
            setState(() {});
          }).catchError((err) {
            Toast.show('Net Unavailable', context);
          });
        },
        confirmDismiss: (DismissDirection direction) async {
          final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm"),
                  content:
                      const Text("Are you sure you wish to delete this item?"),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("DELETE")),
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("CANCEL"),
                    )
                  ],
                );
              });
          return res;
        },
        background: Container(
          color: Colors.red,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                ),
                Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                Text(
                  'Delete',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            ),
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              child: Material(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    Stack(
                      children: <Widget>[
                        FadeInImage.assetNetwork(
                          placeholder: 'images/imageLoading.gif',
                          image: Server.media + _products[index]['images'][0],
                          height: 200,
                        ),
                        Positioned(
                          bottom: 20.0,
                          right: 10.0,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            color: Colors.white70,
                            child: Text(
                              "Rs " +
                                  _products[index]['product_price'].toString(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _products[index]['product_name'],
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(_products[index]['product_made_of']),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: <Widget>[
                              SmoothStarRating(
                                  allowHalfRating: true,
                                  starCount: 5,
                                  rating: _products[index]['average_rating']
                                      .toDouble(),
                                  size: 20.0,
                                  color: Colors.green,
                                  borderColor: Colors.green,
                                  spacing: 0.0)
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onTap: () {
        print(index.toString());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => EditProduct(
                  productData: _products[index],
                  header: head,
                ),
          ),
        );
      },
    );
  }

  Widget buildCoursesList(BuildContext context, int index) {
    return GestureDetector(
      child: Dismissible(
        key: Key(_courses[index]['id'].toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (DismissDirection d) {
          print(token);
          http
              .delete(
                  Server.courseDelete + _courses[index]['id'].toString() + '/',
                  headers: head)
              .then((http.Response response) {
            if (response.statusCode == 204) {
              Toast.show('Course Deleted', context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            } else {
              var error = json.decode(response.body);
              Toast.show(error['detail'], context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
            }
            setState(() {});
          }).catchError((err) {
            Toast.show('Net Unavailable', context);
          });
        },
        confirmDismiss: (DismissDirection direction) async {
          final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm"),
                  content:
                      const Text("Are you sure you wish to delete this item?"),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("DELETE")),
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("CANCEL"),
                    )
                  ],
                );
              });
          return res;
        },
        background: Container(
          color: Colors.red,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                ),
                Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                Text(
                  'Delete',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            ),
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              child: Material(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    Stack(
                      children: <Widget>[
                        FadeInImage.assetNetwork(
                          placeholder: 'images/imageLoading.gif',
                          image: Server.localAddress +
                              _courses[index]['course_logo'],
                          height: 200,
                        ),
                        Positioned(
                          bottom: 20.0,
                          right: 10.0,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            color: Colors.white70,
                            child: Text(
                              "Rs " +
                                  _courses[index]['course_price'].toString(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _courses[index]['course_name'],
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(_courses[index]['course_description']),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onTap: () {
        print(index.toString());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => MyCourseEdit(
                  course: _courses[index],
                  header: head,
                ),
          ),
        );
      },
    );
  }
}
