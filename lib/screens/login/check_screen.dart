import 'dart:async';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:nooranidairyfarm_deliveryboy/data/database_helper.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/models/admin.dart';
import 'package:nooranidairyfarm_deliveryboy/models/user.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/flash_helper.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:flutter/material.dart';

import '../../auth.dart';
import 'login_screen_presenter.dart';

class CheckScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new CheckScreenState();
  }
}

class CheckScreenState extends State<CheckScreen> implements LoginScreenContract, AuthStateListener {
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _username, _password;
  bool passwordVisible = true;
  LoginScreenPresenter _presenter;

  String deliveryboy_token="";

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

  CheckScreenState() {
    _presenter = new LoginScreenPresenter(this);
    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);
  }

  @override
  onAuthStateChanged(AuthState state) {
    if (state == AuthState.LOGGED_IN)
      Navigator.of(_ctx).pushReplacementNamed("/bottomhome");
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        // backgroundColor: shadecolor,
        // backgroundColor: maincolor,
        // backgroundColor: Colors.transparent,
        // backgroundColor: Colors.grey.shade50,
        body:SafeArea(
          child: Stack(
            children: [
              // Image.asset(
              // 'images/bg.jpg',
              //   fit: BoxFit.fill,
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height,
              // ),

              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.4,
                    ),
                    Image.asset(
                      'images/apple.png',
                      // fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.07,
                    ),
                    Text("User Application",style: TextStyle(color: maincolor,fontSize: 30,fontWeight: FontWeight.w600),),
                  ],
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          bottomRight: Radius.circular(0.0),
                          topLeft: Radius.circular(30.0),
                          bottomLeft: Radius.circular(0.0)),

                      // gradient: LinearGradient(
                      // begin: Alignment.topLeft,
                      // end: Alignment.bottomRight,
                      // colors: [
                      //   Color(0xFF0EF6BE).withOpacity(0.3),
                      //   Color(0xFFF44336).withOpacity(0.05),
                      // ],
                      // stops: [
                      //   0.1,
                      //   1,
                      // ]),

                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                        [
                          Color(0xFF1638E0).withOpacity(0.3),
                          // Color(0xFFF63636).withOpacity(0.3),
                          Color(0xFFA3C2D3).withOpacity(0.05),
                        ],
                        stops: [0.1, 1],),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.04,
                          ),

                          InkWell(
                            onTap: ()
                            {
                              Navigator.of(context).pushNamed("/login");
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[

                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      color: maincolor,
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(-0, -2),
                                            color: Colors.white10// shadow direction: bottom right
                                        ),
                                        BoxShadow(
                                          color: Colors.black38,
                                          blurRadius: 2.0,
                                          spreadRadius: 0.0,
                                          offset: Offset(2.0, 2.0), // shadow direction: bottom right
                                        )
                                      ],
                                    ),
                                    padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                    child: Text("Log in".toUpperCase(),
                                      style: TextStyle(fontSize: 14,
                                          color: Colors.white,fontWeight: FontWeight.w500),
                                    ),
                                    // Text("LOG IN NOW", style: TextStyle(color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.02,
                          ),
                          Text("or".toUpperCase(), style: TextStyle(color: redcolor,fontSize: 15.0),),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.02,
                          ),
                          InkWell(
                            onTap: ()
                            {
                              Navigator.of(context).pushNamed("/register");
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[

                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      color: maincolor,
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(-0, -2),
                                            color: Colors.white10// shadow direction: bottom right
                                        ),
                                        BoxShadow(
                                          color: Colors.black38,
                                          blurRadius: 2.0,
                                          spreadRadius: 0.0,
                                          offset: Offset(2.0, 2.0), // shadow direction: bottom right
                                        )
                                      ],
                                    ),
                                    padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                    child: Text("Signup".toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,fontWeight: FontWeight.w500),
                                    ),
                                    // Text("Create Now".toUpperCase(), style: TextStyle(color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold),),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.03,
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),


        ),

      );
    }
  }

  @override
  void onLoginError(String errorTxt) {
    // FlashHelper.errorBar(context, message: errorTxt);
    setState(() => _isLoading = false);
  }

  @override
  void onLoginSuccess(Admin user) async {
    //_showSnackBar(user.toString());
    setState(() => _isLoading = false);
    var db = new DatabaseHelper();
    await db.saveUser(user);
    var authStateProvider = new AuthStateProvider();
    authStateProvider.notify(AuthState.LOGGED_IN);
  }

  String validateMobile(String value) {
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }
}
