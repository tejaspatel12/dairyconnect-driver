import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:face_camera/face_camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_balance_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:flutter/material.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth.dart';


class AddUserBalanceScreen extends StatefulWidget {

  @override
  State<AddUserBalanceScreen> createState() => _AddUserBalanceScreenState();
}

class _AddUserBalanceScreenState extends State<AddUserBalanceScreen> {

  BuildContext _ctx;
  // LocationResult _pickedLocation;

  bool _isLoading = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String user_id,user_first_name,user_last_name,user_balance="0",current_amount,deliveryboy_id,newbalance;
  bool Selfie = false;
  int num = 0;
  double cura = 0, newa = 0 , totala;
  File _image = null;

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;
  NetworkUtil _netUtil = new NetworkUtil();

  TextEditingController user_amount_namecontroller=new TextEditingController();

  _loadJob() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    deliveryboy_id= prefs.getString("deliveryboy_id") ?? '';
    print(deliveryboy_id);
    _netUtil.post(RestDatasource.GET_DELIVEYBOY, body: {
      'action': "show_user_balance",
      'user_id': user_id,
      "token":token,
    }).then((dynamic res) async {
      print(res);
      setState(() {
        num = 1;
        print(res);
        current_amount=res[0]["user_balance"].toString();
        cura = double.parse(current_amount);
        _isLoading=false;
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

  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              // elevation: 2.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: maincolor, width: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              margin: new EdgeInsets.symmetric(
                  horizontal: 0.0, vertical: 5.0),
              child: Container(
                color: whitecolor,
                child: new Wrap(
                  children: <Widget>[
                    new ListTile(
                        leading: new Icon(Icons.photo_library,color: maincolor,),
                        title: new Text('Photo Library',style: TextStyle(fontSize: 14,color:maincolor)),
                        onTap: () {
                          _imgFromGallery();
                          Navigator.of(context).pop();
                        }),
                    new ListTile(
                      leading: new Icon(Icons.photo_camera,color: maincolor,),
                      title: new Text('Camera',style: TextStyle(fontSize: 14,color:maincolor)),
                      onTap: () {
                        _imgFromCamera();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }


  //Profile IMG
  _imgFromCamera() async {
    // var image = await ImagePicker.pickImage(
    //     source: ImageSource.camera, imageQuality: 50);
    var image = await ImagePicker().pickImage(source: ImageSource.camera,imageQuality: 50);

    setState(() {
      // _adharf = image;
      _image = File(image.path);
    });
  }

  _imgFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 50);

    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _ctx = context;
      final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
      user_id = arguments['user_id'];
      user_first_name = arguments['user_first_name'];
      user_last_name = arguments['user_last_name'];
      num == 0?_loadJob():null;
    });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("Add $user_first_name $user_last_name Balance",style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: maincolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body:(_isLoading)
            ? new Center(
          child: Lottie.asset(
            'assets/load.json',
            repeat: true,
            reverse: true,
            animate: true,
          ),

        )
            : Stack(
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.09,
                    ),
                    Center(child: Text("Current Balance : $current_amount",style: TextStyle(color: maincolor,fontSize: MediaQuery.of(context).size.width * 0.05, fontWeight: FontWeight.w600),)),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.09,
                    ),
                    _image==null?
                    TextFormField(
                        initialValue: null,
                        obscureText: false,
                        keyboardType: TextInputType.number,
                        onSaved: (val) => user_balance = val,
                        onChanged: (val) {
                          setState(() {
                            user_balance = val;
                            newa = double.parse(user_balance);
                            totala = newa + cura;
                          });
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.currency_pound,
                              color: maincolor,
                            ),
                            hintText: 'Balance',
                            // isDense: true,
                            // contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                            labelStyle: TextStyle(color: maincolor),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(
                                  color: maincolor,width: 2,
                                )
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(
                                  color: maincolor,width: 2,
                                )
                            ),
                            filled: true)):
                    TextFormField(
                        enabled: false,
                        initialValue: null,
                        obscureText: false,
                        keyboardType: TextInputType.number,
                        onSaved: (val) => user_balance = val,
                        onChanged: (val) {
                          setState(() {
                            user_balance = val;
                            newa = double.parse(user_balance);
                            totala = newa + cura;
                          });
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.currency_pound,
                              color: maincolor,
                            ),
                            hintText: 'Balance',
                            // isDense: true,
                            // contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                            labelStyle: TextStyle(color: maincolor),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(
                                  color: maincolor,width: 2,
                                )
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide(
                                  color: maincolor,width: 2,
                                )
                            ),
                            filled: true)),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.05,
                    ),
                    Text("Note : Current Balance is $current_amount. + New Balance $user_balance, Total is $totala",style: TextStyle(color: redcolor),),

                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.06,
                    ),

                  ],
                ),
              ),
            ),



            _image==null?
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[


                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(25,15, 25, 20),
                          child:
                          InkWell(
                            onTap: () {

                              if(user_balance=="0")
                              {
                                Fluttertoast.showToast(msg: "Please Enter Balance", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                              }
                              else
                              {
                                // _showPicker(context);
                                _imgFromCamera();
                              }
                              // if (_isLoading == false) {
                              //   final form = formKey.currentState;
                              //   if (form.validate()) {
                              //     setState(() => _isLoading = true);
                              //     form.save();
                              //     _netUtil.post(
                              //         RestDatasource.GET_DELIVEYBOY, body: {
                              //       'action': "add_user_balance",
                              //       "token":token,
                              //       "user_id":user_id,
                              //       "deliveryboy_id":deliveryboy_id,
                              //       "current_amount":current_amount,
                              //       "payment_amt":user_balance,
                              //     }).then((dynamic res) async {
                              //       // print("Web Output"+res["status"]);
                              //       if (res["status"] == "yes") {
                              //         // FlashHelper.successBar(context, message: res["message"]);
                              //         setState(() => _isLoading = false);
                              //
                              //         // Navigator.of(context).pushReplacementNamed("/userbalance",
                              //         //     arguments: {
                              //         //       "user_id" : user_id,
                              //         //       "user_first_name" : user_first_name,
                              //         //       "user_last_name" : user_last_name,
                              //         //     }
                              //         // );
                              //         Navigator.pop(context,false);
                              //       }
                              //       else {
                              //         // FlashHelper.errorBar(context, message: res["message"]);
                              //         setState(() => _isLoading = false);
                              //       }
                              //     });
                              //   }
                              // }
                            },

                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0),
                                  bottomLeft: Radius.circular(15.0),
                                  bottomRight: Radius.circular(15.0),
                                ),
                                color: maincolor,
                              ),
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                              alignment: Alignment.center,
                              child: Text("Take Selfie".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ):

            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0)),

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
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.06,
                      ),
                      Container(
                        color : redcolor,
                        height : MediaQuery.of(context).size.width * 0.8,
                        child: Image.file(
                          _image,
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                          child:
                          InkWell(
                            onTap: () {

                              if(user_balance=="0")
                              {
                                Fluttertoast.showToast(msg: "Please Enter Balance", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                              }
                              else
                              {
                                if (_isLoading == false) {
                                  final form = formKey.currentState;
                                  String base64Image = base64Encode(_image.readAsBytesSync());
                                  if (form.validate()) {
                                    setState(() => _isLoading = true);
                                    form.save();
                                    _netUtil.post(
                                        RestDatasource.GET_DELIVEYBOY, body: {
                                      'action': "add_user_balance",
                                      "token":token,
                                      "user_id":user_id,
                                      "deliveryboy_id":deliveryboy_id,
                                      "deliveryboy_img":base64Image,
                                      "current_amount":current_amount,
                                      "payment_amt":user_balance,
                                    }).then((dynamic res) async {
                                      // print("Web Output"+res["status"]);
                                      if (res["status"] == "yes") {
                                        // FlashHelper.successBar(context, message: res["message"]);
                                        setState(() => _isLoading = false);
                                        setState(() => newbalance = current_amount + user_balance);
                                        Navigator.of(context).pushReplacementNamed("/user");
                                        // Navigator.push(context,
                                        //     MaterialPageRoute(
                                        //       builder: (context) => UserBalanceListScreen(user_id: user_id,user_first_name:user_first_name,user_last_name:user_last_name, user_balance:newbalance),
                                        //     ));

                                        // Navigator.of(context).pushReplacementNamed("/userbalance",
                                        //     arguments: {
                                        //       "user_id" : user_id,
                                        //       "user_first_name" : user_first_name,
                                        //       "user_last_name" : user_last_name,
                                        //       "user_balance" : newbalance,
                                        //     }
                                        // );
                                        // Navigator.pop(context,false);
                                      }
                                      else {
                                        // FlashHelper.errorBar(context, message: res["message"]);
                                        setState(() => _isLoading = false);
                                      }
                                    });
                                  }
                                }

                              }

                            },

                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0),
                                  bottomLeft: Radius.circular(15.0),
                                  bottomRight: Radius.circular(15.0),
                                ),
                                color: maincolor,
                              ),
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                              alignment: Alignment.center,
                              child: Text("Add Balance".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),

          ],
        ),

      );
    }
  }
}




