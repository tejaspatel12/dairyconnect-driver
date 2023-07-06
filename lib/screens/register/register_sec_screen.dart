import 'dart:async';
import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nooranidairyfarm_deliveryboy/data/database_helper.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/models/admin.dart';
import 'package:nooranidairyfarm_deliveryboy/models/area.dart';
import 'package:nooranidairyfarm_deliveryboy/models/city.dart';
import 'package:nooranidairyfarm_deliveryboy/models/country.dart';
import 'package:nooranidairyfarm_deliveryboy/models/state.dart';
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

class RegisterSecScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RegisterSecScreenState();
  }
}

class RegisterSecScreenState extends State<RegisterSecScreen>{
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String deliveryboy_mobile,deliveryboy_id,user_first_name,user_last_name,user_email,area;
  bool passwordVisible = true;

  String selectedArea = null,_Areatype=null;


  Future<List<AreaList>> AreaListdata;
  Future<List<AreaList>> AreaListfilterData;

  TextEditingController user_first_name_namecontroller = new TextEditingController();
  TextEditingController user_last_name_namecontroller = new TextEditingController();
  TextEditingController user_email_namecontroller = new TextEditingController();
  TextEditingController area_namecontroller = new TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey3 = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey4 = new GlobalKey<RefreshIndicatorState>();


  SharedPreferences prefs;
  NetworkUtil _netUtil = new NetworkUtil();

  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {

      // AreaListdata = _getAreaData();
      // AreaListfilterData=AreaListdata;

    });
  }


  //Area
  // Future<List<AreaList>> _getAreaData() async
  // {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   return _netUtil.post(RestDatasource.LOCATION,
  //       body:{
  //         'action': "show_area",
  //         'city_id': _Citytype,
  //       }).then((dynamic res)
  //   {
  //     final items = res.cast<Map<String, dynamic>>();
  //     // print(items);
  //     List<AreaList> listofusers = items.map<AreaList>((json) {
  //       return AreaList.fromJson(json);
  //     }).toList();
  //     List<AreaList> revdata = listofusers.toList();
  //
  //     return revdata;
  //   });
  // }
  //
  // Future<List<AreaList>> _refresh4() async
  // {
  //   setState(() {
  //     AreaListdata = _getAreaData();
  //     AreaListfilterData=AreaListdata;
  //   });
  // }

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
    // setState(() {
    //   final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
    //   deliveryboy_mobile = arguments['deliveryboy_mobile'];
    //   deliveryboy_id = arguments['deliveryboy_id'];
    // });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        // backgroundColor: shadecolor,
        body:SafeArea(
          child: Stack(
            children: [

              NestedScrollView(
                headerSliverBuilder: (BuildContext context,
                    bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      centerTitle: true,
                      backgroundColor: maincolor,
                      title: Text("Register",
                        style: TextStyle(color: Colors.white),),
                      iconTheme: IconThemeData(color: Colors.white),

                      pinned: true,
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                    ),
                  ];
                },
                body:ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                            initialValue: null,
                            obscureText: false,
                            keyboardType: TextInputType.text,
                            onSaved: (val) {
                              setState(() {
                                user_first_name = val;
                              });
                            },
                            validator: validateMiddleName,
                            decoration: InputDecoration(

                              // labelText: 'Enter Your Mobile Number',
                                hintText: 'Enter Your Name',

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

                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.04,
                            ),
                            TextFormField(
                                initialValue: null,
                                obscureText: false,
                                keyboardType: TextInputType.number,
                                onSaved: (val) {
                                  setState(() {
                                    user_last_name = val;
                                  });
                                },
                                validator: validateMiddleName,
                                decoration: InputDecoration(

                                  // labelText: 'Enter Your Mobile Number',
                                    hintText: 'Enter Phone Number',

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

                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.04,
                            ),

                            TextFormField(
                                initialValue: null,
                                obscureText: false,
                                keyboardType: TextInputType.emailAddress,
                                onSaved: (val) {
                                  setState(() {
                                    user_email = val;
                                  });
                                },
                                decoration: InputDecoration(

                                    hintText: 'Enter Your Email Address',

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

                            SizedBox(
                                height: MediaQuery.of(context).size.width * 0.04,
                          ),

                            TextFormField(
                                initialValue: null,
                                obscureText: false,
                                keyboardType: TextInputType.visiblePassword,
                                onSaved: (val) {
                                  setState(() {
                                    user_email = val;
                                  });
                                },
                                decoration: InputDecoration(

                                    hintText: 'Create Your Password',

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

                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.04,
                            ),



                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  Container(
                    child: Column(
                      children: [


                        Padding(
                          padding: const EdgeInsets.fromLTRB(20,0, 20, 0),
                          child: InkWell(
                            onTap: ()
                            {
                              // if (_isLoading == false) {
                              //   final form = formKey.currentState;
                              //   if (form.validate()) {
                              //     setState(() => _isLoading = true);
                              //     form.save();
                              //     NetworkUtil _netUtil = new NetworkUtil();
                              //     _netUtil.post(RestDatasource.LOGIN, body: {
                              //       "action": "deliveryboyregistersec",
                              //       "deliveryboy_id": deliveryboy_id,
                              //       "deliveryboy_name": user_first_name,
                              //       "deliveryboy_email": user_email,
                              //     }).then((dynamic res) async {
                              //       if(res["status"] == "yes")
                              //       {
                              //         setState(() => _isLoading = false);
                              //         // FlashHelper.successBar(context, message: res['message']);
                              //         Navigator.of(context).pushNamed("/registertrd",
                              //             arguments: {
                              //               "deliveryboy_mobile" : deliveryboy_mobile,
                              //               "deliveryboy_id" : deliveryboy_id,
                              //             });
                              //       }
                              //       else {
                              //         setState(() => _isLoading = false);
                              //         // FlashHelper.errorBar(context, message: res['message']);
                              //       }
                              //     });
                              //   }
                              // }
                              Fluttertoast.showToast(msg: "Successfully Registered", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: maincolor, fontSize: MediaQuery.of(context).size.width * 0.04);
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("NEXT",
                                    style: TextStyle(
                                        color: Colors.white,fontSize: 14.0,fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.02,
                        ),



                      ],
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

  String validateMiddleName(String value) {
    if (value.length <= 3)
      return 'Name must be greater than 3';
    else
      return null;
  }
  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }


}
