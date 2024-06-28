import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pfaa/screens/login/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Splash_screen extends StatefulWidget {
  Splash_screen({Key? key, required this.title}) : super(key: key);

  final String title;


  @override
  State<Splash_screen> createState() => _Splash_screenState();
}

class _Splash_screenState extends State<Splash_screen> {
  late SharedPreferences _sharedPreferences;

  @override
  void initState() {
    super.initState();

    isLogin();
  }

  void isLogin() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    Timer(Duration(seconds: 5), () {
      if (_sharedPreferences.getInt('userid') == null &&
          _sharedPreferences.getString('usermail') == null) {
        Route route = MaterialPageRoute(builder: (_) => LoginModel());
        Navigator.pushReplacement(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(


        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.jpg"),
          ],
        ),
      ),
    );
  }

}