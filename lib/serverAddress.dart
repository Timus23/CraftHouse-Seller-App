class Server {
  static const String localAddress = 'http://10.0.2.2:8000';
  static const String media = 'http://10.0.2.2:8000/media/';
  static const String login = 'http://10.0.2.2:8000/api/accounts/login/';
  static const String logout = 'http://10.0.2.2:8000/api/accounts/logout';
  static const String signup = 'http://10.0.2.2:8000/api/accounts/signup/';
  static const String reset =
      'http://10.0.2.2:8000/api/accounts/password/reset/';
  static const String resetCodeVerifed =
      'http://10.0.2.2:8000/api/accounts/password/reset/verified/';
  static const String resetCodeVerify =
      'http://10.0.2.2:8000/api/accounts/password/reset/verify/?code=';
  static const String signupVerify =
      'http://10.0.2.2:8000/api/accounts/signup/verify/?code=';
  static const String products = 'http://10.0.2.2:8000/api/products/';
  static const String productAdd = 'http://10.0.2.2:8000/api/products/add/';
  static const String productDelete =
      'http://10.0.2.2:8000/api/products/delete/';
  static const String productUpdate =
      'http://10.0.2.2:8000/api/products/update/';
  static const String categories =
      'http://10.0.2.2:8000/api/products/categories/';
  static const String courses = 'http://10.0.2.2:8000/api/courses/';
  static const String courseAdd = 'http://10.0.2.2:8000/api/courses/add/';
  static const String courseUpdate = 'http://10.0.2.2:8000/api/courses/update/';
  static const String courseDelete = 'http://10.0.2.2:8000/api/courses/delete/';
  static const String videoAdd = 'http://10.0.2.2:8000/api/video/add/';
  static const String testAdd = 'http://10.0.2.2:8000/api/courses/createtest/';
  static const String questionAdd =
      'http://10.0.2.2:8000/api/courses/createquestion/';
}
