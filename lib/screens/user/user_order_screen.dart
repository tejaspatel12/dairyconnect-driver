import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nooranidairyfarm_deliveryboy/models/every_order.dart';
import 'package:nooranidairyfarm_deliveryboy/models/once_order.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_orders/user_not_subscription_product_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_orders/user_onec_product_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';

class UserOrderScreen extends StatefulWidget {
  final String user_id,user_first_name,user_last_name;
  const UserOrderScreen({Key key, @required this.user_id, @required this.user_first_name, @required this.user_last_name}) : super(key: key);
  // UserNotSubscriptionProductScreenState createState() => UserNotSubscriptionProductScreenState();
  State<UserOrderScreen> createState() => UserOrderScreenState(user_id,user_first_name,user_last_name);
}


class UserOrderScreenState extends State<UserOrderScreen> with SingleTickerProviderStateMixin {
  BuildContext _ctx;
  String user_id,user_first_name,user_last_name;
  UserOrderScreenState(this.user_id,this.user_first_name,this.user_last_name);
  bool _isdataLoading = true;

  // String user_id,user_first_name,user_last_name;

  NetworkUtil _netUtil = new NetworkUtil();
  Future<List<EveryOrderList>> EveryOrderListdata;
  Future<List<EveryOrderList>> EveryOrderListfilterData;

  Future<List<OnceOrderList>> OnceOrderListdata;
  Future<List<OnceOrderList>> OnceOrderListfilterData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 = new GlobalKey<RefreshIndicatorState>();

  TabController _tabController;
  int _currentIndex = 0;
  bool _isLoadData = true;
  bool _isProccessing = false;
  String time_slot,cutoff_time,newdate;
  DateTime dateTime,mordate;

  SharedPreferences prefs;
  _loadPref() async {
    setState(() {

      print("hiii $user_id");
      EveryOrderListdata = _getEveryOrderData();
      EveryOrderListfilterData=EveryOrderListdata;

      OnceOrderListdata = _getOnceOrderData();
      OnceOrderListfilterData=OnceOrderListdata;
      _isdataLoading = false;
    });
  }


  //Load Data
  Future<List<EveryOrderList>> _getEveryOrderData() async
  {
    print("user_id : "+ user_id);
    return _netUtil.post(RestDatasource.GET_DELIVEYBOY,
        body:{
          'action' : "get_my_order",
          'user_id' : user_id,
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      List<EveryOrderList> listofusers = items.map<EveryOrderList>((json) {
        return EveryOrderList.fromJson(json);
      }).toList();
      List<EveryOrderList> revdata = listofusers.toList();

      return revdata;

    });
  }

  //On Refresh
  Future<List<EveryOrderList>> _refresh1() async
  {
    setState(() {
      EveryOrderListdata = _getEveryOrderData();
      EveryOrderListfilterData=EveryOrderListdata;
    });
  }

  //Load Data
  Future<List<OnceOrderList>> _getOnceOrderData() async
  {
    // print("Click");
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.GET_DELIVEYBOY,
        body:{
          'action' : "get_my_once_order",
          'user_id' : user_id,
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      List<OnceOrderList> listofusers = items.map<OnceOrderList>((json) {
        return OnceOrderList.fromJson(json);
      }).toList();
      List<OnceOrderList> revdata = listofusers.toList();

      return revdata;

    });
  }

  //On Refresh
  Future<List<OnceOrderList>> _refresh2() async
  {
    setState(() {
      OnceOrderListdata = _getOnceOrderData();
      OnceOrderListfilterData=OnceOrderListdata;
    });
  }

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _otpcode;


  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    super.initState();
    dateTime = DateTime.now();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    _loadPref();
  }

  void _handleTabIndex() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }


  @override
  Widget build(BuildContext context) {
    // _ctx = context;
    // setState(() {
    //   _ctx = context;
    //   final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
    //   user_id = arguments['user_id'];
    //   user_first_name = arguments['user_first_name'];
    //   user_last_name = arguments['user_last_name'];
    //   print(user_id);
    //   user_id!=null? _loadPref():null;
    // });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return DefaultTabController(
          length: 2,
          child: new Scaffold(
            backgroundColor: shadecolor,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {

                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState /*You can rename this!*/) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    // color: whitecolor,
                                    // color: blackcolor,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Card(
                                        semanticContainer: true,
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        elevation: 2.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          width : double.infinity, color: maincolor,
                                          child: Column(
                                            children: const <Widget>[
                                              Text("Add Order", style: TextStyle(color: Colors.white,fontSize: 18)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // 24.height,
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      // Text("Delete folder?",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.black,)),
                                      // // 16.height,
                                      // SizedBox(
                                      //   height: 16,
                                      // ),

                                      Padding(
                                        padding: EdgeInsets.only(left: 12, right: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [

                                            GestureDetector(
                                              onTap:()
                                              {
                                                // usernotsubpro

                                                Navigator.pushReplacement(context,
                                                    MaterialPageRoute(
                                                      builder: (context) => UserNotSubscriptionProductScreen(user_id: user_id,user_first_name:user_first_name,user_last_name:user_last_name),
                                                    ));

                                                // Navigator.of(context).pushReplacementNamed("/usernotsubpro",
                                                //     arguments: {
                                                //       "user_id" : user_id,
                                                //       "user_first_name" : user_first_name,
                                                //       "user_last_name" : user_last_name,
                                                //     });
                                              },
                                              child: Card(
                                                semanticContainer: true,
                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                elevation: 2.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                                                  width : double.infinity, color: greencolor,
                                                  child: Column(
                                                    children: const <Widget>[
                                                      Text("Subscription", style: TextStyle(color: Colors.white,fontSize: 14)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(
                                              height: 10,
                                            ),

                                            GestureDetector(
                                              onTap:()
                                              {
                                                Navigator.pushReplacement(context,
                                                    MaterialPageRoute(
                                                      builder: (context) => UserOnecProductScreen(user_id: user_id,user_first_name:user_first_name,user_last_name:user_last_name),
                                                    ));

                                                // usernotsubpro
                                                // Navigator.of(context).pushReplacementNamed("/useronespro",
                                                //     arguments: {
                                                //       "user_id" : user_id,
                                                //       "user_first_name" : user_first_name,
                                                //       "user_last_name" : user_last_name,
                                                //     });
                                              },
                                              child: Card(
                                                semanticContainer: true,
                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                elevation: 2.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                                                  width : double.infinity, color: redcolor,
                                                  child: Column(
                                                    children: const <Widget>[
                                                      Text("One Time", style: TextStyle(color: Colors.white,fontSize: 14)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),

                                      // 16.height,
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top:0.0,
                                  right: 0.0,
                                  child: new IconButton(
                                      icon: Icon(Icons.cancel,color: Colors.red,size: textSizeNormal,),
                                      onPressed: () {
                                        Navigator.pop(context,false);
                                      }),
                                )
                              ],
                            );
                          });
                    });

                // showDialog(
                //     context: context,
                //     builder: (context) => Dialog(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       elevation: 0.0,
                //       backgroundColor: Colors.transparent,
                //       child: Stack(
                //         children: [
                //           Container(
                //             decoration: BoxDecoration(
                //               // color: whitecolor,
                //               color: blackcolor,
                //               shape: BoxShape.rectangle,
                //               borderRadius: BorderRadius.circular(8),
                //               boxShadow: const [
                //                 BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: Offset(0.0, 10.0)),
                //               ],
                //             ),
                //             width: MediaQuery.of(context).size.width,
                //             child: Column(
                //               mainAxisSize: MainAxisSize.min,
                //               children: <Widget>[
                //                 Card(
                //                   semanticContainer: true,
                //                   clipBehavior: Clip.antiAliasWithSaveLayer,
                //                   elevation: 2.0,
                //                   shape: RoundedRectangleBorder(
                //                     borderRadius: BorderRadius.circular(8.0),
                //                   ),
                //                   child: Container(
                //                     padding: EdgeInsets.all(20),
                //                     width : double.infinity, color: maincolor,
                //                     child: Column(
                //                       children: const <Widget>[
                //                         Text("Add Order", style: TextStyle(color: Colors.white,fontSize: 18)),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //                 // 24.height,
                //                 const SizedBox(
                //                   height: 10,
                //                 ),
                //                 // Text("Delete folder?",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.black,)),
                //                 // // 16.height,
                //                 // SizedBox(
                //                 //   height: 16,
                //                 // ),
                //
                //                 Padding(
                //                   padding: EdgeInsets.only(left: 12, right: 12),
                //                   child: Column(
                //                     crossAxisAlignment: CrossAxisAlignment.start,
                //                     mainAxisAlignment: MainAxisAlignment.start,
                //                     children: [
                //
                //                       GestureDetector(
                //                         onTap:()
                //                         {
                //                           // usernotsubpro
                //                           Navigator.of(context).pushReplacementNamed("/usernotsubpro",
                //                               arguments: {
                //                                 "user_id" : user_id,
                //                                 "user_first_name" : user_first_name,
                //                                 "user_last_name" : user_last_name,
                //                               });
                //                         },
                //                         child: Card(
                //                           semanticContainer: true,
                //                           clipBehavior: Clip.antiAliasWithSaveLayer,
                //                           elevation: 2.0,
                //                           shape: RoundedRectangleBorder(
                //                             borderRadius: BorderRadius.circular(10.0),
                //                           ),
                //                           child: Container(
                //                             padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                //                             width : double.infinity, color: greencolor,
                //                             child: Column(
                //                               children: const <Widget>[
                //                                 Text("Subscription", style: TextStyle(color: Colors.white,fontSize: 14)),
                //                               ],
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                       Card(
                //                         semanticContainer: true,
                //                         clipBehavior: Clip.antiAliasWithSaveLayer,
                //                         elevation: 2.0,
                //                         shape: RoundedRectangleBorder(
                //                           borderRadius: BorderRadius.circular(10.0),
                //                         ),
                //                         child: Container(
                //                           padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                //                           width : double.infinity, color: redcolor,
                //                           child: Column(
                //                             children: const <Widget>[
                //                               Text("One Time", style: TextStyle(color: Colors.white,fontSize: 14)),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //
                //                     ],
                //                   ),
                //                 ),
                //
                //                 // 16.height,
                //                 const SizedBox(
                //                   height: 15,
                //                 ),
                //               ],
                //             ),
                //           ),
                //           Positioned(
                //             top:0.0,
                //             right: 0.0,
                //             child: new IconButton(
                //                 icon: Icon(Icons.cancel,color: Colors.red,size: textSizeNormal,),
                //                 onPressed: () {
                //                   Navigator.pop(context,false);
                //                 }),
                //           )
                //         ],
                //       ),
                //     )
                // );
              },
              label: const Text('Add Order',style: TextStyle(color: whitecolor),),
              icon: const Icon(Icons.add,color: whitecolor,),
              backgroundColor: maincolor,
            ),
            body: new NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  new SliverAppBar(
                    title: Text("$user_first_name $user_last_name Orders"),
                    pinned: true,
                    floating: true,
                    centerTitle: true,
                    backgroundColor: maincolor,
                    forceElevated: innerBoxIsScrolled,
                    bottom: new TabBar(
                      indicatorColor: whitecolor,
                      controller: _tabController,
                      tabs: <Tab>[
                        new Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Subsciption",
                              style: TextStyle(
                                  color: _tabController.index == 0
                                      ? whitecolor
                                      : whitecolor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        new Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "One Time",
                              style: TextStyle(
                                  color: _tabController.index == 1
                                      ? whitecolor
                                      : whitecolor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: new TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // (_isdataLoading)
                  //     ? new Center(
                  //   child: Lottie.asset(
                  //     'assets/loading.json',
                  //     repeat: true,
                  //     reverse: true,
                  //     animate: true,
                  //   ),
                  //
                  // ):
                  // (_isLoadData)
                  //     ? new Center(
                  //   child: Lottie.asset(
                  //     'assets/loading.json',
                  //     repeat: true,
                  //     reverse: true,
                  //     animate: true,
                  //   ),
                  //
                  // ):
                  Stack(
                    children: <Widget>[
                      RefreshIndicator(
                        key: _refreshIndicatorKey,
                        color: maincolor,
                        onRefresh: _refresh1,
                        child: FutureBuilder<List<EveryOrderList>>(
                          future: EveryOrderListdata,
                          builder: (context,snapshot) {
                            if ((snapshot).connectionState == ConnectionState.waiting)
                            {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/load.json',
                                      repeat: true,
                                      reverse: true,
                                      animate: true,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("Please Wait..."),
                                  ],
                                ),
                              );
                            }
                            else if (!snapshot.hasData) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/opps.json',
                                      repeat: true,
                                      reverse: true,
                                      animate: true,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("No Data Available!"),
                                  ],
                                ),
                              );
                            }
                            return ListView(
                              padding: EdgeInsets.only(top: 5),
                              children: snapshot.data
                                  .map((data) =>

                                  // Container(
                                  //   color: maincolor,
                                  //   height: 100,
                                  // ),

                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                        ),
                                        border: Border.all(
                                          color: maincolor,
                                          width: 1,
                                        ),
                                        color: whitecolor
                                        // gradient: LinearGradient(
                                        //   begin: Alignment.topLeft,
                                        //   end: Alignment.bottomRight,
                                        //   colors:
                                        //   [
                                        //
                                        //     Color(0xFF0E50F6).withOpacity(1),
                                        //     Color(0xFF0E50F6).withOpacity(0.5),
                                        //     // Color(0xFFFFFFFF).withOpacity(0.2),
                                        //     // Color(0xFF0E50F6).withOpacity(0.3),
                                        //   ],
                                        //   stops: [0.1, 2],),
                                      ),

                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 90, height: 90,)):ClipOval(child: new Image.asset('images/logo.png', width: 90, height: 90,)),
                                                SizedBox(
                                                  width: spacing_standard,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  // mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [

                                                    Text(data.product_name, style: TextStyle(color: maincolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                                                    SizedBox(
                                                      height: spacing_standard,
                                                    ),

                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(5.0),
                                                          topRight: Radius.circular(5.0),
                                                          bottomLeft: Radius.circular(5.0),
                                                          bottomRight: Radius.circular(5.0),
                                                        ),
                                                        color: maincolor,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                                        child: new Text(
                                                          data.delivery_schedule.toUpperCase(),
                                                          style: new TextStyle(
                                                            color: whitecolor,
                                                            fontSize: spacing_middle,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      height: spacing_standard,
                                                    ),


                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(5.0),
                                                          topRight: Radius.circular(5.0),
                                                          bottomLeft: Radius.circular(5.0),
                                                          bottomRight: Radius.circular(5.0),
                                                        ),
                                                        color: greencolor,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                                        child: new Text(
                                                              data.ds_qty==null?"":"Quantity :  "+data.ds_qty,
                                                          style: new TextStyle(
                                                            color: whitecolor,
                                                            fontSize: spacing_middle,
                                                          ),
                                                        ),
                                                      ),
                                                    ),


                                                    // SizedBox(
                                                    //   height: spacing_standard,
                                                    // ),
                                                    //
                                                    // data.order_ring_bell=="1"?Container(
                                                    //   decoration: BoxDecoration(
                                                    //     borderRadius: BorderRadius.only(
                                                    //       topLeft: Radius.circular(5.0),
                                                    //       topRight: Radius.circular(5.0),
                                                    //       bottomLeft: Radius.circular(5.0),
                                                    //       bottomRight: Radius.circular(5.0),
                                                    //     ),
                                                    //     color: shadecolor, //
                                                    //   ),
                                                    //   child: Padding(
                                                    //     padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                    //     child: Icon(Icons.notifications,size:textSizeLargeMedium,color: maincolor,),
                                                    //   ),
                                                    // ):
                                                    // Container(
                                                    //   decoration: BoxDecoration(
                                                    //     borderRadius: BorderRadius.only(
                                                    //       topLeft: Radius.circular(5.0),
                                                    //       topRight: Radius.circular(5.0),
                                                    //       bottomLeft: Radius.circular(5.0),
                                                    //       bottomRight: Radius.circular(5.0),
                                                    //     ),
                                                    //     color: shadecolor, //
                                                    //   ),
                                                    //   child: Padding(
                                                    //     padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                    //     child: Icon(Icons.notifications_off,size:textSizeLargeMedium,color:redcolor,),
                                                    //   ),
                                                    // ),

                                                  ],
                                                ),


                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),


                              ).toList(),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  Stack(
                    children: <Widget>[

                      // Container(height: 100,color: maincolor,)
                      RefreshIndicator(
                        key: _refreshIndicatorKey2,
                        color: maincolor,
                        onRefresh: _refresh2,
                        child: FutureBuilder<List<OnceOrderList>>(
                          future: OnceOrderListdata,
                          builder: (context,snapshot) {
                            if ((snapshot).connectionState == ConnectionState.waiting)
                            {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/load.json',
                                      repeat: true,
                                      reverse: true,
                                      animate: true,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("Please Wait..."),
                                  ],
                                ),
                              );
                            }
                            else if (!snapshot.hasData) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/opps.json',
                                      repeat: true,
                                      reverse: true,
                                      animate: true,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("No Data Available!"),
                                  ],
                                ),
                              );
                            }
                            return ListView(
                              padding: EdgeInsets.only(top: 5),
                              children: snapshot.data
                                  .map((data) =>

                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                        ),
                                        border: Border.all(
                                          color: maincolor,
                                          width: 1,
                                        ),
                                        color: whitecolor
                                        // gradient: LinearGradient(
                                        //   begin: Alignment.topLeft,
                                        //   end: Alignment.bottomRight,
                                        //   colors:
                                        //   [
                                        //
                                        //     Color(0xFF0E50F6).withOpacity(1),
                                        //     Color(0xFF0E50F6).withOpacity(0.5),
                                        //     // Color(0xFFFFFFFF).withOpacity(0.2),
                                        //     // Color(0xFF0E50F6).withOpacity(0.3),
                                        //   ],
                                        //   stops: [0.1, 2],),
                                      ),

                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 90, height: 90,)):ClipOval(child: new Image.asset('images/logo.png', width: 90, height: 90,)),
                                            SizedBox(
                                              width: spacing_standard,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                Text(data.product_name, style: TextStyle(color: maincolor,fontSize: textSizeSMedium,fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                                                SizedBox(
                                                  height: spacing_standard,
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0),
                                                    ),
                                                    color: maincolor,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                                    child: new Text(
                                                      data.start_date,
                                                      style: new TextStyle(
                                                        color: whitecolor,
                                                        fontSize: spacing_middle,
                                                      ),
                                                    ),
                                                  ),
                                                ),


                                                SizedBox(
                                                  height: spacing_standard,
                                                ),

                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0),
                                                    ),
                                                    color: greencolor,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                                    child: new Text(
                                                      data.order_qty==null?"":"Quantity :  "+data.order_qty,
                                                      style: new TextStyle(
                                                        color: whitecolor,
                                                        fontSize: spacing_middle,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // data.order_ring_bell=="1"?
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     borderRadius: BorderRadius.only(
                                                //       topLeft: Radius.circular(5.0),
                                                //       topRight: Radius.circular(5.0),
                                                //       bottomLeft: Radius.circular(5.0),
                                                //       bottomRight: Radius.circular(5.0),
                                                //     ),
                                                //     color: shadecolor, //
                                                //   ),
                                                //   child: Padding(
                                                //     padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                //     child: Icon(Icons.notifications,size:textSizeLargeMedium,color: maincolor,),
                                                //   ),
                                                // ):
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     borderRadius: BorderRadius.only(
                                                //       topLeft: Radius.circular(5.0),
                                                //       topRight: Radius.circular(5.0),
                                                //       bottomLeft: Radius.circular(5.0),
                                                //       bottomRight: Radius.circular(5.0),
                                                //     ),
                                                //     color: shadecolor, //
                                                //   ),
                                                //   child: Padding(
                                                //     padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                //     child: Icon(Icons.notifications_off,size:textSizeLargeMedium,color:redcolor,),
                                                //   ),
                                                // ),

                                              ],
                                            ),


                                          ],
                                        ),
                                      ),
                                    ),
                                  ),


                              ).toList(),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}