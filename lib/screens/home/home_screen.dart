import 'dart:async';

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';

class HomeScreen extends StatefulWidget {
  // const HomeScreen({Key key, @required this.selected_time}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selected_time;

  // _HomeScreenState(this.selected_time);

  BuildContext _ctx;
  int counter = 0;
  int _current = 0;
  String all_order="0",all_user="0",time_slot,total_pouch,deliveryboy_name,final_time;
  // String deliveryboy_area1;
  DateTime currentDate;
  // Map<String, double> dataMap = Map();

  bool _isLoading = false;
  bool _isdataLoading = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String deliveryboy_id,theme;

  SharedPreferences prefs;
  NetworkUtil _netUtil = new NetworkUtil();


  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      // selected_time = "Evening Batch";
      deliveryboy_id = prefs.getString("deliveryboy_id") ?? '';
      selected_time = prefs.getString("selected_time") ?? '';
      theme= prefs.getString("theme") ?? '';
      _netUtil.post(RestDatasource.GET_DELIVERYBOY_DASHBOARD, body: {
        "deliveryboy_id": deliveryboy_id,
        "deliveryboy_time": selected_time,
        "date": DateFormat('yyy-MM-d').format(currentDate).toString(),
      }).then((dynamic res) async {
        setState(() {
          // print(res);
          print("1111___here___");
          print(selected_time);
          all_order = res["all_order"].toString();
          all_user = res["all_user"].toString();
          // time_slot = res["time_slot"].toString();
          time_slot = selected_time;
          total_pouch = res["total_pouch"].toString();
          total_pouch == "null"?total_pouch="0":total_pouch;
          print("total_pouch = "+total_pouch);
          deliveryboy_name = res["deliveryboy_name"].toString();
          final_time = res["final_time"].toString();
          // deliveryboy_area1 = res["deliveryboy_area"]["1"] +" "+ res["deliveryboy_area"]["2"]+" ";

          // dataMap.clear();

          // dataMap.putIfAbsent("not_approve_user", () => double.parse(res["not_approve_user"].toString()));

          _isdataLoading = false;
          // _isdataLoading = true;
        });
      });
    });
  }


  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    currentDate = DateTime.now();
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   _ctx = context;
    //   final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
    //   selected_time = arguments['selected_time'];
    //   time_slot = selected_time;
    //   // selected_time != null?_loadPref():null;
    // });
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: statusbarcolor,
          statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      // backgroundColor: theme=="0"?blackcolor:whitecolor,
      backgroundColor: shadecolor,
      drawer: DrawerNavigationBarController(),
      appBar: AppBar(
          centerTitle: true,
          title: new Text(apptitle,style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: maincolor,
          actions: <Widget>[
            new Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Row(
                  children: [

                    new IconButton(icon: Icon(Icons.refresh),color: Colors.white, onPressed: () {
                      _loadPref();
                    }),
                    new IconButton(icon: Icon(Icons.power_settings_new),color: Colors.red, onPressed: () {
                      prefs.remove('selected_time');
                      Navigator.of(context).pushReplacementNamed("/selecttime");
                      Fluttertoast.showToast(msg: "Successfully, Close App", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 22);
                    }),
                    // new IconButton(icon: Icon(Icons.light),color: Colors.white, onPressed: () {
                    //   setState(() async {
                    //     if(theme=="1")
                    //     {
                    //       await prefs.remove(theme);
                    //       // prefs.remove(theme);
                    //       // prefs.remove("theme");
                    //       prefs.setString(theme, "0");
                    //       print("theme : "+theme);
                    //     }
                    //     else
                    //     {
                    //       // prefs.remove("theme");
                    //       prefs.remove(theme);
                    //       prefs.setString(theme, "1");
                    //       print("theme : "+theme);
                    //     }
                    //   });
                    // }),
                  ],
                )
              ],
            ),
          ]
      ),
      body: DoubleBackToCloseApp(
        child: _isdataLoading==true ?
        Center(
          child: Lottie.asset(
            'assets/load.json',
            repeat: true,
            reverse: true,
            animate: true,
          ),
        ):

        Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(top: 10),
              children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    children: [
                      Center(child: Text(DateFormat('d-MMMM-yyy').format(currentDate),maxLines: 1,overflow: TextOverflow.ellipsis, style: TextStyle(color: blackcolor,fontSize: textSizeMedium, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Center(child: Text("Hellow, "+deliveryboy_name.toString(),maxLines: 1,overflow: TextOverflow.ellipsis, style: TextStyle(color: redcolor,fontSize: textSizeMedium, fontWeight: FontWeight.w700, letterSpacing: 0.5,))),
                      SizedBox(
                        height: spacing_middle,
                      ),
                      Center(child: Text(time_slot==""?"":"Your Time Slot is "+time_slot.toString(),maxLines: 1,overflow: TextOverflow.ellipsis, style: TextStyle(color: maincolor,fontSize: textSizeMedium, fontWeight: FontWeight.w700, letterSpacing: 0.1))),
                      // Center(child: Text(final_time==""?"":final_time.toString(),maxLines: 1,overflow: TextOverflow.ellipsis, style: TextStyle(color: maincolor,fontSize: textSizeMedium, fontWeight: FontWeight.w700, letterSpacing: 0.1))),
//                   SizedBox(v
//                     height: spacing_middle,
//                   ),
//                   Center(child: Text(deliveryboy_area1==""?"":"Your Delivery Area is "+deliveryboy_area1.toString(), style: TextStyle(color: redcolor,fontSize: textSizeMMedium, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
                      SizedBox(
                        height: spacing_large,
                      ),

                      InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed("/order");
                        },
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
                                Color(0xFF6A3DE8).withOpacity(0.5),
                                Color(0xFF6A3DE8).withOpacity(1),
                                // Color(0xFFFFFFFF).withOpacity(0.2),
                              ],
                              stops: [0.1, 2],),

                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(all_order, style: TextStyle(fontSize: 25,color:whitecolor,letterSpacing: 0.5,fontWeight: FontWeight.w600),),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text("Today Orders", style: TextStyle(fontSize: 16,color:whitecolor),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0),
                                        topLeft: Radius.circular(30.0),
                                        bottomLeft: Radius.circular(30.0)),
                                    color: maincolor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(
                                      Icons.reorder,
                                      size: 30.0,color: whitecolor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: spacing_large,
                      ),

                      InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed("/inventory");
                        },
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

                                Color(0xFF6A3DE8).withOpacity(1),
                                Color(0xFF6A3DE8).withOpacity(0.5),
                                // Color(0xFFFFFFFF).withOpacity(0.2),
                                // Color(0xFF0E50F6).withOpacity(0.3),
                              ],
                              stops: [0.1, 2],),

                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(total_pouch, style: TextStyle(fontSize: 25,color:whitecolor,letterSpacing: 0.5,fontWeight: FontWeight.w600),),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text("Today Inventory", style: TextStyle(fontSize: 16,color:whitecolor),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0),
                                        topLeft: Radius.circular(30.0),
                                        bottomLeft: Radius.circular(30.0)),
                                    color: maincolor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(
                                      Icons.inventory,
                                      size: 30.0,color: whitecolor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: spacing_large,
                      ),

                      InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed("/user");
                        },
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
                                // Color(0xFF0E50F6).withOpacity(0.3),
                                // Color(0xFFFFFFFF).withOpacity(0.2),
                                Color(0xFF6A3DE8).withOpacity(0.5),
                                Color(0xFF6A3DE8).withOpacity(1),
                              ],
                              stops: [0.1, 2],),

                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(all_user, style: TextStyle(fontSize: 25,color:whitecolor,letterSpacing: 0.5,fontWeight: FontWeight.w600),),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text("All Users", style: TextStyle(fontSize: 16,color:whitecolor),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0),
                                        topLeft: Radius.circular(30.0),
                                        bottomLeft: Radius.circular(30.0)),
                                    color: maincolor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(
                                      Icons.person,
                                      size: 30.0,color: whitecolor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      // SizedBox(
                      //   height: spacing_large,
                      // ),
                      //
                      // InkWell(
                      //   onTap: (){
                      //     Navigator.of(context).pushNamed("/json");
                      //   },
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20.0),
                      //           bottomRight: Radius.circular(20.0),
                      //           topLeft: Radius.circular(20.0),
                      //           bottomLeft: Radius.circular(20.0)),
                      //
                      //       gradient: LinearGradient(
                      //         begin: Alignment.topLeft,
                      //         end: Alignment.bottomRight,
                      //         colors:
                      //         [
                      //           Color(0xFFFFFFFF).withOpacity(0.2),
                      //           Color(0xFF0E50F6).withOpacity(0.3),
                      //         ],
                      //         stops: [0.1, 2],),
                      //
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: <Widget>[
                      //         Padding(
                      //           padding: const EdgeInsets.all(20.0),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Text(total_pouch, style: TextStyle(fontSize: 25,color:whitecolor,letterSpacing: 0.5,fontWeight: FontWeight.w600),),
                      //               SizedBox(
                      //                 height: 12,
                      //               ),
                      //               Text("json".toUpperCase(), style: TextStyle(fontSize: 16,color:whitecolor),),
                      //             ],
                      //           ),
                      //         ),
                      //         Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Container(
                      //             decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.only(
                      //                   topRight: Radius.circular(30.0),
                      //                   bottomRight: Radius.circular(30.0),
                      //                   topLeft: Radius.circular(30.0),
                      //                   bottomLeft: Radius.circular(30.0)),
                      //               color: maincolor,
                      //             ),
                      //             child: Padding(
                      //               padding: const EdgeInsets.all(10.0),
                      //               child: Icon(
                      //                 Icons.inventory,
                      //                 size: 30.0,color: whitecolor,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),









                      // Stack(
                      //   children: [
                      //     GlassmorphicContainer(
                      //       height: 350,
                      //       borderRadius: 20,
                      //       blur: 20,
                      //       alignment: Alignment.bottomCenter,
                      //       border: 2,
                      //       linearGradient: LinearGradient(
                      //           begin: Alignment.topLeft,
                      //           end: Alignment.bottomRight,
                      //           colors: [
                      //             Color(0xFF0EF6BE).withOpacity(0.3),
                      //             Color(0xFFF44336).withOpacity(0.05),
                      //           ],
                      //           stops: [
                      //             0.1,
                      //             1,
                      //           ]),
                      //       child: null,
                      //     ),
                      //     Positioned(
                      //       top: 0,
                      //       left: 0,
                      //       right: 0,
                      //       child: Image.asset(
                      //         'images/daino.png',
                      //         width: MediaQuery.of(context).size.width * 80,
                      //         height: MediaQuery.of(context).size.height * 0.40,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),

              ],
            ),

            // Column(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //
            //
            //     Row(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       children: [
            //         Flexible(
            //           flex: 2,
            //           child: GestureDetector(
            //             onTap: () {
            //
            //               Fluttertoast.showToast(msg: "Double click to close app", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 22);
            //               // FlashHelper.successBar(context, message: user_id.toString());
            //             },
            //             onDoubleTap: (){
            //
            //               prefs.remove('selected_time');
            //               Navigator.of(context).pushReplacementNamed("/selecttime");
            //               Fluttertoast.showToast(msg: "Successfully, Close App", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 22);
            //
            //             },
            //             child: Container(
            //               decoration: const BoxDecoration(
            //                 borderRadius: BorderRadius.only(
            //                   topLeft: Radius.circular(25.0),
            //                   topRight: Radius.circular(25.0),
            //                   bottomLeft: Radius.circular(25.0),
            //                   bottomRight: Radius.circular(25.0),
            //                 ),
            //                 color: redcolor,
            //               ),
            //               child: Padding(
            //                 padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            //                 child: Icon(Icons.add,color: whitecolor,),
            //               ),
            //             ),
            //           ),
            //         ),
            //         SizedBox(),
            //         Flexible(flex: 8, child: Container())
            //       ],
            //     ),
            //
            //   ],
            // ),
          ],
        ),
        snackBar: const SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Press again to exit app'),
        ),
      ),


    );
  }
}

