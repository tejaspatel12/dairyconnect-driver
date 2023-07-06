import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nooranidairyfarm_deliveryboy/models/user.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_balance_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_order_screen.dart';
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

class UserScreen extends StatefulWidget {
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  BuildContext _ctx;

  RestDatasource api = new RestDatasource();
  NetworkUtil _netUtil = new NetworkUtil();
  String loggedinname = "";
  String deliveryboy_id="",_number;
  int num = 0;
  int i = 1;

  bool _isLoading= false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<List<Users>> userdata;
  Future<List<Users>> filterData;
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

  Future<List<Users>> _getData() async
  {
    return _netUtil.post(RestDatasource.USER,
        body:{
          'deliveryboy_id': deliveryboy_id,
        }
    ).then((dynamic res) {
      final items = res.cast<Map<String, dynamic>>();
      print(items);
      List<Users> listofusers = items.map<Users>((json) {
        return Users.fromJson(json);
      }).toList();
      List<Users> revdata = listofusers.toList();
      return revdata;
    });
  }

  Future<List<Users>> _refresh() async
  {
    setState(() {
      userdata = _getData();
      filterData=userdata;
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
        Future<List<Users>> items=userdata;
        List<Users> filter=new List<Users>();
        items.then((result){
          for(var record in result)
          {

            if(record.user_first_name.toLowerCase().toString().contains(searchQuery.toLowerCase()) || record.user_last_name.toLowerCase().toString().contains(searchQuery.toLowerCase()) || record.user_mobile_number.toLowerCase().toString().contains(searchQuery.toLowerCase()))
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
  Future<List<Users>> _refresh1() async
  {
    setState(() {
      userdata = _getData();
      filterData=userdata;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed("/adduser");
          },
          label: const Text('Add User',style: TextStyle(color: whitecolor),),
          icon: const Icon(Icons.add,color: whitecolor,),
          backgroundColor: maincolor,
        ),
        // backgroundColor: blackcolor,
        backgroundColor: shadecolor,
        body: SafeArea(
          child: new NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  centerTitle: true,
                  title: _isSearching ? _buildSearchField() : RichText(
                    text: TextSpan(
                        text: "Users".toUpperCase(),
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
                  onRefresh: _refresh,
                  child: FutureBuilder<List<Users>>(
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

                                Padding(
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
                                      caption: 'Order',
                                      icon: Icons.shopping_bag,
                                      color: maincolor,
                                      onTap: (){
                                        // Navigator.of(context).pushNamed("/userorder",
                                        //     arguments: {
                                        //       "user_id" : data.user_id,
                                        //       "user_first_name" : data.user_first_name,
                                        //       "user_last_name" : data.user_last_name,
                                        //     });

                                        Navigator.push(context,
                                            MaterialPageRoute(
                                              builder: (context) => UserOrderScreen(user_id: data.user_id,user_first_name: data.user_first_name,user_last_name: data.user_last_name,),
                                            ));

                                        // Navigator.of(context).pushNamed("/userorder",
                                        //     arguments: {
                                        //       "user_id" : data.user_id,
                                        //       "user_first_name" : data.user_first_name,
                                        //       "user_last_name" : data.user_last_name,
                                        //     });
                                      },
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                //   child: Card(
                                //     semanticContainer: true,
                                //     clipBehavior: Clip.antiAliasWithSaveLayer,
                                //     // elevation: 2.0,
                                //     shape: RoundedRectangleBorder(
                                //       side: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                //       borderRadius: BorderRadius.only(
                                //         topLeft: Radius.circular(20.0),
                                //         topRight: Radius.circular(20.0),
                                //         bottomLeft: Radius.circular(20.0),
                                //         bottomRight: Radius.circular(20.0),
                                //       ),
                                //     ),
                                //     margin: new EdgeInsets.symmetric(
                                //         horizontal: 0.0, vertical: 0.0),
                                //     child: IconSlideAction(
                                //       caption: 'Log',
                                //       icon: Icons.timelapse_outlined,
                                //       color: maincolor,
                                //       onTap: (){
                                //         Navigator.of(context).pushNamed("/userorderlogdetail",
                                //             arguments: {
                                //               "user_id" : data.user_id,
                                //               // "user_name" : data.user_name,
                                //             }
                                //         );
                                //       },
                                //     ),
                                //   ),
                                // ),
                              ],

                              secondaryActions: <Widget>[

                                Padding(
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
                                      caption: 'Balance',
                                      icon: Icons.account_balance_wallet_outlined,
                                      color: maincolor,
                                      onTap: (){
                                        // Navigator.of(context).pushNamed("/userbalance",
                                        //     arguments: {
                                        //       "user_id" : data.user_id,
                                        //       "user_first_name" : data.user_first_name,
                                        //       "user_last_name" : data.user_last_name,
                                        //     }
                                        // );

                                        Navigator.push(context,
                                            MaterialPageRoute(
                                              builder: (context) => UserBalanceListScreen(user_id: data.user_id,user_first_name:data.user_first_name,user_last_name:data.user_last_name, user_balance:data.user_balance),
                                            ));

                                      },
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                //   child: Card(
                                //     semanticContainer: true,
                                //     clipBehavior: Clip.antiAliasWithSaveLayer,
                                //     // elevation: 2.0,
                                //     shape: RoundedRectangleBorder(
                                //       side: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                //       borderRadius: BorderRadius.only(
                                //         topLeft: Radius.circular(20.0),
                                //         topRight: Radius.circular(20.0),
                                //         bottomLeft: Radius.circular(20.0),
                                //         bottomRight: Radius.circular(20.0),
                                //       ),
                                //     ),
                                //     margin: new EdgeInsets.symmetric(
                                //         horizontal: 0.0, vertical: 0.0),
                                //     child: IconSlideAction(
                                //       caption: 'Sequence',
                                //       icon: Icons.format_list_numbered,
                                //       color: maincolor,
                                //       onTap: (){
                                //         showDialog(
                                //             context: context,
                                //             builder: (context) =>
                                //                 Dialog(
                                //                   backgroundColor: Colors.white,
                                //                   child: Stack(
                                //                     children: [
                                //                       SingleChildScrollView(
                                //                         child: Container(
                                //                           child: Column(
                                //                             crossAxisAlignment: CrossAxisAlignment
                                //                                 .start,
                                //                             mainAxisSize: MainAxisSize.min,
                                //                             children: <Widget>[
                                //                               Container(
                                //                                 padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                //                                 child: Column(
                                //                                   crossAxisAlignment: CrossAxisAlignment
                                //                                       .start,
                                //                                   children: <Widget>[
                                //                                     // Lottie.asset(
                                //                                     //   'assets/done.json',
                                //                                     //   repeat: true,
                                //                                     //   reverse: true,
                                //                                     //   animate: true,
                                //                                     // ),
                                //                                     SvgPicture.asset('images/path.svg',width: MediaQuery.of(context).size.width * 0.65,),
                                //                                     SizedBox(
                                //                                       height: spacing_standard,
                                //                                     ),
                                //
                                //                                     Form(
                                //                                       key: formKey,
                                //                                       child: Column(
                                //                                         children: [
                                //                                           TextFormField(
                                //                                             initialValue: null,
                                //                                             obscureText: false,
                                //                                             keyboardType: TextInputType.number,
                                //                                             onSaved: (val) {
                                //                                               setState(() {
                                //                                                 _number = val;
                                //                                               });
                                //                                             },
                                //                                             onChanged: (val) {
                                //                                               setState(() {
                                //                                                 _number = val;
                                //                                               });
                                //                                             },
                                //                                             validator: (val) {
                                //                                               return val.length <= 0
                                //                                                   ? "Please Enter Sequence Number"
                                //                                                   : null;
                                //                                             },
                                //                                             decoration: InputDecoration(
                                //                                               hintText: "Sequence Number",
                                //                                               labelStyle: TextStyle(color: maincolor),
                                //                                               filled: false,
                                //                                               focusedBorder: OutlineInputBorder(
                                //                                                   borderSide: BorderSide(width: 1, color: maincolor)
                                //                                               ),
                                //                                               border: OutlineInputBorder(
                                //                                                   borderSide: BorderSide()
                                //                                               ),
                                //                                               //fillColor: Colors.red.shade50,
                                //                                               contentPadding: EdgeInsets.all(12),
                                //                                             ),
                                //                                           ),
                                //                                         ],
                                //                                       ),
                                //                                     ),
                                //                                     // Align(
                                //                                     //     alignment: Alignment.center,
                                //                                     //     child: Text(res["message"], style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold),)
                                //                                     // ),
                                //
                                //                                     SizedBox(
                                //                                       height: spacing_standard,
                                //                                     ),
                                //
                                //
                                //                                     Align(
                                //                                       alignment: Alignment.center,
                                //                                       child: Text("Sequence Number (ex. 1,2,3,...)",
                                //                                         style: TextStyle(
                                //                                           fontSize: textSizeSmall,
                                //                                         ),
                                //                                       ),
                                //                                     ),
                                //                                     // SizedBox(
                                //                                     //   height: spacing_standard,
                                //                                     // ),
                                //                                   ],
                                //                                 ),
                                //                               ),
                                //                               Divider(
                                //                                 color: Colors.grey,
                                //                               ),
                                //                               Row(
                                //                                 children: <Widget>[
                                //
                                //                                   Expanded(
                                //                                     child: InkWell(
                                //                                       onTap: () {
                                //
                                //                                         if (_isLoading == false) {
                                //                                           final form = formKey.currentState;
                                //                                           if (form.validate()) {
                                //                                             setState(() => _isLoading = true);
                                //                                             form.save();
                                //                                             _netUtil.post(
                                //                                                 RestDatasource.DELIVERYBOY_USER_SORT, body: {
                                //                                               "deliveryboy_id": deliveryboy_id,
                                //                                               "sorting_no": _number.toString(),
                                //                                               "user_id": data.user_id,
                                //                                             }).then((dynamic res) async {
                                //                                               Navigator.pop(context,false);
                                //                                               if (res["status"] == "yes") {
                                //                                                 formKey.currentState.reset();
                                //                                                 _refresh1();
                                //
                                //                                                 // FlashHelper.successBar(context, message: res["message"]);
                                //                                                 setState(() => _isLoading = false);
                                //                                               }
                                //                                               else {
                                //                                                 // FlashHelper.errorBar(context, message: res["message"]);
                                //                                                 setState(() => _isLoading = false);
                                //                                               }
                                //                                             });
                                //                                           }
                                //                                         }
                                //                                         _refresh1();
                                //                                       },
                                //                                       child: Container(
                                //                                         padding: EdgeInsets
                                //                                             .fromLTRB(
                                //                                             10, 10, 10, 15),
                                //                                         alignment: Alignment
                                //                                             .center,
                                //                                         child: Text("Ohk",
                                //                                           style: TextStyle(
                                //                                               color: maincolor,
                                //                                               fontSize: 15),
                                //                                         ),
                                //                                       ),
                                //                                     ),
                                //                                   ),
                                //                                 ],
                                //                               )
                                //                             ],
                                //                           ),
                                //                         ),
                                //                       ),
                                //                       Positioned(
                                //                         top:0.0,
                                //                         right: 0.0,
                                //                         child: new IconButton(
                                //                             icon: Icon(Icons.cancel,color: maincolor,size: textSizeLarge,),
                                //                             onPressed: () {
                                //                               Navigator.pop(context,false);
                                //                             }),
                                //                       )
                                //                     ],
                                //                   ),
                                //                 )
                                //         );
                                //       },
                                //     ),
                                //   ),
                                // ),
                              ],
                              actionExtentRatio: 1/5,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
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
                                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                      child: Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    data.user_first_name==""?"":data.user_first_name+ " ",
                                                    style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700, color: maincolor),
                                                  ),
                                                  Text(
                                                    data.user_last_name==""?"":data.user_last_name+ " ",
                                                    style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700, color: maincolor),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: spacing_control,
                                              ),
                                              Text(
                                                "+44 "+data.user_mobile_number,
                                                style: TextStyle(fontSize: textSizeMMedium,fontWeight: FontWeight.w600, color: blackcolor),
                                              ),
                                              SizedBox(
                                                height: spacing_control,
                                              ),
                                              Text(
                                                data.area_name==null?"":data.area_name,
                                                style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w500, color: greencolor),
                                              ),

                                              data.user_time!="0"?Column(
                                                children: [
                                                  SizedBox(
                                                    height: spacing_control,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        data.time_slot_name==null?"":data.time_slot_name,
                                                        style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w500, color: redcolor),
                                                      ),
                                                    ],
                                                  ),

                                                ],
                                              ):
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: spacing_control,
                                                  ),
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
                                                                                    Text("Add Delivery Time", style: TextStyle(color: Colors.white,fontSize: 18)),
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
                                                                              child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [

                                                                                  Expanded(
                                                                                    child: GestureDetector(
                                                                                      onTap:(){
                                                                                        _netUtil.post(
                                                                                            RestDatasource.GET_DELIVEYBOY, body: {
                                                                                          'action': "is_set_batch",
                                                                                          'user_id': data.user_id,
                                                                                          'time': "Morning Batch",
                                                                                        }).then((dynamic res) async {
                                                                                          // print("Web Output"+res["status"]);
                                                                                          if (res["status"] == "yes") {
                                                                                            _refresh();
                                                                                            Navigator.of(context).pop();
                                                                                            Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: maincolor, fontSize: 12.0);
                                                                                          }
                                                                                          else {
                                                                                            _refresh();
                                                                                            Navigator.of(context).pop();
                                                                                            Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 12.0);

                                                                                          }
                                                                                        });
                                                                                      },
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                                          color: redcolor

                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                                                                          child: Center(
                                                                                            child: Text(
                                                                                              "Morning Batch",
                                                                                              style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400, color: whitecolor),
                                                                                            ),
                                                                                          ),
                                                                                        ),),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                                                                  Expanded(
                                                                                    child: GestureDetector(
                                                                                      onTap:(){
                                                                                        _netUtil.post(
                                                                                            RestDatasource.GET_DELIVEYBOY, body: {
                                                                                          'action': "is_set_batch",
                                                                                          'user_id': data.user_id,
                                                                                          'time': "Evening Batch",
                                                                                        }).then((dynamic res) async {
                                                                                          // print("Web Output"+res["status"]);
                                                                                          if (res["status"] == "yes") {
                                                                                            _refresh();
                                                                                            Navigator.of(context).pop();
                                                                                            Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: maincolor, fontSize: 12.0);
                                                                                          }
                                                                                          else {
                                                                                            _refresh();
                                                                                            Navigator.of(context).pop();
                                                                                            Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 12.0);

                                                                                          }
                                                                                        });
                                                                                      },
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                                          color: greencolor

                                                                                        ),
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                                                                          child: Center(
                                                                                            child: Text(
                                                                                              "Evening Batch",
                                                                                              style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400, color: whitecolor),
                                                                                            ),
                                                                                          ),
                                                                                        ),),
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
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                          // color: whitecolor
                                                        gradient: LinearGradient(
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          colors:
                                                          [

                                                            Color(0xFF0E50F6).withOpacity(1),
                                                            Color(0xFF0E50F6).withOpacity(0.5),
                                                            // Color(0xFFFFFFFF).withOpacity(0.2),
                                                            // Color(0xFF0E50F6).withOpacity(0.3),
                                                          ],
                                                          stops: [0.1, 2],),
                                                      ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(4.0),
                                                      child: Text(
                                                        "Add Delivery Time",
                                                        style: TextStyle(fontSize: 10,fontWeight: FontWeight.w400, color: whitecolor),
                                                      ),
                                                    ),),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(
                                                height: spacing_control,
                                              ),
                                              Text(
                                                data.user_address==null?"":"Address : "+data.user_address,
                                                style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w400, color: blackcolor),
                                              ),

                                            ],
                                          ),

                                          Positioned(right: 0, child: GestureDetector(onTap: (){
                                            Fluttertoast.showToast(msg: data.user_status=="1"?"Active User":"In-Active User" , toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, fontSize: 12);
                                          }, child: Icon(Icons.circle,color: data.user_status=="1"?greencolor:redcolor,))),

                                          Positioned(left: 0, right: 0, child: Image.asset(data.time_slot_name=="Morning Batch"?'images/sun.png':data.time_slot_name=="Evening Batch"?'images/moon.png':'images/null.png',height: MediaQuery.of(context).size.width * 0.2,opacity: const AlwaysStoppedAnimation(.3))),


                                        ],
                                      ),
                                    ),
                                  ),

                                  Positioned(right: 20, bottom: 60, child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context,
                                          MaterialPageRoute(
                                            builder: (context) => UserBalanceListScreen(user_id: data.user_id,user_first_name:data.user_first_name,user_last_name:data.user_last_name, user_balance:data.user_balance),
                                          ));

                                      // Navigator.of(context).pushNamed("/userbalance",
                                      //     arguments: {
                                      //       "user_id" : data.user_id,
                                      //       "user_first_name" : data.user_first_name,
                                      //       "user_last_name" : data.user_last_name,
                                      //     }
                                      // );
                                    },
                                    child: Text(
                                      data.user_balance==""?"":"₹ "+data.user_balance,
                                      style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.w800, color: data.user_balance=="0.00"?Color(0xFFF44336).withOpacity(0.7):Color(0xFF1638E0).withOpacity(0.7)),
                                    ),
                                  )),
                                  Positioned(right: 16, bottom: 6, child: GestureDetector(
                                    onTap: ()
                                    {

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
                                                                  // Lottie.asset(
                                                                  //   'assets/done.json',
                                                                  //   repeat: true,
                                                                  //   reverse: true,
                                                                  //   animate: true,
                                                                  // ),
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
                                                                            });
                                                                          },
                                                                          onChanged: (val) {
                                                                            setState(() {
                                                                              _number = val;
                                                                            });
                                                                          },
                                                                          validator: (val) {
                                                                            return val.length <= 0
                                                                                ? "Please Enter Sequence Number"
                                                                                : null;
                                                                          },
                                                                          decoration: InputDecoration(
                                                                            hintText: "Sequence Number",
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


                                                                  Align(
                                                                    alignment: Alignment.center,
                                                                    child: Text("Sequence Number (ex. 1,2,3,...)",
                                                                      style: TextStyle(
                                                                        fontSize: textSizeSmall,
                                                                      ),
                                                                    ),
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

                                                                      if (_isLoading == false) {
                                                                        final form = formKey.currentState;
                                                                        if (form.validate()) {
                                                                          setState(() => _isLoading = true);
                                                                          form.save();
                                                                          _netUtil.post(
                                                                              RestDatasource.DELIVERYBOY_USER_SORT, body: {
                                                                            "deliveryboy_id": deliveryboy_id,
                                                                            "sorting_no": _number.toString(),
                                                                            "user_id": data.user_id,
                                                                          }).then((dynamic res) async {
                                                                            Navigator.pop(context,false);
                                                                            if (res["status"] == "yes") {
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
                                                                      _refresh1();
                                                                    },
                                                                    child: Container(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                          10, 10, 10, 15),
                                                                      alignment: Alignment
                                                                          .center,
                                                                      child: Text("Ohk",
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
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(0.0),
                                            bottomRight: Radius.circular(15.0),
                                            topLeft: Radius.circular(20.0),
                                            bottomLeft: Radius.circular(0.0)),
                                        color: maincolor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          data.sorting_no==""?"":data.sorting_no,
                                          style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w800, color: whitecolor),
                                        ),
                                      ),
                                    ),
                                  )),
                                  Positioned(left: 16, bottom: 6, child: GestureDetector(
                                    onTap: (){
                                      // data.user_time!="0"
                                      if(data.user_time==0)
                                      {
                                        Fluttertoast.showToast(msg: "User not asign with time", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, fontSize: 12);
                                      }
                                      else
                                      {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                              builder: (context) => UserOrderScreen(user_id: data.user_id,user_first_name:data.user_first_name,user_last_name:data.user_last_name),
                                            ));

                                        // Navigator.of(context).pushNamed("/userorder",
                                        //     arguments: {
                                        //       "user_id" : data.user_id,
                                        //       "user_first_name" : data.user_first_name,
                                        //       "user_last_name" : data.user_last_name,
                                        //     });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20.0),
                                            bottomRight: Radius.circular(0.0),
                                            topLeft: Radius.circular(0.0),
                                            bottomLeft: Radius.circular(15.0)),
                                        // color: Color(0xFFCBC3E3).withOpacity(0.5),
                                        color: redcolor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(Icons.shopping_bag,color: whitecolor,size: 20,),
                                      )
                                    ),
                                  )),
                                ],
                              ),
                            ),
                        ).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }


}
