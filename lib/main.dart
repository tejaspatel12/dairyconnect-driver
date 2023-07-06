import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nooranidairyfarm_deliveryboy/routes.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database_helper.dart';

void main() => runApp(new LoginApp());

class LoginApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;
    return new MaterialApp(
      title: 'Deliveryboy',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData.dark(),
      theme: ThemeData.light(),
      routes: routes,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{
  BuildContext _ctx;
  String type,selected_time;
  SharedPreferences prefs;

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  _loadUser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      type= prefs.getString("type") ?? '';
      selected_time= prefs.getString("selected_time") ?? '';
      prefs.setString("theme", "1");
    });
    print("type " + type);
  }

  void navigationPage() async {
    if(type=="delivery_boy")
    {
      if(selected_time=="")
      {
        Navigator.of(context).pushNamedAndRemoveUntil('/selecttime', (Route<dynamic> route) => false);
      }
      else
      {
        Navigator.of(context).pushNamedAndRemoveUntil('/bottomhome', (Route<dynamic> route) => false);
      }
    }
    else
    {
      // Navigator.of(context).pushNamedAndRemoveUntil('/check', (Route<dynamic> route) => false);
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  // void navigationPage() async {
  //   var db = new DatabaseHelper();
  //   var isLoggedIn = await db.isLoggedIn();
  //   if(isLoggedIn) {
  //     Navigator.of(context).pushNamedAndRemoveUntil('/bottomhome', (Route<dynamic> route) => false);
  //   } else {
  //     Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    startTime();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // backgroundColor: maincolor,
      backgroundColor: shadecolor,
      body: new Center(
        child: new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'images/logo_bg.png',
                  width: MediaQuery.of(context).size.width * 0.70,
              ),
              // new Container(
              //   padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
              //   child: new CircularProgressIndicator(
              //     // backgroundColor: maincolor,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}