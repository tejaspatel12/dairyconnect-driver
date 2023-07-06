import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/models/time_slot.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/home/home_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectTimeSlot extends StatefulWidget {
  const SelectTimeSlot({Key key}) : super(key: key);

  @override
  State<SelectTimeSlot> createState() => _SelectTimeSlotState();
}

class _SelectTimeSlotState extends State<SelectTimeSlot> {
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  String deliveryboy_id="",deliveryboy_name="",deliveryboy_mobile="",greetings="";
  String _timeController;
  String selectedArea = null,_Areatype=null;

  Future<List<TimeSlotList>> TimeSlotListdata;
  Future<List<TimeSlotList>> TimeSlotListfilterData;

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  SharedPreferences prefs;
  NetworkUtil _netUtil = new NetworkUtil();

  _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deliveryboy_id = prefs.getString("deliveryboy_id") ?? '';
      deliveryboy_name = prefs.getString("deliveryboy_name") ?? '';
      deliveryboy_mobile = prefs.getString("deliveryboy_mobile") ?? '';
      print("deliveryboy_id :" +deliveryboy_id);

      TimeSlotListdata = _getAreaData();
      TimeSlotListfilterData=TimeSlotListdata;

    });
  }

  //Area
  Future<List<TimeSlotList>> _getAreaData() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.GET_DELIVEYBOY,
        body:{
          'action': "deliveryboy_timeslot",
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      // print(items);
      List<TimeSlotList> listofusers = items.map<TimeSlotList>((json) {
        return TimeSlotList.fromJson(json);
      }).toList();
      List<TimeSlotList> revdata = listofusers.toList();
      // _isLoading = false;
      return revdata;
    });
  }

  Future<List<TimeSlotList>> _refresh1() async
  {
    setState(() {
      TimeSlotListdata = _getAreaData();
      TimeSlotListfilterData=TimeSlotListdata;
    });
  }


  greeting() {
    var hour = DateTime.now().hour;
    setState(() {
    if (hour < 12) {
      greetings = "Good Morning,";
    }
    if (hour < 17) {
      greetings = "Good Afternoon,";
    }
    greetings = "Good Evening,";
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
    _loadPref();
    greeting();
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
        backgroundColor: shadecolor,
        body:SafeArea(
          child:
          (_isLoading==true) ?Center(
            child: Lottie.asset(
              'assets/load.json',
              repeat: true,
              reverse: true,
              animate: true,
            ),
          ):Stack(
            children: [
              Center(
                child: Image.asset(
                  // 'images/logo.png',
                  'images/logo_bg.png',
                  // 'images/apple.png',
                  width: MediaQuery.of(context).size.width * 80,
                  height: MediaQuery.of(context).size.height * 0.20,
                ),
              ),

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
                      color: whitecolor,


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


                                Text(greetings==""?"":greetings, style: TextStyle(color: maincolor,fontSize: textSizeNormal,fontWeight: FontWeight.w600),),
                                Text(deliveryboy_name==null?"":deliveryboy_name, style: TextStyle(color: redcolor,fontSize: textSizeNormal,fontWeight: FontWeight.w600),),

                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.06,
                                ),

                                FutureBuilder<List<TimeSlotList>>(
                                  future: _getAreaData(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return Center(
                                          child: CircularProgressIndicator());
                                    return DropdownButtonFormField(
                                        isExpanded: true,
                                        // hint: Text("Select Main Category", maxLines: 1),
                                        value: selectedArea,
                                        // validator: validatebird,
                                        items: snapshot.data.map((
                                            data) {
                                          return DropdownMenuItem(
                                            child: Text(
                                                data.time_slot_name +" ("+ data.time_slot_cutoff_time +")"),
                                            value: data.time_slot_name.toString(),
                                          );
                                        }).toList(),
                                        onChanged: (newVal) {
                                          setState(() {
                                            _Areatype = newVal;
                                            selectedArea = newVal;
                                          });
                                        },
                                        decoration:const InputDecoration(
                                          hintText: 'Select Delivery Time',
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
                                          fillColor: whitecolor,
                                          contentPadding: EdgeInsets.all(13),));
                                  },
                                ),


                                // DropdownButtonFormField<String>(
                                //   autofocus: true,
                                //   value: _timeController,
                                //   items: ["Morning Batch ( 09:00 )", "Evening Batch ( 17:00 )"]
                                //       .map((label) => DropdownMenuItem(
                                //     child: Text(label.toString()),
                                //     value: label,
                                //   ))
                                //       .toList(),
                                //   decoration:const InputDecoration(
                                //     hintText: 'Select Delivery Time',
                                //     labelStyle: TextStyle(color: maincolor),
                                //     focusedBorder: OutlineInputBorder(
                                //         borderSide: BorderSide(
                                //             width: 2, color: maincolor
                                //         )
                                //     ),
                                //     border: OutlineInputBorder(
                                //         borderSide: BorderSide()
                                //     ),
                                //     filled: true,
                                //     contentPadding: EdgeInsets.all(13),),
                                //   onChanged: (value) {
                                //     setState(() {
                                //       _timeController = value;
                                //     });
                                //   },
                                // ),
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
                                    onTap: () async {
                                      if(selectedArea==null)
                                      {
                                        Fluttertoast.showToast(msg: "Please Select Time Slot", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                                      }
                                      else
                                      {
                                        Fluttertoast.showToast(msg: selectedArea, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);

                                        // Navigator.of(context).pushReplacementNamed("/bottomhome",
                                        // arguments: {
                                        //   "selected_time" : selectedArea,
                                        // });
                                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.setString("selected_time", selectedArea);
                                        Navigator.of(context).pushReplacementNamed("/bottomhome");

                                        // Navigator.push(context,
                                        //     MaterialPageRoute(
                                        //       builder: (context) => HomeScreen(selected_time: selectedArea,),
                                        //     ));
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
                                      child: Text("Let's Get Started",style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
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
                                      child: Text("".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
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
                ],
              ),
            ],
          ),


        ),

      );
    }
  }
}
