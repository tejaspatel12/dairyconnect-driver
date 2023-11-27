import 'dart:async';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth.dart';
import 'login_screen_presenter.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> implements LoginScreenContract, AuthStateListener {
  BuildContext _ctx;

  bool _isLoading = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _mobile_numbers,_otp;
  bool passwordVisible = true;
  LoginScreenPresenter _presenter;

  String deliveryboy_token="";
  String app_login;

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  NetworkUtil _netUtil = new NetworkUtil();

  _loadUser() async {
    _netUtil.post(RestDatasource.APP_SETTING, body: {
      'action': "show_app_setting",
    }).then((dynamic res) async {
      // print(res);
      setState(() {
        // product_name = res[0]["product_name"];
        app_login = res[0]["app_login"];
        // app_login = "../images/more/"+app_login;
        _isLoading = false;
      });
    });
  }

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
    _loadUser();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  LoginScreenState() {
    _presenter = new LoginScreenPresenter(this);
    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);
  }

  @override
  onAuthStateChanged(AuthState state) {
    if (state == AuthState.LOGGED_IN)
      Navigator.of(_ctx).pushReplacementNamed("/selecttime");
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        // backgroundColor: blackcolor,
        backgroundColor: shadecolor,
        // backgroundColor: Colors.transparent,
        // backgroundColor: Colors.grey.shade50,
        body:SafeArea(
          child: Stack(
            children: [
              ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.50,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0)),
                            color: whitecolor,

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

                            // gradient: LinearGradient(
                            // begin: Alignment.topLeft,
                            // end: Alignment.bottomRight,
                            // colors:
                            // [
                            //   Color(0xFF1638E0).withOpacity(0.3),
                            //   // Color(0xFFF63636).withOpacity(0.3),
                            //   Color(0xFFA3C2D3).withOpacity(0.05),
                            // ],
                            // stops: [0.1, 1],),

                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.06,
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'images/logo_bg.png',
                                    width: MediaQuery.of(context).size.width * 80,
                                    height: MediaQuery.of(context).size.height * 0.20,
                                  ),

                                  SizedBox(
                                    height: MediaQuery.of(context).size.width * 0.06,
                                  ),
                                  Text("Delivery Boy Login", style: TextStyle(color: redcolor,fontSize: textSizeNormal,fontWeight: FontWeight.w600),),

                                  SizedBox(
                                    height: MediaQuery.of(context).size.width * 0.06,
                                  ),

                                  TextFormField(
                                      initialValue: null,
                                      obscureText: false,
                                      keyboardType: TextInputType.number,
                                      onSaved: (val) => _mobile_numbers = val,
                                      validator: validateMobile,
                                      decoration: InputDecoration(
                                          hintText: 'Enter Your Mobile Number',
                                          hintStyle: TextStyle(color: maincolor),
                                          labelStyle: TextStyle(color: maincolor),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: maincolor
                                              )
                                          ),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide()
                                          ),
                                          fillColor: whitecolor,
                                          filled: true,
                                          isDense: true,
                                          contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),)),

                                  SizedBox(
                                    height: MediaQuery.of(context).size.width * 0.04,
                                  ),

                                  TextFormField(
                                      initialValue: null,
                                      obscureText: false,
                                      keyboardType: TextInputType.visiblePassword,
                                      onSaved: (val) => _otp = val,
                                      // validator: validateMobile,
                                      decoration: InputDecoration(

                                        // labelText: 'Enter Your Mobile Number',
                                        hintText: 'Enter Your Password',

                                        hintStyle: TextStyle(color: maincolor),
                                        labelStyle: TextStyle(color: maincolor),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: maincolor
                                            )
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide()
                                        ),
                                        fillColor: whitecolor,
                                        filled: true,
                                        isDense: true,
                                        contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),)),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.02,
                          ),

                          _isLoading == false?
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                                    child: InkWell(
                                      onTap: () {
                                        if (_isLoading == false) {
                                          final form = formKey.currentState;
                                          if (form.validate()) {
                                            setState(() => _isLoading = true);
                                            form.save();
                                            NetworkUtil _netUtil = new NetworkUtil();
                                            _netUtil.post(RestDatasource.LOGIN, body: {
                                              "action": "deliveryboylogin",
                                              "deliveryboy_mobile": _mobile_numbers,
                                              "deliveryboy_password": _otp,
                                            }).then((dynamic res) async {
                                              if(res["status"] == "yes")
                                              {
                                                Fluttertoast.showToast(msg: res["message"], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: maincolor, fontSize: MediaQuery.of(context).size.width * 0.04);

                                                print("HEE :" + res["status"]);
                                                setState(() => _isLoading = false);

                                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                                prefs.setString("type", "delivery_boy");
                                                prefs.setString("deliveryboy_id", res["data"]["deliveryboy_id"]);
                                                prefs.setString("deliveryboy_name", res["data"]["deliveryboy_name"]);
                                                prefs.setString("deliveryboy_mobile", res["data"]["deliveryboy_mobile"]);
                                                prefs.setString("theme", "1");

                                                Navigator.of(context).pushNamed("/selecttime");
                                              }
                                              else {
                                                Fluttertoast.showToast(msg: res["message"], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                                                setState(() => _isLoading = false);
                                              }
                                            });
                                          }
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5.0),
                                            topRight: Radius.circular(5.0),
                                            bottomLeft: Radius.circular(5.0),
                                            bottomRight: Radius.circular(5.0),
                                          ),
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
                                        alignment: Alignment.center,
                                        child: Text("lOGIN".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ):
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                                    child: InkWell(
                                      onTap: () {
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5.0),
                                            topRight: Radius.circular(5.0),
                                            bottomLeft: Radius.circular(5.0),
                                            bottomRight: Radius.circular(5.0),
                                          ),
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
                                        alignment: Alignment.center,
                                        child: Text("please wait".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.04,
                          ),

                          // InkWell(
                          //   onTap: ()
                          //   {
                          //     Navigator.of(context).pushNamed("/registersec");
                          //   },
                          //     child: Text("Create Account", style: TextStyle(color: redcolor,fontSize: textSizeMMedium),)
                          // ),
                          //
                          // SizedBox(
                          //   height: MediaQuery.of(context).size.width * 0.05,
                          // ),



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
