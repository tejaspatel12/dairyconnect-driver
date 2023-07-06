import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nooranidairyfarm_deliveryboy/models/product.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';

class UserOnecProductScreen extends StatefulWidget {
  final String user_id,user_first_name,user_last_name;
  const UserOnecProductScreen({Key key, @required this.user_id, @required this.user_first_name, @required this.user_last_name}) : super(key: key);

  @override
  State<UserOnecProductScreen> createState() => UserOnecProductScreenState(user_id,user_first_name,user_last_name);

  // UserOnecProductScreenState createState() => UserOnecProductScreenState();
}

class UserOnecProductScreenState extends State<UserOnecProductScreen> {
  BuildContext _ctx;
  String user_id,user_first_name,user_last_name;

  UserOnecProductScreenState(this.user_id,this.user_first_name,this.user_last_name);

  RestDatasource api = new RestDatasource();
  NetworkUtil _netUtil = new NetworkUtil();
  String loggedinname = "",user_status;
  String user_subscription_status,accept_nagative_balance,user_balance;
  String cutoff_1,cutoff_2;
  String newdate;
  String notification = "1";
  String category_id="",time_slot,cutoff_time,user_type;
  int count = 1;
  int num = 0;
  DateTime dateTime = DateTime.now();
  DateTime mordate = DateTime.now();

  Future<List<ProductList>> ProductListdata;
  Future<List<ProductList>> ProductListfilterData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  bool _isdataLoading = true;
  bool _isdataUser = true;
  String searchQuery = "Search query";

  bool _isProccessing = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  _loadPref() async {
    setState(() {
      ProductListdata = getProductData();
      ProductListfilterData=ProductListdata;
      _loadUserTime();
    });

  }

  _loadUserTime() async {
    print("user id : " + user_id);
    setState(() {
      _netUtil.post(RestDatasource.GET_USER_DASHBOARD, body: {
        "user_id": user_id,
      }).then((dynamic res) async {
        setState(() {
          num= 1;
          // print(res);
          user_status = res["user_status"];
          time_slot = res["time_slot"].toString();
          print("time_slot : $time_slot");
          if(user_status=="1")
          {
            print("Yes here");
            user_first_name = res["user_first_name"].toString();
            user_last_name = res["user_last_name"].toString();
            user_type = res["user_type"].toString();
            user_subscription_status = res["user_subscription_status"].toString();
            accept_nagative_balance = res["accept_nagative_balance"].toString();
            user_balance = res["user_balance"].toString();

            //
            time_slot = res["time_slot"].toString();
            cutoff_time = res["cutoff_time"].toString();

            cutoff_1 = res["cutoff_1"].toString();
            cutoff_2 = res["cutoff_2"].toString();
            newdate = DateFormat('yyyy-MM-dd').format(dateTime).toString();
            newdate = newdate+" "+ cutoff_time;
            print("NEW DATE"+newdate.toString());
            print("time_slot "+time_slot);
            // print("user_status "+user_status);

            // newdate = DateFormat('yyyy-MM-dd H:mm:ss').format(newdate).toString();

            if(cutoff_time==cutoff_1)
            {
              // print("NEW "+newdate.toString());
              // print("MOR "+DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString());

              DateTime.parse(newdate.toString()).isBefore
                (DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString()))==false?
              mordate=dateTime:
              mordate=dateTime.add(Duration(days: 1));
            }
            else if(cutoff_time==cutoff_2)
            {
              DateTime.parse(newdate.toString()).isBefore
                (DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)))==false?
              // (DateTime.parse(dateTime.toString()))==false?
              mordate=dateTime:
              mordate=dateTime.add(Duration(days: 1));
            }
            else{}
          }
          else{
            print("No here");
            time_slot="No";
          }

          print("Here TIME IS :"+time_slot);

          _isdataUser = false;
        });
      });
    });
  }


  //Load Data
  Future<List<ProductList>> getProductData() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.GET_DELIVEYBOY, body: {
      'action': "user_onec_product",
      "user_id": user_id,
      // "featured_product":"1",
    }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      // print(items);
      List<ProductList> listofusers = items.map<ProductList>((json) {
        return ProductList.fromJson(json);
      }).toList();
      List<ProductList> revdata = listofusers.toList();

      return revdata;
    });
  }

  //On Refresh
  Future<List<ProductList>> _refresh1() async
  {
    setState(() {
      ProductListdata = getProductData();
      ProductListfilterData=ProductListdata;
    });
  }


  bool isOffline = false;
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
    _loadPref();
    // _loadUserTime();
    _searchQuery = new TextEditingController();
    // _loadUser();

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
    //   user_id = arguments['user_id'];
    //   user_first_name = arguments['user_first_name'];
    //   user_last_name = arguments['user_last_name'];
    //   // _loadPref();
    //   num==0?_loadUserTime():null;
    // });
    print("Product");
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("One Time Product",style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: maincolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: maincolor,
          onRefresh: _refresh1,
          child: FutureBuilder<List<ProductList>>(
            future: ProductListdata,
            builder: (context, snapshot) {
              //print(snapshot.data);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Lottie.asset(
                    'assets/load.json',
                    repeat: true,
                    reverse: true,
                    animate: true,
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
              return (_isdataUser)?Center(
                child: Lottie.asset(
                  'assets/load.json',
                  repeat: true,
                  reverse: true,
                  animate: true,
                ),

              ):(_isProccessing)?Center(
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
                    padding: EdgeInsets.only(top: 15),
                    children: snapshot.data
                        .map((data) =>

                        GestureDetector(
                          onTap: ()
                          {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState /*You can rename this!*/) {
                                        return Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: whitecolor,
                                                // color: blackcolor,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(10),
                                                // gradient: LinearGradient(
                                                //   begin: Alignment.topLeft,
                                                //   end: Alignment.bottomRight,
                                                //   colors:
                                                //   [
                                                //     // Color(0xFF0E50F6).withOpacity(0.3),
                                                //     Color(0xFFFFFFFF).withOpacity(0.3),
                                                //     Color(0xFFFFFFFF).withOpacity(0.2),
                                                //   ],
                                                //   stops: [0.1, 2],),
                                                boxShadow: const [
                                                  BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: Offset(0.0, 10.0)),
                                                ],
                                              ),
                                              width: MediaQuery.of(context).size.width,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                          Text("Add Subscription Order", style: TextStyle(color: Colors.white,fontSize: 18)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // 24.height,
                                                  const SizedBox(
                                                    height: 10,
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.only(left: 12, right: 12),
                                                    child: Form(
                                                      key: formKey,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [

                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: <Widget>[

                                                              (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 90, height: 90,)):ClipOval(child: new Image.asset('images/logo.png', width: 90, height: 90,)),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Flexible(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                    SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    Text(
                                                                      data.product_name,
                                                                      style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w600, color: maincolor),
                                                                    ),
                                                                    SizedBox(
                                                                      height: spacing_control,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          data.product_att_value==null?"":data.product_att_value,
                                                                          style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w500, color: redcolor),
                                                                        ),
                                                                        SizedBox(
                                                                          width: 5,
                                                                        ),
                                                                        Text(
                                                                          data.attribute_name==null?"":data.attribute_name,
                                                                          style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w500, color: redcolor),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: spacing_control,
                                                                    ),
                                                                    user_type=="1"?
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          "Price : ",
                                                                          style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: greencolor),
                                                                        ),
                                                                        Flexible(
                                                                          child: Text(
                                                                            data.product_regular_price==null?"":data.product_regular_price,
                                                                            style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: greencolor),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ):
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          "Price : ",
                                                                          style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: greencolor),
                                                                        ),
                                                                        Flexible(
                                                                          child: Text(
                                                                            data.product_normal_price==null?"":data.product_normal_price,
                                                                            style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: greencolor),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    SizedBox(
                                                                      height: spacing_control,
                                                                    ),

                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          "Product Minimum Quantity : ",
                                                                          style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w500, color: whitecolor),
                                                                        ),
                                                                        Text(
                                                                          data.product_min_qty==null?"":data.product_min_qty.toString(),
                                                                          style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w500, color: whitecolor),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          SizedBox(height: 10,),
                                                          Text("Select Quantity"),
                                                          SizedBox(height: 10,),


                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [

                                                              InkWell(
                                                                onTap: (){
                                                                  setState(() {
                                                                    // int.parse(price);
                                                                    if(count <= data.product_min_qty)
                                                                    {
                                                                      count = data.product_min_qty;
                                                                    }
                                                                    else
                                                                    {
                                                                      count = count-1;
                                                                    }

                                                                  });
                                                                },
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(5.0),
                                                                      topRight: Radius.circular(5.0),
                                                                      bottomLeft: Radius.circular(5.0),
                                                                      bottomRight: Radius.circular(5.0),
                                                                    ),
                                                                    color: maincolor, //
                                                                  ),
                                                                  child: Padding(
                                                                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                                                    child: Icon(Icons.remove,size:textSizeMedium,color: whitecolor,),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: spacing_standard,
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.fromLTRB(15, 7, 15, 7),
                                                                child: Text(count.toString(),
                                                                  style: TextStyle(
                                                                    color: maincolor,
                                                                    fontSize: textSizeSMedium,
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: spacing_standard,
                                                              ),
                                                              InkWell(
                                                                onTap: (){
                                                                  setState(() {
                                                                    // int.parse(price);
                                                                    count = count+1;
                                                                    // if(count >= 10)
                                                                    // {
                                                                    // }
                                                                    // else
                                                                    // {
                                                                    //   count = count+1;
                                                                    // }

                                                                  });
                                                                },
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(5.0),
                                                                      topRight: Radius.circular(5.0),
                                                                      bottomLeft: Radius.circular(5.0),
                                                                      bottomRight: Radius.circular(5.0),
                                                                    ),
                                                                    color: maincolor, //
                                                                  ),
                                                                  child: Padding(
                                                                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                                                    child: Icon(Icons.add,size:textSizeMedium,color: whitecolor,),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          Divider(),

                                                          Text("Select Date"),

                                                          SizedBox(height: 15,),

                                                          time_slot!="No"?
                                                          Column(
                                                            children: [
                                                              cutoff_time==cutoff_1?
                                                              Container(
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(Icons.today,size:textSizeNormal,color: blackcolor,),
                                                                        SizedBox(
                                                                          width: spacing_control,
                                                                        ),
                                                                        // DateTime.parse(newdate.toString()).isBefore
                                                                        //   (DateTime.parse(dateTime.toString()))==false?
                                                                        // Text(DateFormat('d-MM-yyy').format(dateTime.add(Duration(days: 1))), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)):
                                                                        // Text(DateFormat('d-MM-yyy').format(dateTime.add(Duration(days: 2))), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                        Text(DateFormat('d-MM-yyy').format(mordate), style: TextStyle(color: blackcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5))
                                                                      ],
                                                                    ),

                                                                    DateTime.parse(newdate.toString()).isBefore
                                                                      (DateTime.parse(dateTime.toString()))==false?
                                                                    InkWell(
                                                                        onTap:() async {
                                                                          DateTime newDateTime = await showDatePicker(
                                                                            context: context,
                                                                            initialDate: dateTime,
                                                                            firstDate: dateTime,
                                                                            lastDate: DateTime(DateTime.now().year + 1),
                                                                          );
                                                                          if (newDateTime != null) {
                                                                            setState(() => mordate = newDateTime);
                                                                          }
                                                                        },
                                                                        child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                                    ):
                                                                    InkWell(
                                                                        onTap:() async {
                                                                          DateTime newDateTime = await showDatePicker(
                                                                            context: context,
                                                                            initialDate: dateTime.add(Duration(days: 1)),
                                                                            firstDate: dateTime.add(Duration(days: 1)),
                                                                            lastDate: DateTime(DateTime.now().year + 1),
                                                                          );
                                                                          if (newDateTime != null) {
                                                                            setState(() => mordate = newDateTime);
                                                                          }
                                                                        },
                                                                        child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                                    ),

                                                                  ],
                                                                ),
                                                              ):
                                                              cutoff_time==cutoff_2?
                                                              Container(
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        const Icon(Icons.today,size:textSizeNormal,color: blackcolor,),
                                                                        const SizedBox(
                                                                          width: spacing_control,
                                                                        ),
                                                                        // DateTime.parse(newdate.toString()).isBefore
                                                                        //   (DateTime.parse(dateTime.toString()))==false?
                                                                        // Text(DateFormat('d-MM-yyy').format(dateTime), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)):
                                                                        // Text(DateFormat('d-MM-yyy').format(dateTime.add(Duration(days: 1))), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                        Text(DateFormat('d-MM-yyy').format(mordate), style: TextStyle(color: blackcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5))
                                                                      ],
                                                                    ),

                                                                    DateTime.parse(newdate.toString()).isBefore
                                                                      (DateTime.parse(dateTime.toString()))==false?
                                                                    InkWell(
                                                                        onTap:() async {
                                                                          DateTime newDateTime = await showDatePicker(
                                                                            context: context,
                                                                            initialDate: dateTime,
                                                                            firstDate: dateTime,
                                                                            lastDate: DateTime(DateTime.now().year + 1),
                                                                          );
                                                                          if (newDateTime != null) {
                                                                            setState(() => mordate = newDateTime);
                                                                          }
                                                                        },
                                                                        child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                                    ):
                                                                    InkWell(
                                                                        onTap:() async {
                                                                          DateTime newDateTime = await showDatePicker(
                                                                            context: context,
                                                                            initialDate: dateTime.add(Duration(days: 1)),
                                                                            firstDate: dateTime.add(Duration(days: 1)),
                                                                            lastDate: DateTime(DateTime.now().year + 1),
                                                                          );
                                                                          if (newDateTime != null) {
                                                                            setState(() => mordate = newDateTime);
                                                                          }
                                                                        },
                                                                        child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                                    )

                                                                  ],
                                                                ),
                                                              ):SizedBox(),
                                                            ],
                                                          )
                                                              :SizedBox(),

                                                          Divider(),
                                                          SizedBox(height: 10,),
                                                          Container(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment
                                                                  .spaceEvenly,
                                                              children: <Widget>[
                                                                Expanded(
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      // Fluttertoast.showToast(msg: "Please Wait", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                                                                      if(count < data.product_min_qty)
                                                                      {
                                                                        showDialog(
                                                                            context: context,
                                                                            builder: (context) =>
                                                                                Dialog(
                                                                                  // backgroundColor: blackcolor,
                                                                                  child: Container(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment
                                                                                          .start,
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: <Widget>[
                                                                                        Container(
                                                                                          padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment
                                                                                                .center,
                                                                                            children: <Widget>[
                                                                                              Lottie.asset(
                                                                                                'assets/stop.json',
                                                                                                repeat: true,
                                                                                                reverse: false,
                                                                                                animate: true,
                                                                                                height: MediaQuery.of(context).size.height * 0.40,
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: spacing_standard,
                                                                                              ),
                                                                                              Align(
                                                                                                  alignment: Alignment.center,
                                                                                                  child: Text("Minimum Quantity", style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold,color: maincolor),)
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: spacing_middle,
                                                                                              ),
                                                                                              Align(
                                                                                                alignment: Alignment.center,
                                                                                                child: Text(
                                                                                                  "You should add at less "+ data.product_min_qty.toString() +" quantity",
                                                                                                  style: TextStyle(
                                                                                                      fontSize: textSizeMMedium,fontWeight: FontWeight.w500, letterSpacing: 0.2
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: spacing_standard,
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        // Divider(
                                                                                        //   color: Colors.grey,
                                                                                        // ),
                                                                                        Row(
                                                                                          children: <Widget>[

                                                                                            Expanded(
                                                                                              child: InkWell(
                                                                                                onTap: ()
                                                                                                {
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.all(10.0),
                                                                                                  child: Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.only(
                                                                                                        topLeft: Radius.circular(5.0),
                                                                                                        topRight: Radius.circular(5.0),
                                                                                                        bottomLeft: Radius.circular(5.0),
                                                                                                        bottomRight: Radius.circular(5.0),
                                                                                                      ),
                                                                                                      color: maincolor,
                                                                                                    ),
                                                                                                    padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                                                                                                    alignment: Alignment.center,
                                                                                                    child: Text("Ok".toUpperCase(),style: TextStyle(fontSize: textSizeSMedium,color:Colors.white,fontWeight: FontWeight.w600),),
                                                                                                  ),
                                                                                                ),
                                                                                              ),

                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                        );
                                                                      }
                                                                      else
                                                                      {
                                                                        // FlashHelper.errorBar(context, message: cutoff_time);
                                                                        if (_isProccessing == false) {
                                                                          final form = formKey.currentState;
                                                                          if (form.validate()) {
                                                                            setState(() => _isProccessing = true);
                                                                            form.save();
                                                                            NetworkUtil _netUtil = new NetworkUtil();
                                                                            _netUtil.post(RestDatasource.GET_DELIVEYBOY, body: {
                                                                              'action': "deliveryboy_order_onetime_product",
                                                                              "user_id": user_id,
                                                                              "product_id": data.product_id,
                                                                              "product_name": data.product_name,
                                                                              "attribute_id": data.attribute_id,
                                                                              "cutoff_time": cutoff_time,
                                                                              "order_qty": count.toString(),
                                                                              "order_amt": user_type=="1"? data.product_regular_price.toString():data.product_normal_price.toString(),
                                                                              "start_date": DateFormat('yyyy-MM-dd').format(mordate).toString(),
                                                                            }).then((dynamic res) async {
                                                                              if(res["status"] == "insufficient_balance")
                                                                              {
                                                                                setState(() => _isProccessing = false);
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (context) =>
                                                                                        Dialog(
                                                                                          backgroundColor: Colors.white,
                                                                                          child: Container(
                                                                                            child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment
                                                                                                  .start,
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              children: <Widget>[
                                                                                                Container(
                                                                                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                                                                                  child: Column(
                                                                                                    crossAxisAlignment: CrossAxisAlignment
                                                                                                        .center,
                                                                                                    children: <Widget>[
                                                                                                      Lottie.asset(
                                                                                                        'assets/stop.json',
                                                                                                        repeat: true,
                                                                                                        reverse: false,
                                                                                                        animate: true,
                                                                                                        height: MediaQuery.of(context).size.height * 0.40,
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        height: spacing_standard,
                                                                                                      ),
                                                                                                      Align(
                                                                                                          alignment: Alignment.center,
                                                                                                          child: Text(res['message'], style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold,color: maincolor),)
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        height: spacing_middle,
                                                                                                      ),
                                                                                                      Align(
                                                                                                        alignment: Alignment.center,
                                                                                                        child: Text(
                                                                                                          res['description'],
                                                                                                          style: TextStyle(
                                                                                                              fontSize: textSizeMMedium,fontWeight: FontWeight.w500, letterSpacing: 0.2
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        height: spacing_standard,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                // Divider(
                                                                                                //   color: Colors.grey,
                                                                                                // ),
                                                                                                Row(
                                                                                                  children: <Widget>[

                                                                                                    Expanded(
                                                                                                      child: InkWell(
                                                                                                        onTap: ()
                                                                                                        {
                                                                                                          Navigator.of(context).pushReplacementNamed("/wallet");
                                                                                                        },
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.all(10.0),
                                                                                                          child: Container(
                                                                                                            decoration: BoxDecoration(
                                                                                                              borderRadius: BorderRadius.only(
                                                                                                                topLeft: Radius.circular(5.0),
                                                                                                                topRight: Radius.circular(5.0),
                                                                                                                bottomLeft: Radius.circular(5.0),
                                                                                                                bottomRight: Radius.circular(5.0),
                                                                                                              ),
                                                                                                              color: maincolor,
                                                                                                            ),
                                                                                                            padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                                                                                                            alignment: Alignment.center,
                                                                                                            child: Text("Ok",style: TextStyle(fontSize: textSizeMedium,color:Colors.white,fontWeight: FontWeight.w600),),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),

                                                                                                    ),
                                                                                                  ],
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                );
                                                                              }
                                                                              else if (res["status"] == "yes") {
                                                                                setState(() => _isProccessing = false);
                                                                                // FlashHelper.successBar(
                                                                                //     context, message: res['message']);
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (context) =>
                                                                                        Dialog(
                                                                                          backgroundColor: Colors.white,
                                                                                          child: Container(
                                                                                            child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment
                                                                                                  .start,
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              children: <Widget>[
                                                                                                Container(
                                                                                                  padding: EdgeInsets.fromLTRB(
                                                                                                      20, 20, 20, 5),
                                                                                                  child: Column(
                                                                                                    crossAxisAlignment: CrossAxisAlignment
                                                                                                        .center,
                                                                                                    children: <Widget>[
                                                                                                      Lottie.asset(
                                                                                                        'assets/done.json',
                                                                                                        repeat: true,
                                                                                                        reverse: false,
                                                                                                        animate: true,
                                                                                                        height: MediaQuery
                                                                                                            .of(context)
                                                                                                            .size
                                                                                                            .height * 0.40,
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        height: spacing_standard,
                                                                                                      ),
                                                                                                      Align(
                                                                                                          alignment: Alignment
                                                                                                              .center,
                                                                                                          child: Text(
                                                                                                            res['message'],
                                                                                                            style: TextStyle(
                                                                                                                fontSize: textSizeLargeMedium,
                                                                                                                fontWeight: FontWeight
                                                                                                                    .bold,
                                                                                                                color: maincolor),)
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        height: spacing_middle,
                                                                                                      ),
                                                                                                      Align(
                                                                                                        alignment: Alignment
                                                                                                            .center,
                                                                                                        child: Text(
                                                                                                          res['description'],
                                                                                                          style: TextStyle(
                                                                                                              fontSize: textSizeMMedium,
                                                                                                              fontWeight: FontWeight
                                                                                                                  .w500,
                                                                                                              letterSpacing: 0.2
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        height: spacing_standard,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                // Divider(
                                                                                                //   color: Colors.grey,
                                                                                                // ),
                                                                                                Row(
                                                                                                  children: <Widget>[

                                                                                                    Expanded(
                                                                                                      child: InkWell(
                                                                                                        onTap: () {
                                                                                                          Navigator.of(context)
                                                                                                              .pushReplacementNamed(
                                                                                                              "/bottomhome");
                                                                                                        },
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets
                                                                                                              .all(10.0),
                                                                                                          child: Container(
                                                                                                            decoration: BoxDecoration(
                                                                                                              borderRadius: BorderRadius
                                                                                                                  .only(
                                                                                                                topLeft: Radius
                                                                                                                    .circular(
                                                                                                                    5.0),
                                                                                                                topRight: Radius
                                                                                                                    .circular(
                                                                                                                    5.0),
                                                                                                                bottomLeft: Radius
                                                                                                                    .circular(
                                                                                                                    5.0),
                                                                                                                bottomRight: Radius
                                                                                                                    .circular(
                                                                                                                    5.0),
                                                                                                              ),
                                                                                                              color: maincolor,
                                                                                                            ),
                                                                                                            padding: EdgeInsets
                                                                                                                .fromLTRB(
                                                                                                                10, 12, 10, 12),
                                                                                                            alignment: Alignment
                                                                                                                .center,
                                                                                                            child: Text("Ok",
                                                                                                              style: TextStyle(
                                                                                                                  fontSize: textSizeMedium,
                                                                                                                  color: Colors
                                                                                                                      .white,
                                                                                                                  fontWeight: FontWeight
                                                                                                                      .w600),),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),

                                                                                                    ),
                                                                                                  ],
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                );
                                                                              }
                                                                              else {
                                                                                setState(() => _isProccessing = false);
                                                                                // FlashHelper.errorBar(
                                                                                //     context, message: res['message']);
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
                                                                          bottomLeft: Radius.circular(0.0),
                                                                          bottomRight: Radius.circular(0.0),
                                                                        ),
                                                                        color: maincolor,
                                                                      ),
                                                                      padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                                                      alignment: Alignment.center,
                                                                      child: Text("Add Now".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                        ],
                                                      ),
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

                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: maincolor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                              color: whitecolor,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[

                                      (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 90, height: 90,)):ClipOval(child: new Image.asset('images/logo.png', width: 90, height: 90,)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              data.product_name,
                                              style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w600, color: maincolor, wordSpacing: 0.2),
                                            ),
                                            SizedBox(
                                              height: spacing_control,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  data.product_att_value==null?"":data.product_att_value,
                                                  style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w500, color: redcolor),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  data.attribute_name==null?"":data.attribute_name,
                                                  style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w500, color: redcolor),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: spacing_control,
                                            ),
                                            user_type=="1"?Text(
                                              data.product_regular_price==null?"":"₹ "+data.product_regular_price,
                                              style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: greencolor),
                                            ):Text(
                                              data.product_normal_price==null?"":"₹ "+data.product_normal_price,
                                              style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: greencolor),
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
                        ),
                    ).toList(),
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
                                padding: const EdgeInsets.fromLTRB(5,0, 5, 0),
                                child:
                                InkWell(
                                  onTap: () {
                                    Fluttertoast.showToast(msg: "Please Wait", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: MediaQuery.of(context).size.width * 0.04);
                                    // FlashHelper.successBar(context, message: user_id.toString());
                                  },

                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15.0),
                                        topRight: Radius.circular(15.0),
                                        bottomLeft: Radius.circular(0.0),
                                        bottomRight: Radius.circular(0.0),
                                      ),
                                      color: maincolor,
                                    ),
                                    padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                    alignment: Alignment.center,
                                    child: Text(time_slot==""?"":time_slot.toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
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
              );
            },
          ),
        ),
      );
    }
  }


}
