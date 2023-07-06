import 'dart:async';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:flutter/material.dart';

class JSONScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new JSONScreenState();
  }
}

class JSONScreenState extends State<JSONScreen>{
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _username, _password;

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    // startTime();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        drawer: DrawerNavigationBarController(),
        // backgroundColor: shadecolor,
        // appBar: AppBar(
        //   backgroundColor: maincolor,
        //   title: Text("Contact Us".toUpperCase(),style: TextStyle(color: Colors.white),),
        //   iconTheme: IconThemeData(color: Colors.white),
        //   centerTitle: true,
        // ),
        body:ListView(
          padding: EdgeInsets.only(top: 5),
          children: [
            Lottie.asset(
              'assets/jsonviewer.json',
              repeat: true,
              reverse: false,
              animate: true,
              height: MediaQuery.of(context).size.height * 0.40,
            ),
          ],
        ),

      );
    }
  }

}
