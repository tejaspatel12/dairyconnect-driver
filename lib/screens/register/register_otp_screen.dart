import 'dart:async';
import 'dart:ui';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
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

class RegisterOTPScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RegisterOTPScreenState();
  }
}

class RegisterOTPScreenState extends State<RegisterOTPScreen>{
  BuildContext _ctx;

  Timer _timer,_newtimer;
  int _start = 30;
  int _newstart = 60;

  bool _isLoading = false;
  bool first = false;
  bool _isLoad = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String last_id, deliveryboy_id,otp,_otpcode,deliveryboy_mobile,new_last_id;
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
    startTimer();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            startNewTimer();
          });
        } else {
          setState(() {
            print("_start : "+ _start.toString());
            _start--;
          });
        }
      },
    );
  }

  void startNewTimer() {
    const oneSec = const Duration(seconds: 1);
    _newtimer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_newstart == 0) {
          setState(() {
            // _start = 10;
            timer.cancel();
          });
        } else {
          setState(() {
            print("_start : "+ _newstart.toString());
            _newstart--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    // timer?.cancel();
    _timer.cancel();
    _newtimer.cancel();
    // startTimer();
    // startNewTimer();
  }


  @override
  Widget build(BuildContext context) {
    _ctx = context;
    setState(() {
      final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
      last_id = arguments['last_id'];
      deliveryboy_id = arguments['deliveryboy_id'];
      otp = arguments['otp'];
      deliveryboy_mobile = arguments['deliveryboy_mobile'];
    });
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
                    height: MediaQuery.of(context).size.width * 0.40,
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
                        color: concolor,
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

                                Text("Verification Code", style: TextStyle(color: maincolor,fontSize: textSizeLarge),),
                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.02,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                  child: Text("OTP has been send to your mobile number please enter OTP below", style: TextStyle(color: whitecolor,fontSize: textSizeSMedium,letterSpacing: 0.4,),),
                                ),

                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.06,
                                ),

                                Form(
                                  key: formKey,
                                  child: PinCodeFields(
                                    length: 6,
                                    onChange: (val) {
                                      setState(() {
                                        _otpcode = val;
                                      });
                                    },
                                    keyboardType: TextInputType.number,
                                    borderColor: maincolor,
                                    fieldBackgroundColor: concolor,
                                    onComplete: (result) {
                                      // Your logic with code
                                      print(result);
                                    },
                                  ),
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
                              onTap: () {
                                if (_isLoading == false) {
                                  final form = formKey.currentState;
                                  if (form.validate()) {
                                    setState(() => _isLoading = true);
                                    form.save();
                                    NetworkUtil _netUtil = new NetworkUtil();
                                    _netUtil.post(RestDatasource.LOGIN, body: {
                                      "action": "deliveryboyotpregister",
                                      "last_id": first==true?new_last_id:last_id,
                                      "deliveryboy_id": deliveryboy_id,
                                      "otp": _otpcode,
                                    }).then((dynamic res) async {
                                      if(res["status"] == "yes")
                                      {
                                        setState(() => _isLoading = false);
                                        // FlashHelper.successBar(context, message: res['message']);
                                        Navigator.of(context).pushNamed("/registersec",
                                            arguments: {
                                              "deliveryboy_mobile" : deliveryboy_mobile,
                                              "deliveryboy_id" : deliveryboy_id,
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
                                    Text("NEXT",
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
                          first==false?

                          Container(
                            child: _start != 0?InkWell(
                              onTap: ()
                              {

                              },
                              child: Center(
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
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
                                        child: Text("Resend Otp code in "+" "+_start.toString()+" sec".toUpperCase(),style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600,color: whitecolor, letterSpacing: 0.5),),
                                      )
                                  )
                              ),
                            ):InkWell(
                              onTap: ()
                              {
                                first = true;
                                if (_isLoad == false) {
                                  setState(() => _isLoad = true);
                                  NetworkUtil _netUtil = new NetworkUtil();
                                  _netUtil.post(RestDatasource.LOGIN, body: {
                                    "action": "resenddelotp",
                                    "deliveryboy_mobile": deliveryboy_mobile,
                                    "deliveryboy_id": deliveryboy_id,
                                  }).then((dynamic res) async {
                                    if(res["status"] == "yes")
                                    {
                                      setState(() {
                                        new_last_id = res["last_id"].toString();
                                      });
                                      // FlashHelper.successBar(context, message: last_id);
                                      setState(() => _isLoad = false);
                                    }
                                    else {
                                      setState(() => _isLoad = false);
                                      // FlashHelper.errorBar(context, message: res['message']);
                                    }
                                  });
                                }
                              },
                              child: Center(
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
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
                                        child: Text("Resend Otp".toUpperCase(),style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600,color: whitecolor, letterSpacing: 0.5),),
                                      )
                                  )
                              ),
                            ),
                          ):
                          Container(
                            child: _newstart != 0?
                            InkWell(
                              onTap: ()
                              {

                              },
                              child: Center(
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
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
                                        child: Text("Resend Otp code in "+" "+_newstart.toString()+" sec".toUpperCase(),style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600,color: whitecolor, letterSpacing: 0.5),),
                                      )
                                  )
                              ),
                            ):InkWell(
                              onTap: ()
                                {
                                first = true;
                                if (_isLoad == false) {
                                setState(() => _isLoad = true);
                                NetworkUtil _netUtil = new NetworkUtil();
                                _netUtil.post(RestDatasource.LOGIN, body: {
                                "action": "resenddelotp",
                                "deliveryboy_mobile": deliveryboy_mobile,
                                "deliveryboy_id": deliveryboy_id,
                                }).then((dynamic res) async {
                                if(res["status"] == "yes")
                                {
                                setState(() {
                                new_last_id = res["last_id"].toString();
                                });
                                // FlashHelper.successBar(context, message: last_id);
                                setState(() => _isLoad = false);
                                }
                                else {
                                setState(() => _isLoad = false);
                                // FlashHelper.errorBar(context, message: res['message']);
                                }
                                });
                                }
                                },
                                child: Center(
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
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
                                          child: Text("Resend Otp".toUpperCase(),style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600,color: whitecolor, letterSpacing: 0.5),),
                                        )
                                    )
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
