import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:seller/serverAddress.dart';
import 'package:seller/testPage.dart';
import 'package:seller/uploadquiz.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class Upload extends StatefulWidget {
  final String courseId;
  final String userId;

  Upload({@required this.courseId, @required this.userId});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  int _noOfVideo = 0;
  final _formKey = GlobalKey<FormState>();
  String _filePath;
  String _title;
  String btnName = 'Upload Video';
  bool isLoading = false;
  Map<String, String> config = {};
  Response response;
  Dio dio = new Dio();
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      config['Authorization'] = 'Token ' + prefs.getString('token');
    });
  }

  void getFilePath() async {
    try {
      String filePath = await FilePicker.getFilePath(type: FileType.VIDEO);
      if (filePath == '') {
        return;
      }
      setState(() {
        this._filePath = filePath;
      });
    } on PlatformException catch (e) {
      print("Error while picking the file: " + e.toString());
    }
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
                        maxLength: 32,
                        validator: validateName,
                        onSaved: (value) {
                          _title = value;
                        },
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Video Name",
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
                    child: _filePath == null
                        ? new Text('Video not selected.',
                            style: TextStyle(color: Colors.red.shade200))
                        : new Text('Path: ' + _filePath,
                            style: TextStyle(color: Colors.red.shade200)),
                  ),
                  Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new RaisedButton(
                            onPressed: getFilePath,
                            child: new Icon(
                              Icons.video_library,
                              color: Colors.red,
                            ),
                          ),
                        ]),
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
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red))
                        : RaisedButton(
                            onPressed: submit,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0)),
                            child: Text('Upload Video',
                                style: TextStyle(color: Colors.white70)),
                            color: Colors.red,
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
              child: RaisedButton(
                onPressed: (_noOfVideo > 0)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => TestPage(
                                  courseId: widget.courseId,
                                  token: config['Authorization'],
                                  userId: widget.userId,
                                ),
                          ),
                        );
                      }
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
                child:
                    Text("Set Test", style: TextStyle(color: Colors.white70)),
                color: (_noOfVideo > 0) ? Colors.red : Colors.grey,
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

  void submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FormData data = FormData.from({
        'course_id': widget.courseId,
        'title': _title,
        'file': UploadFileInfo(File(_filePath), _filePath.split('/').last),
      });
      try {
        setState(() {
          isLoading = true;
        });
        dio
            .post(
          Server.videoAdd,
          data: data,
          options: Options(headers: config, contentType: ContentType.json),
        )
            .then((response) {
          if (response.statusCode == 200 || response.statusCode == 201) {
            _formKey.currentState.reset();
            setState(() {
              isLoading = false;
              _filePath = null;
              _noOfVideo++;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            Toast.show('Unable to upload video', context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
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
