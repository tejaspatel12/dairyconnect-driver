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
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';

import '../../auth.dart';

class RegisterFirstScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RegisterFirstScreenState();
  }
}

class RegisterFirstScreenState extends State<RegisterFirstScreen>{
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _mobile_numbers;
  bool passwordVisible = true;

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
  

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: blackcolor,
        // backgroundColor: maincolor,
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

                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                              [
                                Color(0xFF0EF6BE).withOpacity(0.3),
                                Color(0xFFF44336).withOpacity(0.05),
                              ],
                              stops: [0.1, 1],),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.06,
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Column(
                              children: [

                                Image.asset(
                                  'images/logo.png',
                                  width: MediaQuery.of(context).size.width * 80,
                                  height: MediaQuery.of(context).size.height * 0.20,
                                ),

                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.06,
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Register ", style: TextStyle(color: maincolor,fontSize: textSizeLargeMedium),),
                                    Text("Your Account", style: TextStyle(color: whitecolor,fontSize: textSizeLargeMedium),),
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.06,
                                ),

                                Form(
                                  key: formKey,
                                  child: TextFormField(
                                      initialValue: null,
                                      obscureText: false,
                                      keyboardType: TextInputType.number,
                                      onSaved: (val) => _mobile_numbers = val,
                                      validator: validateMobile,
                                      decoration: InputDecoration(

                                        // labelText: 'Enter Your Mobile Number',
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
                                          fillColor: Colors.black12,
                                          filled: true)),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.06,
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(25,0, 25, 0),
                            child: InkWell(
                              onTap: ()
                              {
                                if (_isLoading == false) {
                                  final form = formKey.currentState;
                                  if (form.validate()) {
                                    setState(() => _isLoading = true);
                                    form.save();
                                    NetworkUtil _netUtil = new NetworkUtil();
                                    _netUtil.post(RestDatasource.LOGIN, body: {
                                      "action": "deliveryboyregister",
                                      "deliveryboy_mobile": _mobile_numbers,
                                    }).then((dynamic res) async {
                                      if(res["status"] == "yes")
                                      {
                                        setState(() => _isLoading = false);
                                        // FlashHelper.successBar(context, message: res['message'].toString());
                                        Navigator.of(context).pushNamed("/registerotp",
                                            arguments: {
                                              "last_id" : res["last_id"].toString(),
                                              "deliveryboy_id" : res["deliveryboy_id"].toString(),
                                              "otp" : res["deliveryboy_otp"].toString(),
                                              "deliveryboy_mobile" : _mobile_numbers,
                                            });
                                      }
                                      else {
                                        setState(() => _isLoading = false);
                                        // FlashHelper.errorBar(context, message: res['message']);
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 10),
                                alignment: Alignment.center,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("SEND OTP",
                                      style: TextStyle(
                                          color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.06,
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
