import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nooranidairyfarm_deliveryboy/models/once_order.dart';
import 'package:nooranidairyfarm_deliveryboy/models/order.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/flash_helper.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';

class OrderDetailScreen extends StatefulWidget {
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  BuildContext _ctx;

  bool _isLoading=false;
  bool _isButton=false;
  RestDatasource api = new RestDatasource();
  NetworkUtil _netUtil = new NetworkUtil();
  String loggedinname = "";
  String deliveryboy_id="",user_id,_number;
  DateTime currentDate;
  double newnumber,newqty;
  int num = 0;
  Future<List<OnceOrderList>> userdata;
  Future<List<OnceOrderList>> filterData;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  String searchQuery = "Search query";

  _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deliveryboy_id = prefs.getString("deliveryboy_id") ?? '';
      num = 1;
      loggedinname= prefs.getString("name") ?? '';
      userdata = _getData();
      filterData=userdata;
    });
  }

  Future<List<OnceOrderList>> _getData() async
  {
    return _netUtil.post(RestDatasource.ORDER_DETAIL,
        body:{
          'deliveryboy_id': deliveryboy_id,
          'user_id': user_id,
          "date": DateFormat('yyy-MM-d').format(currentDate).toString(),
        }
    ).then((dynamic res) {
      final items = res.cast<Map<String, dynamic>>();
      print(items);
      List<OnceOrderList> listofusers = items.map<OnceOrderList>((json) {
        return OnceOrderList.fromJson(json);
      }).toList();
      List<OnceOrderList> revdata = listofusers.toList();
      return revdata;
    });
  }

  // Future<List<OnceOrderList>> _refresh() async
  // {
  //   setState(() {
  //     userdata = _getData();
  //     filterData=userdata;
  //   });
  // }

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;
  @override
  void initState() {
    currentDate = DateTime.now();
    super.initState();
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
    _searchQuery = new TextEditingController();
  }
  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }



  void _startSearch() {
    //print("open search box");
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }
  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    //print("close search box");
    setState(() {
      _searchQuery.clear();
      filterData=userdata;
      updateSearchQuery("");
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      if(searchQuery.toString().length>0)
      {
        //print(searchQuery.toString().length);
        Future<List<OnceOrderList>> items=userdata;
        List<OnceOrderList> filter=new List<OnceOrderList>();
        items.then((result){
          for(var record in result)
          {

            if(record.product_name.toLowerCase().toString().contains(searchQuery.toLowerCase()))
            {
              //print(record.Name);
              filter.add(record);
            }
          }
          filterData=Future.value(filter);
        });
      }
      else
      {
        filterData=userdata;
      }
    });
    print("search query1 " + newQuery);
  }
  Widget _buildSearchField() {
    return new TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: updateSearchQuery,
    );
  }
  List<Widget> _buildActions() {

    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  //Load Data
  //On Refresh
  Future<List<OnceOrderList>> _refresh1() async
  {
    setState(() {
      userdata = _getData();
      filterData=userdata;
    });
  }

  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    setState(() {
      _ctx = context;
      final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
      user_id = arguments['user_id'];
    });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: shadecolor,
        // backgroundColor: blackcolor,
        body: SafeArea(
          child: new NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  centerTitle: true,
                  title: _isSearching ? _buildSearchField() : RichText(
                    text: TextSpan(
                        text: "Orders".toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 17,fontWeight: FontWeight.bold),

                        children: [
                          TextSpan(text: "",
                              style: TextStyle(color: Colors.white, fontSize: 15))
                        ]),
                  ),
                  actions: _buildActions(),
                  backgroundColor: maincolor,
                  iconTheme: IconThemeData(color: Colors.white),
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,

                ),
              ];
            },
            body: Stack(
              children: <Widget>[
                RefreshIndicator(
                  key: _refreshIndicatorKey,
                  color: maincolor,
                  onRefresh: _refresh1,
                  child: FutureBuilder<List<OnceOrderList>>(
                    future: filterData,
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
                      return ListView(
                        padding: EdgeInsets.only(top: 15),
                        children: snapshot.data
                            .map((data) =>
                            Slidable(
                              actionPane: SlidableScrollActionPane(),
                              actions: [
                                data.oc_is_delivered=="1" || data.oc_is_delivered=="2"?SizedBox():Padding(
                                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    // elevation: 2.0,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    margin: new EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 0.0),
                                    child: IconSlideAction(
                                      caption: 'No Delivered',
                                      icon: Icons.cancel,
                                      color: redcolor,
                                      onTap: (){
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                Dialog(
                                                  backgroundColor: Colors.white,
                                                  child: Stack(
                                                    children: [
                                                      SingleChildScrollView(
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
                                                                      .start,
                                                                  children: <Widget>[
                                                                    SvgPicture.asset('images/path.svg',width: MediaQuery.of(context).size.width * 0.65,),
                                                                    SizedBox(
                                                                      height: spacing_standard,
                                                                    ),

                                                                    Form(
                                                                      key: formKey,
                                                                      child: Column(
                                                                        children: [
                                                                          TextFormField(
                                                                            initialValue: null,
                                                                            obscureText: false,
                                                                            keyboardType: TextInputType.number,
                                                                            onSaved: (val) {
                                                                              setState(() {
                                                                                _number = val;
                                                                                newnumber = double.parse(_number);

                                                                                newqty = double.parse(data.order_qty);
                                                                                if(newqty < newnumber)
                                                                                {
                                                                                  _isButton = true;
                                                                                }
                                                                                else
                                                                                {
                                                                                  _isButton = false;
                                                                                }
                                                                              });
                                                                            },
                                                                            onChanged: (val) {
                                                                              setState(() {
                                                                                _number = val;
                                                                                newnumber = double.parse(_number);

                                                                                newqty = double.parse(data.order_qty);
                                                                                if(newqty < newnumber)
                                                                                {
                                                                                  _isButton = true;
                                                                                }
                                                                                else
                                                                                {
                                                                                  _isButton = false;
                                                                                }
                                                                              });
                                                                            },
                                                                            validator: (val) {
                                                                              return val.length <= 0
                                                                                  ? "Please Enter Not Delivered Product Number"
                                                                                  : null;
                                                                            },
                                                                            decoration: InputDecoration(
                                                                              hintText: "Not Delivered Product Quantity",
                                                                              labelStyle: TextStyle(color: maincolor),
                                                                              filled: false,
                                                                              focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(width: 1, color: maincolor)
                                                                              ),
                                                                              border: OutlineInputBorder(
                                                                                  borderSide: BorderSide()
                                                                              ),
                                                                              //fillColor: Colors.red.shade50,
                                                                              contentPadding: EdgeInsets.all(12),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    // Align(
                                                                    //     alignment: Alignment.center,
                                                                    //     child: Text(res["message"], style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold),)
                                                                    // ),

                                                                    SizedBox(
                                                                      height: spacing_standard,
                                                                    ),

                                                                    // SizedBox(
                                                                    //   height: spacing_standard,
                                                                    // ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Divider(
                                                                color: Colors.grey,
                                                              ),
                                                              Row(
                                                                children: <Widget>[

                                                                  Expanded(
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        if(_isButton==true)
                                                                        {
                                                                          // FlashHelper.errorBar(context, message: "Enter Quantity is Grather Then Order Quantity");
                                                                        }
                                                                        else
                                                                        {
                                                                          if (_isLoading == false) {
                                                                            final form = formKey.currentState;
                                                                            if (form.validate()) {
                                                                              setState(() => _isLoading = true);
                                                                              form.save();
                                                                              _netUtil.post(
                                                                                  RestDatasource.DELIVERYBOY_ORDER_STATUS, body: {
                                                                                'action': "not_delivered_qty",
                                                                                'user_id': data.user_id,
                                                                                'oc_id': data.oc_id,
                                                                                "order_one_unit_price": data.user_type=="1"?data.product_regular_price.toString():data.product_normal_price.toString(),
                                                                                "order_qty": data.order_qty.toString(),
                                                                                "not_delivered_qty": _number.toString(),
                                                                              }).then((dynamic res) async {
                                                                                Navigator.pop(context,false);
                                                                                if (res["status"] == "yes") {
                                                                                  if(res["check"] == "1")
                                                                                  {
                                                                                    Navigator.of(context).pushReplacementNamed("/order");
                                                                                  }
                                                                                  formKey.currentState.reset();
                                                                                  _refresh1();

                                                                                  // FlashHelper.successBar(context, message: res["message"]);
                                                                                  setState(() => _isLoading = false);
                                                                                }
                                                                                else {
                                                                                  // FlashHelper.errorBar(context, message: res["message"]);
                                                                                  setState(() => _isLoading = false);
                                                                                }
                                                                              });
                                                                            }
                                                                          }
                                                                        }
                                                                          _refresh1();
                                                                      },
                                                                      child: Container(
                                                                        padding: EdgeInsets
                                                                            .fromLTRB(
                                                                            10, 10, 10, 15),
                                                                        alignment: Alignment
                                                                            .center,
                                                                        child:
                                                                        // _isButton==true?Text("Wrong Quantity",
                                                                        //   style: TextStyle(
                                                                        //       color: maincolor,
                                                                        //       fontSize: 15),
                                                                        // ):
                                                                        Text("Ohk",
                                                                          style: TextStyle(
                                                                              color: maincolor,
                                                                              fontSize: 15),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top:0.0,
                                                        right: 0.0,
                                                        child: new IconButton(
                                                            icon: Icon(Icons.cancel,color: maincolor,size: textSizeLarge,),
                                                            onPressed: () {
                                                              Navigator.pop(context,false);
                                                            }),
                                                      )
                                                    ],
                                                  ),
                                                )
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                              secondaryActions: <Widget>[

                                data.oc_is_delivered=="1" || data.oc_is_delivered=="2"?SizedBox():Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    // elevation: 2.0,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                        bottomLeft: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    margin: new EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 0.0),
                                    child: IconSlideAction(
                                      caption: 'Delivered',
                                      icon: Icons.done,
                                      color: maincolor,
                                        onTap: () {


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
                                                                        Text("Make Order Delivered", style: TextStyle(color: Colors.white,fontSize: 18)),
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
                                                                                    data.product_name==null?"":data.product_name,
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

                                                                                  Row(
                                                                                    children: [
                                                                                      Text(
                                                                                        "Price : ",
                                                                                        style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: greencolor),
                                                                                      ),
                                                                                      Flexible(
                                                                                        child: Text(
                                                                                          data.order_one_unit_price==null?"":data.order_one_unit_price,
                                                                                          style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: greencolor),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),

                                                                                  SizedBox(
                                                                                    height: spacing_control,
                                                                                  ),

                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),

                                                                        SizedBox(height: 10,),
                                                                        Text("Select Delivered Quantity"),
                                                                        SizedBox(height: 10,),


                                                                        Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [

                                                                            InkWell(
                                                                              onTap: (){
                                                                                setState(() {
                                                                                  // int.parse(price);

                                                                                  if(data.order_qty_int <= 1)
                                                                                  {
                                                                                    // data.order_qty_int = data.order_qty_int;
                                                                                  }
                                                                                  else
                                                                                  {
                                                                                  data.order_qty_int = data.order_qty_int-1;
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
                                                                              child: Text(data.order_qty_int.toString(),
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
                                                                                  data.order_qty_int = data.order_qty_int+1;
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

                                                                                      // FlashHelper.errorBar(context, message: cutoff_time);

                                                                                    if (_isLoading == false) {
                                                                                      setState(() => _isLoading = true);
                                                                                      _netUtil.post(
                                                                                          RestDatasource.DELIVERYBOY_ORDER_STATUS, body: {
                                                                                        'action': "delivered_qty",
                                                                                        'user_id': data.user_id,
                                                                                        'oc_id': data.oc_id,
                                                                                        "order_one_unit_price": data.user_type=="1"?data.product_regular_price.toString():data.product_normal_price.toString(),
                                                                                        "order_qty": data.order_qty_int.toString(),
                                                                                      }).then((dynamic res) async {
                                                                                        // Navigator.pop(context,false);
                                                                                        if (res["status"] == "yes") {
                                                                                          if(res["check"] == "1")
                                                                                          {
                                                                                            Navigator.of(context).pushReplacementNamed("/order");
                                                                                          }
                                                                                          // FlashHelper.successBar(context, message: res["message"]);
                                                                                          setState(() => _isLoading = false);
                                                                                          _refresh1();
                                                                                          Navigator.pop(context,false);
                                                                                        }
                                                                                        else {
                                                                                          // FlashHelper.errorBar(context, message: res["message"]);
                                                                                          setState(() => _isLoading = false);
                                                                                        }
                                                                                      });
                                                                                    }
                                                                                    _refresh1();

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
                                                                                    child: Text("Delivered".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
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


                                          // showDialog(
                                          //     context: context,
                                          //     builder: (context) =>
                                          //         Dialog(
                                          //           backgroundColor: Colors.white,
                                          //           child: Stack(
                                          //             children: [
                                          //               SingleChildScrollView(
                                          //                 child: Container(
                                          //                   child: Column(
                                          //                     crossAxisAlignment: CrossAxisAlignment
                                          //                         .start,
                                          //                     mainAxisSize: MainAxisSize.min,
                                          //                     children: <Widget>[
                                          //                       Container(
                                          //                         padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                          //                         child: Column(
                                          //                           crossAxisAlignment: CrossAxisAlignment
                                          //                               .start,
                                          //                           children: <Widget>[
                                          //                             SvgPicture.asset('images/path.svg',width: MediaQuery.of(context).size.width * 0.65,),
                                          //                             SizedBox(
                                          //                               height: spacing_standard,
                                          //                             ),
                                          //
                                          //                             Form(
                                          //                               key: formKey,
                                          //                               child: Column(
                                          //                                 children: [
                                          //                                   TextFormField(
                                          //                                     initialValue: null,
                                          //                                     obscureText: false,
                                          //                                     keyboardType: TextInputType.number,
                                          //                                     onSaved: (val) {
                                          //                                       setState(() {
                                          //                                         _number = val;
                                          //                                         newnumber = double.parse(_number);
                                          //
                                          //                                         newqty = double.parse(data.order_qty);
                                          //                                       });
                                          //                                     },
                                          //                                     onChanged: (val) {
                                          //                                       setState(() {
                                          //                                         _number = val;
                                          //                                         newnumber = double.parse(_number);
                                          //
                                          //                                         newqty = double.parse(data.order_qty);
                                          //                                       });
                                          //                                     },
                                          //                                     validator: (val) {
                                          //                                       return val.length <= 0
                                          //                                           ? "Please Enter Delivered Product Number"
                                          //                                           : null;
                                          //                                     },
                                          //                                     decoration: InputDecoration(
                                          //                                       hintText: "Delivered Product Quantity",
                                          //                                       labelStyle: TextStyle(color: maincolor),
                                          //                                       filled: false,
                                          //                                       focusedBorder: OutlineInputBorder(
                                          //                                           borderSide: BorderSide(width: 1, color: maincolor)
                                          //                                       ),
                                          //                                       border: OutlineInputBorder(
                                          //                                           borderSide: BorderSide()
                                          //                                       ),
                                          //                                       //fillColor: Colors.red.shade50,
                                          //                                       contentPadding: EdgeInsets.all(12),
                                          //                                     ),
                                          //                                   ),
                                          //                                 ],
                                          //                               ),
                                          //                             ),
                                          //                             // Align(
                                          //                             //     alignment: Alignment.center,
                                          //                             //     child: Text(res["message"], style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold),)
                                          //                             // ),
                                          //
                                          //                             SizedBox(
                                          //                               height: spacing_standard,
                                          //                             ),
                                          //
                                          //                             // SizedBox(
                                          //                             //   height: spacing_standard,
                                          //                             // ),
                                          //                           ],
                                          //                         ),
                                          //                       ),
                                          //                       Divider(
                                          //                         color: Colors.grey,
                                          //                       ),
                                          //                       Row(
                                          //                         children: <Widget>[
                                          //
                                          //                           Expanded(
                                          //                             child: InkWell(
                                          //                               onTap: () {
                                          //
                                          //                                 if (_isLoading == false) {
                                          //                                   setState(() => _isLoading = true);
                                          //                                   _netUtil.post(
                                          //                                       RestDatasource.DELIVERYBOY_ORDER_STATUS, body: {
                                          //                                     'action': "delivered_qty",
                                          //                                     'user_id': data.user_id,
                                          //                                     'oc_id': data.oc_id,
                                          //                                     "order_one_unit_price": data.user_type=="1"?data.product_regular_price.toString():data.product_normal_price.toString(),
                                          //                                     "order_qty": _number.toString(),
                                          //                                   }).then((dynamic res) async {
                                          //                                     // Navigator.pop(context,false);
                                          //                                     if (res["status"] == "yes") {
                                          //                                       if(res["check"] == "1")
                                          //                                       {
                                          //                                         Navigator.of(context).pushReplacementNamed("/order");
                                          //                                       }
                                          //                                       // FlashHelper.successBar(context, message: res["message"]);
                                          //                                       setState(() => _isLoading = false);
                                          //                                       _refresh1();
                                          //                                     }
                                          //                                     else {
                                          //                                       // FlashHelper.errorBar(context, message: res["message"]);
                                          //                                       setState(() => _isLoading = false);
                                          //                                     }
                                          //                                   });
                                          //                                 }
                                          //                                 _refresh1();
                                          //                               },
                                          //                               child: Container(
                                          //                                 padding: EdgeInsets
                                          //                                     .fromLTRB(
                                          //                                     10, 10, 10, 15),
                                          //                                 alignment: Alignment
                                          //                                     .center,
                                          //                                 child:
                                          //                                 // _isButton==true?Text("Wrong Quantity",
                                          //                                 //   style: TextStyle(
                                          //                                 //       color: maincolor,
                                          //                                 //       fontSize: 15),
                                          //                                 // ):
                                          //                                 Text("Ohk",
                                          //                                   style: TextStyle(
                                          //                                       color: maincolor,
                                          //                                       fontSize: 15),
                                          //                                 ),
                                          //                               ),
                                          //                             ),
                                          //                           ),
                                          //                         ],
                                          //                       )
                                          //                     ],
                                          //                   ),
                                          //                 ),
                                          //               ),
                                          //               Positioned(
                                          //                 top:0.0,
                                          //                 right: 0.0,
                                          //                 child: new IconButton(
                                          //                     icon: Icon(Icons.cancel,color: maincolor,size: textSizeLarge,),
                                          //                     onPressed: () {
                                          //                       Navigator.pop(context,false);
                                          //                     }),
                                          //               )
                                          //             ],
                                          //           ),
                                          //         )
                                          // );



                                        },
                                    ),
                                  ),
                                ),
                              ],
                              actionExtentRatio: 1/5,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: whitecolor,
                                  // gradient: LinearGradient(
                                  //   begin: Alignment.topLeft,
                                  //   end: Alignment.bottomRight,
                                  //   colors:
                                  //   [
                                  //     // Color(0xFF0E50F6).withOpacity(0.3),
                                  //     // Color(0xFFFFFFFF).withOpacity(0.2),
                                  //     Color(0xFF0E50F6).withOpacity(1),
                                  //     Color(0xFF0E50F6).withOpacity(0.5),
                                  //   ],
                                  //   stops: [0.1, 2],),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors:
                                    [
                                      Color(0xFF0E50F6).withOpacity(0.3),
                                      Color(0xFFFFFFFF).withOpacity(0.2),
                                      // _color.withOpacity(0.3),
                                      // _color2.withOpacity(0.2),
                                    ],
                                    stops: [0.5, 2],),
                                ),
                                margin: new EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 5.0),

                                child: data.oc_is_delivered=="1"?
                                InkWell(
                                  onTap: ()
                                  {

                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                    child: Row(
                                      children: [
                                        (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 80, height: 80,)):ClipOval(child: new Image.asset('images/logo.png', width: 80, height: 80,)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data.product_name==""?"":data.product_name,
                                                style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700, color: maincolor),
                                              ),
                                              SizedBox(
                                                height: spacing_control,
                                              ),
                                              Text(
                                                data.order_qty.toString()==""?"":data.order_qty.toString()+" Quantity",
                                                style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w500, color: blackcolor),
                                              ),
                                              SizedBox(
                                                height: spacing_control,
                                              ),
                                              data.oc_is_delivered!="1"?Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.order_instructions==""?"No Instruction":" Instruction : "+data.order_instructions,
                                                    style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w400, color: blackcolor),
                                                  ),
                                                  SizedBox(
                                                    height: spacing_control,
                                                  ),
                                                  data.order_ring_bell=="1"?Icon(Icons.notifications,size:textSizeLargeMedium,color: maincolor,):Icon(Icons.notifications_off,size:textSizeLargeMedium,color:redcolor,),
                                                ],
                                              ):
                                              data.not_delivered_qty!="0"?
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
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
                                                          Color(0xFF1638E0).withOpacity(0.4),
                                                          Color(0xFF1638E0).withOpacity(0.8),
                                                        ],
                                                        stops: [0.1, 2],),

                                                    ),
                                                    // color : maincolor,
                                                    child: Padding(
                                                      padding: const EdgeInsets.fromLTRB(7,5,7,5),
                                                      child: Text(
                                                        "Delivered : "+data.delivered_qty,
                                                        style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w400, color: whitecolor),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: spacing_control,
                                                  ),
                                                  Container(
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
                                                          Color(0xFFFF5722).withOpacity(0.4),
                                                          Color(0xFFFF5722).withOpacity(0.8),
                                                        ],
                                                        stops: [0.1, 2],),

                                                    ),
                                                    // color : maincolor,
                                                    child: Padding(
                                                      padding: const EdgeInsets.fromLTRB(7,5,7,5),
                                                      child: Text(
                                                        "Not Delivered : "+data.not_delivered_qty,
                                                        style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w400, color: whitecolor),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ):
                                              Container(
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
                                                      Color(0xFF1638E0).withOpacity(0.4),
                                                      Color(0xFFFF5722).withOpacity(0.8),
                                                    ],
                                                    stops: [0.1, 2],),

                                                ),
                                                // color : maincolor,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(7,5,7,5),
                                                  child: Text(
                                                    "Delivered",
                                                    style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w400, color: whitecolor),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ):
                                InkWell(
                                  onTap: ()
                                  {

                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                    child: Row(
                                      children: [
                                        (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 80, height: 80,)):ClipOval(child: new Image.asset('images/logo.png', width: 80, height: 80,)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data.product_name==""?"":data.product_name,
                                                style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700, color: maincolor),
                                              ),
                                              SizedBox(
                                                height: spacing_control,
                                              ),
                                              Text(
                                                data.order_qty.toString()==""?"":data.order_qty.toString()+" Quantity",
                                                style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w500, color: blackcolor),
                                              ),
                                              SizedBox(
                                                height: spacing_control,
                                              ),
                                              data.oc_is_delivered!="1"?Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.order_instructions==""?"No Instruction":" Instruction : "+data.order_instructions,
                                                    style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w400, color: blackcolor),
                                                  ),
                                                  SizedBox(
                                                    height: spacing_control,
                                                  ),
                                                  data.order_ring_bell=="1"?Icon(Icons.notifications,size:textSizeLargeMedium,color: maincolor,):Icon(Icons.notifications_off,size:textSizeLargeMedium,color:redcolor,),
                                                ],
                                              ):
                                              Container(
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
                                                      Color(0xFF1638E0).withOpacity(0.4),
                                                      Color(0xFFFF5722).withOpacity(0.8),
                                                    ],
                                                    stops: [0.1, 2],),

                                                ),
                                                // color : maincolor,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(7,5,7,5),
                                                  child: Text(
                                                    "Delivered",
                                                    style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w400, color: whitecolor),
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
                              ),
                            ),
                        ).toList(),
                      );
                    },
                  ),
                ),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: <Widget>[
                //
                //     Container(
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.only(
                //             topRight: Radius.circular(20.0),
                //             bottomRight: Radius.circular(5.0),
                //             topLeft: Radius.circular(20.0),
                //             bottomLeft: Radius.circular(5.0)),
                //         // color: blackcolor,
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                //         child: Row(
                //           children: [
                //             Expanded(
                //               child: InkWell(
                //                 onTap: ()
                //                 {
                //                   if (_isLoading == false) {
                //                     setState(() => _isLoading = true);
                //                     _netUtil.post(
                //                         RestDatasource.DELIVERYBOY_ORDER_STATUS, body: {
                //                       'action': "user_order_calendar_status",
                //                       'user_id': user_id,
                //                       "date": DateFormat('yyy-MM-d').format(currentDate).toString(),
                //                     }).then((dynamic res) async {
                //                       Navigator.pop(context,false);
                //                       if (res["status"] == "yes") {
                //                         FlashHelper.successBar(context, message: res["message"]);
                //                         setState(() => _isLoading = false);
                //                         Navigator.of(context).pushReplacementNamed("/order");
                //                       }
                //                       else {
                //                         FlashHelper.errorBar(context, message: res["message"]);
                //                         setState(() => _isLoading = false);
                //                       }
                //                     });
                //                   }
                //                   // _refresh1();
                //                 },
                //                 child: Container(
                //                   decoration: BoxDecoration(
                //                     borderRadius: BorderRadius.only(
                //                       topLeft: Radius.circular(5.0),
                //                       topRight: Radius.circular(5.0),
                //                       bottomLeft: Radius.circular(5.0),
                //                       bottomRight: Radius.circular(5.0),
                //                     ),
                //                     color: maincolor,
                //                     boxShadow: [
                //                       BoxShadow(
                //                           spreadRadius: 1,
                //                           blurRadius: 2,
                //                           offset: Offset(-0, -2),
                //                           color: Colors.white10// shadow direction: bottom right
                //                       ),
                //                       BoxShadow(
                //                         color: Colors.black38,
                //                         blurRadius: 2.0,
                //                         spreadRadius: 0.0,
                //                         offset: Offset(2.0, 2.0), // shadow direction: bottom right
                //                       )
                //                     ],
                //                   ),
                //                   padding: EdgeInsets.symmetric(
                //                       vertical: 15,
                //                       horizontal: 10),
                //                   alignment: Alignment.center,
                //                   child: Row(
                //                     crossAxisAlignment: CrossAxisAlignment.center,
                //                     mainAxisAlignment: MainAxisAlignment.center,
                //                     children: [
                //                       Text("confirm".toUpperCase(),
                //                         style: TextStyle(
                //                             color: Colors.white,fontSize: 14.0,fontWeight: FontWeight.bold),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             ),
                //
                //           ],
                //         ),
                //       ),
                //     ),
                //     SizedBox(
                //       height: spacing_middle,
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      );
    }
  }


}
