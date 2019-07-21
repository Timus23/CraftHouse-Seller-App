import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:http/http.dart' as http;
import 'package:seller/serverAddress.dart';
import 'dart:convert';
import 'package:toast/toast.dart';

class EditProduct extends StatefulWidget {
  final productData, header;
  EditProduct({@required this.productData, @required this.header});
  @override
  EditProductState createState() => EditProductState();
}

class EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  Map<String, dynamic> productItem = {};
  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 800,
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
                      initialValue: widget.productData['product_name'],
                      validator: validateName,
                      style: TextStyle(color: Colors.red),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.red.shade200),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.label,
                          color: Colors.red,
                        ),
                      ),
                      onSaved: (value) {
                        productItem['product_name'] = value;
                      },
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
                      maxLength: 32,
                      validator: validateName,
                      initialValue: widget.productData['product_made_of'],
                      style: TextStyle(color: Colors.red),
                      decoration: InputDecoration(
                        hintText: "Made of ",
                        hintStyle: TextStyle(color: Colors.red.shade200),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.perm_identity,
                          color: Colors.red,
                        ),
                      ),
                      onSaved: (value) {
                        productItem['product_made_of'] = value;
                      },
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
                      maxLength: 8,
                      validator: validatePrice,
                      initialValue:
                          widget.productData['product_price'].toString(),
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
                      onSaved: (value) {
                        productItem['product_price'] = value;
                      },
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
                      maxLength: 3,
                      initialValue:
                          widget.productData['product_quantity'].toString(),
                      validator: validateQuantity,
                      style: TextStyle(color: Colors.red),
                      decoration: InputDecoration(
                        hintText: "Quantity",
                        hintStyle: TextStyle(color: Colors.red.shade200),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.lock,
                          color: Colors.red,
                        ),
                      ),
                      onSaved: (value) {
                        productItem['product_quantity'] = value;
                      },
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
                      maxLength: 100,
                      validator: validateDetails,
                      initialValue: widget.productData['product_description'],
                      style: TextStyle(color: Colors.red),
                      decoration: InputDecoration(
                        hintText: "Product Details",
                        hintStyle: TextStyle(color: Colors.red.shade200),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.perm_identity,
                          color: Colors.red,
                        ),
                      ),
                      onSaved: (value) {
                        productItem['product_description'] = value;
                      },
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
            height: 800,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      onPressed: submitEdit,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child:
                          Text("Save", style: TextStyle(color: Colors.white70)),
                      color: Colors.red,
                    ),
            ),
          )
        ],
      ),
    );
  }

  void submitEdit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      // widget.header['Content-Type'] = 'application/json';

      http
          .patch(Server.productUpdate + widget.productData['id'].toString() + '/',
              body: json.encode(productItem), headers: widget.header)
          .then((http.Response response) {
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          Toast.show('Product Updated', context,
              gravity: Toast.BOTTOM, duration: Toast.LENGTH_SHORT);
          _formKey.currentState.reset();
          Navigator.of(context).pop();
        } else {
          var msg = json.decode(response.body);
          Toast.show(msg['detail'], context,
              gravity: Toast.BOTTOM, duration: Toast.LENGTH_SHORT);
        }
      });
    }
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

  String validateDetails(String value) {
    // String patttern = r'(^[a-zA-Z ]*$)';
    // RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Product Description is Required";
      // } else if (!regExp.hasMatch(value)) {
      //   return "Description must be a-z and A-Z";
    }
    return null;
  }

  String validatePrice(String value) {
    if (value.length == 0) {
      return "Price is Required";
    }
    return null;
  }

  String validateQuantity(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Quantity is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Quantity must be a number";
    }
    return null;
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
