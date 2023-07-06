import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nooranidairyfarm_deliveryboy/models/payment.dart';
import 'package:nooranidairyfarm_deliveryboy/models/user_order_log.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';
import 'package:skeleton_text/skeleton_text.dart';

class UserBalanceListScreen extends StatefulWidget {
  final String user_id,user_first_name,user_last_name,user_balance;
  const UserBalanceListScreen({Key key, @required this.user_id, @required this.user_first_name, @required this.user_last_name, @required this.user_balance}) : super(key: key);
  // UserNotSubscriptionProductScreenState createState() => UserNotSubscriptionProductScreenState();
  State<UserBalanceListScreen> createState() => _UserBalanceListScreenState(user_id,user_first_name,user_last_name,user_balance);

  // _UserBalanceListScreenState createState() => _UserBalanceListScreenState();
}

class _UserBalanceListScreenState extends State<UserBalanceListScreen> with SingleTickerProviderStateMixin{
  BuildContext _ctx;
  String user_id,user_first_name,user_last_name,user_balance;

  _UserBalanceListScreenState(this.user_id,this.user_first_name,this.user_last_name,this.user_balance);

  RestDatasource api = new RestDatasource();
  NetworkUtil _netUtil = new NetworkUtil();
  String loggedinname = "";
  String deliveryboy_id;

  Future<List<PaymentList>> PaymentListdata;
  Future<List<PaymentList>> PaymentListfilterData;

  Future<List<UserOrderLogList>> userdata;
  Future<List<UserOrderLogList>> filterData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 = new GlobalKey<RefreshIndicatorState>();
  bool _isSearching = false;
  bool _isLoading = false;
  String _number;
  int num=0;

  TabController _tabController;
  int _currentIndex = 0;

  _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    deliveryboy_id= prefs.getString("deliveryboy_id") ?? '';
    setState(() {
      num = 1;
      PaymentListdata = _getData();
      PaymentListfilterData=PaymentListdata;

      userdata = _getuserData();
      filterData=userdata;
    });
  }

  Future<List<PaymentList>> _getData() async
  {
    return _netUtil.post(RestDatasource.GET_DELIVEYBOY, body: {
      'action': "show_user_balance_log",
      'user_id': user_id,
      "token":token,
    }).then((dynamic res) {
      print(res);
      final items = res.cast<Map<String, dynamic>>();
      List<PaymentList> listofPaymentList = items.map<PaymentList>((json) {
        return PaymentList.fromJson(json);
      }).toList();
      List<PaymentList> revdata = listofPaymentList.toList();
      return revdata;
    });
  }

  //On Refresh
  Future<List<PaymentList>> _refresh() async
  {
    setState(() {
      PaymentListdata = _getData();
      PaymentListfilterData=PaymentListdata;
    });
  }

  Future<List<UserOrderLogList>> _getuserData() async
  {
    return _netUtil.post(RestDatasource.GET_DELIVEYBOY, body: {
      'action': "show_user_order_log",
      'user_id': user_id,
      "token":token,
    }).then((dynamic res) {
      print(res);
      final items = res.cast<Map<String, dynamic>>();
      List<UserOrderLogList> listofUserOrderLogList = items.map<UserOrderLogList>((json) {
        return UserOrderLogList.fromJson(json);
      }).toList();
      List<UserOrderLogList> revdata = listofUserOrderLogList .toList();
      return revdata;
    });
  }

  Future<List<UserOrderLogList>> _refresh1() async
  {
    setState(() {
      userdata = _getuserData();
      filterData=userdata;
    });
  }

  bool isOffline = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;
  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    _loadPref();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
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
    //   num == 0 ?
    //   _loadPref() : null;
    //   // _loadPref();
    // });
    // print("User");
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return DefaultTabController(
        length: 2,
        child: new Scaffold(
          backgroundColor: shadecolor,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Add your onPressed code here!
              Navigator.of(context).pushNamed("/adduserbalance",
              arguments: {
                "user_id" : user_id,
                "user_first_name" : user_first_name,
                "user_last_name" : user_last_name,
              });

            },
            label: const Text('ADD BALANCE',style: TextStyle(color: whitecolor),),
            icon: const Icon(Icons.add,color: whitecolor,),
            backgroundColor: maincolor,
          ),
          body: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    new SliverAppBar(
                      title: Text("$user_first_name $user_last_name Balance"),
                      pinned: true,
                      floating: true,
                      centerTitle: true,
                      snap: false,
                      backgroundColor: maincolor,
                      forceElevated: innerBoxIsScrolled,
                      // actions: <Widget>[
                      //   InkWell(
                      //     onTap: () {},
                      //     child: Container(
                      //       alignment: Alignment.center,
                      //       padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      //       child: Text(
                      //         "SAVE",
                      //         style: GoogleFonts.alegreyaSans(
                      //             color: whitecolor,
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //   )
                      // ],
                      flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                ),
                                color: greencolor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text("₹ "+user_balance,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ) //TextStyle
                              ),
                            ),
                          ), //Text//Images.network
                      ), //F
                      bottom: new TabBar(
                        indicatorColor: whitecolor,
                        controller: _tabController,
                        tabs: <Tab>[
                          new Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Credit",
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
                                "Debit",
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
                    (_isLoading)
                        ? new Center(
                      child: CircularProgressIndicator(),
                    ):
                    Stack(
                      children: <Widget>[

                        RefreshIndicator(
                          key: _refreshIndicatorKey,
                          color: maincolor,
                          onRefresh: _refresh,
                          child: FutureBuilder<List<PaymentList>>(
                            future: PaymentListfilterData,
                            builder: (context, snapshot) {
                              //print(snapshot.data);
                              if (snapshot.connectionState == ConnectionState.waiting) {
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
                                padding: EdgeInsets.only(top: 10),
                                children: snapshot.data
                                    .map((data) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: maincolor,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(16.0),
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
                                      margin: new EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 5.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(data.tbl_tilte ?? "",style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: maincolor)),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Amount : ",
                                                            style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              data.ubl_amount==null?"":data.ubl_amount,
                                                              style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Add Time : ",
                                                            style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              data.ubl_date==null?"":data.ubl_date+ " ",
                                                              style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ).toList(),
                              );
                            },
                          ),
                        ),


                      ],
                    ),

                    Stack(

                      children: <Widget>[
                        RefreshIndicator(
                          key: _refreshIndicatorKey1,
                          color: maincolor,
                          onRefresh: _refresh1,
                          child: FutureBuilder<List<UserOrderLogList>>(
                            future: filterData,
                            builder: (context, snapshot) {
                              //print(snapshot.data);
                              if (snapshot.connectionState == ConnectionState.waiting) {
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
                                padding: EdgeInsets.only(top: 10),
                                children: snapshot.data
                                    .map((data) =>
                                    Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: maincolor,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(16.0),
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
                                          margin: new EdgeInsets.symmetric(
                                              horizontal: 15.0, vertical: 5.0),
                                          // color:Colors.red.shade400,
                                          // decoration: BoxDecoration(
                                          //     gradient: LinearGradient(
                                          //         colors: [Colors.lightGreen.shade600, Colors.lightGreen.shade400, Colors.lightGreen.shade500],
                                          //         begin: Alignment.bottomCenter,
                                          //         end: Alignment.topCenter,
                                          //         stops: [0.2,0.6,1]
                                          //     )
                                          // ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      // SizedBox(
                                                      //   width: 5,
                                                      // ),

                                                      (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 80, height: 80,)):ClipOval(child: new Image.asset('images/logo.png', width: 80, height: 80,)),
                                                      // (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 80, height: 80,)):ClipOval(child: new Image.asset('images/logo.png', width: 80, height: 80,)),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Flexible(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Flexible(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    data.product_name==null?"":data.product_name,
                                                                    style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: maincolor),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        product_quantity_text,
                                                                        style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                                      ),
                                                                      Flexible(
                                                                        child: Text(
                                                                          data.order_qty==null?"":data.order_qty,
                                                                          style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        "Order Total Price : ",
                                                                        style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                                      ),
                                                                      Flexible(
                                                                        child: Text(
                                                                          data.order_total_amt==null?"":data.order_total_amt,
                                                                          style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        "Date : ",
                                                                        style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                                      ),
                                                                      Flexible(
                                                                        child: Text(
                                                                          data.order_date==null?"":data.order_date,
                                                                          style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w600, color: blackcolor),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ).toList(),
                              );
                            },
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: <Widget>[
              //
              //
              //     Container(
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment
              //             .spaceEvenly,
              //         children: <Widget>[
              //           Expanded(
              //             child: Padding(
              //               padding: const EdgeInsets.fromLTRB(5,0, 5, 0),
              //               child:
              //               InkWell(
              //                 onTap: () {
              //                   // Fluttertoast.showToast(msg: "Please Wait", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
              //                   // FlashHelper.successBar(context, message: user_id.toString());
              //                 },
              //
              //                 child: Container(
              //                   decoration: BoxDecoration(
              //                     borderRadius: BorderRadius.only(
              //                       topLeft: Radius.circular(15.0),
              //                       topRight: Radius.circular(15.0),
              //                       bottomLeft: Radius.circular(0.0),
              //                       bottomRight: Radius.circular(0.0),
              //                     ),
              //
              //                     gradient: LinearGradient(
              //                       begin: Alignment.topLeft,
              //                       end: Alignment.bottomRight,
              //                       colors:
              //                       [
              //                         Color(0xFF0E50F6).withOpacity(0.1),
              //                         Color(0xFFFFFFFF).withOpacity(0.2),
              //                       ],
              //                       stops: [0.3, 2],),
              //                     // color: maincolor,
              //
              //                   ),
              //                   padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              //                   alignment: Alignment.bottomLeft,
              //                   child: user_balance!=null?Text("User Balance : "+user_balance,style: TextStyle(fontSize: 14,color:redcolor,fontWeight: FontWeight.w600),):null,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //
              //   ],
              // ),
            ],
          ),
        ),
      );
    }
  }


}
