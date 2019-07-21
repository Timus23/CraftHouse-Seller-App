import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:seller/serverAddress.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:toast/toast.dart';

class Product extends StatefulWidget {
  const Product({Key key}) : super(key: key);
  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  Response response;
  Dio dio = new Dio();
  Map<String, dynamic> productData = {};
  bool isLoading = false;
  Map<String, String> config = {};
  File image1;
  File image2;
  File image3;
  File cameraFile;
  List<String> _category;
  String _selectedCategory;
  List<dynamic> catData;

  void getCategories() {
    http.get(Server.categories).then((response) {
      if (response.statusCode == 200) {
        catData = json.decode(response.body);
        List<String> temp = [];
        catData.forEach((value) {
          temp.add(value['cat_name']);
        });
        setState(() {
          _category = temp;
        });
      }
    });
  }

  int getCategoryId() {
    int temp = 0;
    catData.forEach((item) {
      if (item['cat_name'].toString() == _selectedCategory.toString()) {
        temp = item['id'];
      }
    });
    return temp;
  }

  void getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    config['Authorization'] = 'Token ' + pref.getString('token');
    productData['user_id'] = pref.getInt('id');
    print(config);
  }

  @override
  void initState() {
    super.initState();
    _category = [];
    // productItem = {};
    // if (widget.productItemId != null) {
    //   getProduct();
    // }
    getCategories();
    getUserData();
  }

  final _formKey = GlobalKey<FormState>();
  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 1100,
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
                      style: TextStyle(color: Colors.red),
                      decoration: InputDecoration(
                          hintText: "Product Name",
                          hintStyle: TextStyle(color: Colors.red.shade200),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.label,
                            color: Colors.red,
                          )),
                      onSaved: (value) {
                        productData['product_name'] = value;
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
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Made of ",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.perm_identity,
                              color: Colors.red,
                            )),
                        onSaved: (value) {
                          productData['product_made_of'] = value;
                        },
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
                        maxLength: 8,
                        validator: validatePrice,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Price",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.monetization_on,
                              color: Colors.red,
                            )),
                        onSaved: (value) {
                          productData['product_price'] = value;
                        },
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
                        maxLength: 3,
                        validator: validateQuantity,
                        style: TextStyle(color: Colors.red),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: "Quantity",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock,
                              color: Colors.red,
                            )),
                        onSaved: (value) {
                          productData['product_quantity'] = value;
                        },
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
                        maxLength: 100,
                        validator: validateDetails,
                        style: TextStyle(color: Colors.red),
                        decoration: InputDecoration(
                            hintText: "Product Details",
                            hintStyle: TextStyle(color: Colors.red.shade200),
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.perm_identity,
                              color: Colors.red,
                            )),
                        onSaved: (value) {
                          productData['product_description'] = value;
                        },
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
                    child: DropdownButton(
                      hint: Text(
                        'Please choose a Category',
                        style: TextStyle(color: Colors.red.shade200),
                      ),
                      value: _selectedCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      items: _category.map((category) {
                        return DropdownMenuItem(
                          child: new Text(
                            category,
                            style: TextStyle(color: Colors.red.shade200),
                          ),
                          value: category,
                        );
                      }).toList(),
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
                          'Image 1: ',
                          style: TextStyle(color: Colors.red.shade200),
                        ),
                        popupMenu('image1'),
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Image 2: ',
                          style: TextStyle(color: Colors.red.shade200),
                        ),
                        popupMenu('image2'),
                        image2 == null
                            ? Container()
                            : Image.file(
                                image2,
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Image 3: ',
                          style: TextStyle(color: Colors.red.shade200),
                        ),
                        popupMenu('image3'),
                        image3 == null
                            ? Container()
                            : Image.file(
                                image3,
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
            height: 1100,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      onPressed: submitsell,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: Text("Upload",
                          style: TextStyle(color: Colors.white70)),
                      color: Colors.red,
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget popupMenu(String source) => PopupMenuButton<int>(
        itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("Camera"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("Gallery"),
              ),
            ],
        initialValue: 1,
        onCanceled: () {},
        onSelected: (value) {
          if (value == 1) {
            imageSelectorCamera(source);
          } else if (value == 2) {
            imageSelectorGallery(source);
          }
        },
        icon: Icon(Icons.camera_alt),
      );

  void submitsell() {
    if (_formKey.currentState.validate() &&
        _selectedCategory != null &&
        image1 != null &&
        image2 != null &&
        image3 != null) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      print(productData);
      // String u = ;
      print(getCategoryId());
      FormData data = FormData.from({
        'user_id': productData['user_id'],
        'product_name': productData['product_name'],
        'product_made_of': productData['product_made_of'],
        'product_price': productData['product_price'],
        'product_quantity': productData['product_quantity'],
        'product_description': productData['product_description'],
        'categories': getCategoryId(),
        'image': UploadFileInfo(File(image1.path), image1.path.split('/').last),
        'image2':
            UploadFileInfo(File(image2.path), image2.path.split('/').last),
        'image3': UploadFileInfo(File(image3.path), image3.path.split('/').last)
      });
      try {
        dio
            .post(
          Server.productAdd,
          data: data,
          options: Options(headers: config, contentType: ContentType.json),
        )
            .then((response) {
          setState(() {
            isLoading = false;
          });
          if (response.statusCode == 201) {
            setState(() {
              _formKey.currentState.reset();
              image1 = null;
              image2 = null;
              image3 = null;
            });
            Toast.show('Product Uploaded', context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          } else {
            Toast.show('Product Upload Failed', context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e.message);
        print(e.error);
      }
    } else {
      Toast.show('Please fill all the field', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
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
    if (value.length == 0) {
      return "Product Description is Required";
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

  String validateMobile(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Mobile is Required";
    } else if (value.length != 10) {
      return "Mobile number must 10 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Mobile Number must be digits";
    }
    return null;
  }

  imageSelectorGallery(String s) async {
    switch (s) {
      case 'image1':
        image1 = await ImagePicker.pickImage(
          source: ImageSource.gallery,
        );
        break;
      case 'image2':
        image2 = await ImagePicker.pickImage(
          source: ImageSource.gallery,
        );
        break;
      case 'image3':
        image3 = await ImagePicker.pickImage(
          source: ImageSource.gallery,
        );
        break;
    }
    print(image1);
    setState(() {});
  }

  imageSelectorCamera(String s) async {
    switch (s) {
      case 'image1':
        image1 = await ImagePicker.pickImage(
            source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
        break;
      case 'image2':
        image2 = await ImagePicker.pickImage(
            source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
        break;
      case 'image3':
        image3 = await ImagePicker.pickImage(
            source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
        break;
    }
    setState(() {});
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
