import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:seller/serverAddress.dart';
import 'package:seller/upload_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class Video extends StatefulWidget {
  const Video({Key key}) : super(key: key);
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  final _formKey = GlobalKey<FormState>();
  SharedPreferences prefs;
  bool _isLoading = false;
  String _name, _tools, _price, _description;
  File image1;
  Response response;
  Dio dio = new Dio();
  Map<String, String> body = {};
  Map<String, String> head = {};

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      head['Authorization'] = 'Token ' + prefs.getString('token');
      body['user_id'] = prefs.getInt('id').toString();
    });
  }

  imageSelectorGallery() async {
    image1 = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {});
  }

  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 680,
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Thumbnail: ',
                          style: TextStyle(color: Colors.red.shade200),
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: imageSelectorGallery,
                        ),
                        image1 == null
                            ? Container()
                            : Image.file(
                                image1,
                                height: 90.0,
                                width: 90.0,
                              )
                      ],
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
            height: 650,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red))
                  : RaisedButton(
                      onPressed: submit,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child:
                          Text("Next", style: TextStyle(color: Colors.white70)),
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
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Price is Required";
    } else if (value.length < 2) {
      return "Price must be more than 100";
    } else if (!regExp.hasMatch(value)) {
      return "Price must be a number";
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
    print(head);
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print(body);
      FormData data = FormData.from({
        'user_id': body['user_id'],
        'course_name': body['course_name'],
        'course_description': body['course_description'],
        'course_price': body['course_price'],
        'course_tools_required': body['course_tools_required'],
        'course_logo':
            UploadFileInfo(File(image1.path), image1.path.split('/').last),
      });
      print(data);
      try {
        dio
            .post(Server.courseAdd,
                data: data,
                options: Options(headers: head, contentType: ContentType.json))
            .then((response) {
          if (response.statusCode == 200 || response.statusCode == 201) {
            var temp = response.data;
            print('-------------------------------');
            print(temp);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => Upload(
                      courseId: temp['id'].toString(),
                      userId: temp['user_id'].toString(),
                    ),
              ),
            );
          } else {
            // String msg = json.decode(response.data)['detail'];
            Toast.show('Unable to Upload Course', context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        });
      } catch (e) {
        print(e);
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
