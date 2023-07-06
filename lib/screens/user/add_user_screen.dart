import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nooranidairyfarm_deliveryboy/models/area.dart';
import 'package:nooranidairyfarm_deliveryboy/models/time_slot.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';


class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}


class _AddUserScreenState extends State<AddUserScreen> {
  BuildContext _ctx;
  int counter = 0;  String user_mobile_number,user_id,user_first_name,user_last_name,user_email,area,user_pass,user_address;

  bool _isLoading = false;
  bool _isdataLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String deliveryboy_id, timeController,area_namecontroller;

  TextEditingController user_first_name_namecontroller = new TextEditingController();
  TextEditingController user_last_name_namecontroller = new TextEditingController();
  TextEditingController user_email_namecontroller = new TextEditingController();
  

  SharedPreferences prefs;
  NetworkUtil _netUtil = new NetworkUtil();

  // String selectedArea = null,_Areatype=null;
  // String selectedTime = null,_Timetype=null;

  // String selectedState = null,_Statetype=null;
  // String selectedCity = null,_Citytype=null;

  // Future<List<AreaList>> AreaListdata;
  // Future<List<AreaList>> AreaListfilterData;
  //
  // Future<List<TimeSlotList>> TimeSlotListdata;
  // Future<List<TimeSlotList>> TimeSlotListfilterData;

  // Future<List<AreaList>> AreaListdata;
  // Future<List<AreaList>> AreaListfilterData;
  //
  // Future<List<TimeSlotList>> TimeSlotListdata;
  // Future<List<TimeSlotList>> TimeSlotListfilterData;

  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 = new GlobalKey<RefreshIndicatorState>();
  // final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 = new GlobalKey<RefreshIndicatorState>();

  _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deliveryboy_id = prefs.getString("deliveryboy_id") ?? '';
      print("deliveryboy_id :" +deliveryboy_id);

      // AreaListdata = _getStateData();
      // AreaListfilterData=AreaListdata;
      //
      // TimeSlotListdata = _getCityData();
      // TimeSlotListfilterData=TimeSlotListdata;

    });
  }

  // //State
  // Future<List<AreaList>> _getStateData() async
  // {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   return _netUtil.post(RestDatasource.LOCATION,
  //       body:{
  //         'action': "show_area",
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
  // Future<List<AreaList>> _refresh1() async
  // {
  //   setState(() {
  //     AreaListdata = _getStateData();
  //     AreaListfilterData=AreaListdata;
  //   });
  // }
  //
  // //City
  // Future<List<TimeSlotList>> _getCityData() async
  // {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   return _netUtil.post(RestDatasource.GET_DELIVEYBOY,
  //       body:{
  //     'action': "deliveryboy_timeslot",
  //       }).then((dynamic res)
  //   {
  //     final items = res.cast<Map<String, dynamic>>();
  //     // print(items);
  //     List<TimeSlotList> listofusers = items.map<TimeSlotList>((json) {
  //       return TimeSlotList.fromJson(json);
  //     }).toList();
  //     List<TimeSlotList> revdata = listofusers.toList();
  //
  //     return revdata;
  //   });
  // }
  //
  // Future<List<TimeSlotList>> _refresh2() async
  // {
  //   setState(() {
  //     TimeSlotListdata = _getCityData();
  //     TimeSlotListfilterData=TimeSlotListdata;
  //   });
  // }
  
  
  // //Area
  // Future<List<AreaList>> _getAreaData() async
  // {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   return _netUtil.post(RestDatasource.LOCATION,
  //       body:{
  //         'action': "show_area",
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
  //
  //
  // //Area
  // Future<List<TimeSlotList>> _getTimeData() async
  // {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   return _netUtil.post(RestDatasource.GET_DELIVEYBOY,
  //       body:{
  //         'action': "deliveryboy_timeslot",
  //       }).then((dynamic res)
  //   {
  //     final items = res.cast<Map<String, dynamic>>();
  //     // print(items);
  //     List<TimeSlotList> listofusers = items.map<TimeSlotList>((json) {
  //       return TimeSlotList.fromJson(json);
  //     }).toList();
  //     List<TimeSlotList> revdata = listofusers.toList();
  //     // _isLoading = false;
  //     return revdata;
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

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: statusbarcolor,
          statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      // backgroundColor: blackcolor,
      appBar: AppBar(
          centerTitle: true,
          title: new Text("Add User",style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: maincolor,
      ),
      body: _isdataLoading==true ?
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
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [

                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),

                      TextFormField(
                          initialValue: null,
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          // onChanged: (val){
                          //   setState(() {
                          //     user_first_name = val;
                          //   });
                          // },

                          onSaved: (val){
                            setState(() {
                              user_first_name = val;
                            });
                          },
                          validator: validateMiddleName,
                          decoration: const InputDecoration(

                            // labelText: 'Enter Your Mobile Number',
                              hintText: 'Enter User First Name',
                              labelStyle: TextStyle(color: maincolor),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: maincolor
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(15))),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),

                      //LNAME
                      TextFormField(
                          initialValue: null,
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          // onChanged: (val){
                          //   setState(() {
                          //     user_last_name = val;
                          //   });
                          // },
                          onSaved: (val){
                            setState(() {
                              user_last_name = val;
                            });
                          },

                          validator: validateMiddleName,
                          decoration: const InputDecoration(

                            // labelText: 'Enter Your Mobile Number',
                              hintText: 'Enter User Last Name',
                              labelStyle: TextStyle(color: maincolor),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: maincolor
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(15))),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),

                      //MAIL
                      TextFormField(
                          initialValue: null,
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          // onChanged: (val){
                          //   setState(() {
                          //     user_email = val;
                          //   });
                          // },
                          onSaved: (val){
                            setState(() {
                              user_email = val;
                            });
                          },

                          decoration: const InputDecoration(
                              hintText: 'Enter User Email Address',
                              labelStyle: TextStyle(color: maincolor),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: maincolor
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(15))),

                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),

                      //PASS
                      TextFormField(
                          initialValue: null,
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          // onChanged: (val){
                          //   setState(() {
                          //     user_mobile_number = val;
                          //   });
                          // },

                          onSaved: (val){
                            setState(() {
                              user_mobile_number = val;
                            });
                          },

                          validator: validateMobile,
                          decoration: const InputDecoration(
                              hintText: 'Enter User Mobile Number',
                              labelStyle: TextStyle(color: maincolor),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: maincolor
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(15))),

                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),

                      //PASS
                      TextFormField(
                          initialValue: null,
                          obscureText: false,
                          keyboardType: TextInputType.visiblePassword,
                          // onChanged: (val){
                          //   setState(() {
                          //     user_pass = val;
                          //   });
                          // },
                          onSaved: (val){
                            setState(() {
                              user_pass = val;
                            });
                          },

                          validator: validatePassword,
                          decoration: const InputDecoration(
                              hintText: 'Create User Password',
                              labelStyle: TextStyle(color: maincolor),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: maincolor
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(15))),

                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),

                      //AREA

                      // FutureBuilder<List<AreaList>>(
                      //   future: _getStateData(),
                      //   builder: (context, snapshot) {
                      //     if (!snapshot.hasData)
                      //       return Center(
                      //           child: CircularProgressIndicator());
                      //     return DropdownButtonFormField(
                      //         isExpanded: true,
                      //         // hint: Text("Select Main Category", maxLines: 1),
                      //         value: selectedState,
                      //         // validator: validatebird,
                      //         items: snapshot.data.map((
                      //             data) {
                      //           return new DropdownMenuItem(
                      //             child: new Text(
                      //                 data.area_name),
                      //             value: data.area_id.toString(),
                      //           );
                      //         }).toList(),
                      //         onChanged: (newVal) {
                      //           setState(() {
                      //             _Statetype = newVal;
                      //             selectedState = newVal;
                      //           });
                      //         },
                      //         decoration:const InputDecoration(
                      //           hintText: 'Select Area',
                      //           labelStyle: TextStyle(color: maincolor),
                      //           focusedBorder: OutlineInputBorder(
                      //               borderSide: BorderSide(
                      //                   width: 2, color: maincolor
                      //               )
                      //           ),
                      //           border: OutlineInputBorder(
                      //               borderSide: BorderSide()
                      //           ),
                      //           filled: true,
                      //           contentPadding: EdgeInsets.all(13),));
                      //   },
                      // ),


                      DropdownButtonFormField<String>(
                        value: area_namecontroller,
                        items: ["Rander", "Sagrampura", "Shapor"]
                            .map((label) => DropdownMenuItem(
                          child: Text(label.toString()),
                          value: label,
                        ))
                            .toList(),
                        decoration:const InputDecoration(
                          hintText: 'Select Area',
                          labelStyle: TextStyle(color: maincolor),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: maincolor
                              )
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide()
                          ),
                          filled: true,
                          contentPadding: EdgeInsets.all(13),),
                        onChanged: (value) {
                          setState(() {
                            area_namecontroller = value;
                          });
                        },
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),


                      // FutureBuilder<List<TimeSlotList>>(
                      //   future: _getCityData(),
                      //   builder: (context, snapshot) {
                      //     if (!snapshot.hasData)
                      //       return Center(
                      //           child: CircularProgressIndicator());
                      //     return DropdownButtonFormField(
                      //         isExpanded: true,
                      //         // hint: Text("Select Main Category", maxLines: 1),
                      //         value: selectedCity,
                      //         // validator: validatebird,
                      //         items: snapshot.data.map((
                      //             data) {
                      //           return new DropdownMenuItem(
                      //             child: new Text(
                      //                 data.time_slot_name),
                      //             value: data.time_slot_id.toString(),
                      //           );
                      //         }).toList(),
                      //         onChanged: (newVal) {
                      //           setState(() {
                      //             _Citytype = newVal;
                      //             selectedCity = newVal;
                      //           });
                      //         },
                      //         decoration:const InputDecoration(
                      //           hintText: 'Select Time',
                      //           labelStyle: TextStyle(color: maincolor),
                      //           focusedBorder: OutlineInputBorder(
                      //               borderSide: BorderSide(
                      //                   width: 2, color: maincolor
                      //               )
                      //           ),
                      //           border: OutlineInputBorder(
                      //               borderSide: BorderSide()
                      //           ),
                      //           filled: true,
                      //           contentPadding: EdgeInsets.all(13),));
                      //   },
                      // ),

                      DropdownButtonFormField<String>(
                        value: timeController,
                        items: ["Morning Batch", "Evening Batch"]
                            .map((label) => DropdownMenuItem(
                          child: Text(label.toString()),
                          value: label,
                        ))
                            .toList(),
                        decoration:const InputDecoration(
                          hintText: 'Select Time',
                          labelStyle: TextStyle(color: maincolor),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: maincolor
                              )
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide()
                          ),
                          filled: true,
                          contentPadding: EdgeInsets.all(13),),
                        onChanged: (value) {
                          setState(() {
                            timeController = value;
                          });
                        },
                      ),


                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),

                      TextFormField(
                          initialValue: null,
                          obscureText: false,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          // onChanged: (val){
                          //   setState(() {
                          //     user_address = val;
                          //   });
                          // },

                          onSaved: (val){
                            setState(() {
                              user_address = val;
                            });
                          },
                          decoration: const InputDecoration(
                              hintText: 'Enter Your Address',
                              labelStyle: TextStyle(color: maincolor),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: maincolor
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(15))),
                    ],
                  ),
                ),
              ),

            ],
          ),

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
                        padding: const EdgeInsets.fromLTRB(25,0, 25, 15),
                        child:
                        _isLoading!=true?
                        InkWell(
                          onTap: () {

                            if(area_namecontroller==null)
                            {
                              Fluttertoast.showToast(msg: "Please Select Area", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                            }
                            else if(deliveryboy_id==null)
                            {
                              Fluttertoast.showToast(msg: "Deliveryboy ID", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                            }
                            else if(timeController==null)
                            {
                              Fluttertoast.showToast(msg: "Please Select Delivery Time", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                            }
                            else
                            {
                              Fluttertoast.showToast(msg: "Time : "+timeController, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);

                              if (_isLoading == false) {
                                final form = formKey.currentState;
                                if (form.validate()) {
                                  setState(() => _isLoading = true);
                                  form.save();
                                  NetworkUtil _netUtil = new NetworkUtil();
                                  _netUtil.post(RestDatasource.GET_DELIVEYBOY, body: {
                                    "action": "add_user_deliveryboy",
                                    "user_first_name": user_first_name,
                                    "user_last_name": user_last_name,
                                    "user_email": user_email,
                                    "user_pass": user_pass,
                                    "user_address": user_address,
                                    "user_mobile_number": user_mobile_number,
                                    "deliveryboy_id": deliveryboy_id,
                                    "delivery_time": timeController,
                                    "delivery_area": area_namecontroller.toString(),
                                  }).then((dynamic res) async {
                                    if(res["status"] == "yes")
                                    {
                                      setState(() => _isLoading = false);
                                      Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: maincolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                                      Navigator.of(context).pushReplacementNamed("/user");
                                    }
                                    else {
                                      setState(() => _isLoading = false);
                                      Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);

                                    }
                                  });
                                }
                              }
                            }
                            // FlashHelper.successBar(context, message: user_id.toString());
                          },

                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                                topRight: Radius.circular(5.0),
                                bottomLeft: Radius.circular(5.0),
                                bottomRight: Radius.circular(5.0),
                              ),
                              color: maincolor,
                            ),
                            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                            alignment: Alignment.center,
                            child: Text("Add User".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                          ),
                        ):
                        InkWell(
                          onTap: () {

                            Fluttertoast.showToast(msg: "Please Wait", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                            // FlashHelper.successBar(context, message: user_id.toString());
                          },

                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                                topRight: Radius.circular(5.0),
                                bottomLeft: Radius.circular(5.0),
                                bottomRight: Radius.circular(5.0),
                              ),
                              color: maincolor,
                            ),
                            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                            alignment: Alignment.center,
                            child: Text("Please Wait".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
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

  String validateMiddleName(String value) {
    if (value.length <= 3)
      return 'Name must be greater than 3';
    else
      return null;
  }
  String validateArea(String value) {
    if (value.length == null)
      return 'Please Enter Area';
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
  String validateMobile(String value) {
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }
  String validatePassword(String value) {
    if (value.length < 5)
      return 'Password must be 5 alphanumeric characters in length';
    else
      return null;
  }

}
