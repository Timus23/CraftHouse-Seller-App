import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        elevation: 0.1,
        backgroundColor: Colors.red,
        title: Text('About This Application'),
      ),
      body: Container(
        height: 600.0,
        child: new Text(
          "This is a mobile application to promote local arts and crafts.",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
