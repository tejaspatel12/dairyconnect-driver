import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nooranidairyfarm_deliveryboy/models/product.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';

class InventoryScreen extends StatefulWidget {
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  BuildContext _ctx;

  // Timer _timer;
  // int _start = 30;
  // final Random _random = Random();
  //
  // Color _color = Color(0xFFFFFFFF);
  // Color _color2 = Color(0xFFFFFFFF);

  RestDatasource api = new RestDatasource();
  NetworkUtil _netUtil = new NetworkUtil();
  String loggedinname = "";
  String deliveryboy_id="",selected_time;
  DateTime currentDate;
  int num = 0;
  Future<List<ProductList>> userdata;
  Future<List<ProductList>> filterData;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  String searchQuery = "Search query";

  _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deliveryboy_id = prefs.getString("deliveryboy_id") ?? '';
      selected_time = prefs.getString("selected_time") ?? '';
      num = 1;
      loggedinname= prefs.getString("name") ?? '';
      userdata = _getData();
      filterData=userdata;
    });
  }

  Future<List<ProductList>> _getData() async
  {
    return _netUtil.post(RestDatasource.DELIVERYBOY_INVENTORY,
        body:{
          'deliveryboy_id': deliveryboy_id,
          'deliveryboy_time': selected_time,
          "date": DateFormat('yyy-MM-d').format(currentDate).toString(),
        }
    ).then((dynamic res) {
      final items = res.cast<Map<String, dynamic>>();
      List<ProductList> listofusers = items.map<ProductList>((json) {
        return ProductList.fromJson(json);
      }).toList();
      List<ProductList> revdata = listofusers.toList();
      return revdata;
    });
  }

  Future<List<ProductList>> _refresh() async
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
    currentDate = DateTime.now();
    super.initState();
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
    _searchQuery = new TextEditingController();
    // startTimer();
  }
  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  // void startTimer() {
  //   const oneSec = const Duration(seconds: 2);
  //   _timer = new Timer.periodic(
  //     oneSec,
  //         (Timer timer) {
  //       if (_start == 0) {
  //         setState(() {
  //           // _start = 10;
  //           timer.cancel();
  //         });
  //       } else {
  //         setState(() {
  //           print("_start : "+ _start.toString());
  //           _start--;
  //           _color = Color.fromARGB(
  //             //or with fromRGBO with fourth arg as _random.nextDouble(),
  //             _random.nextInt(256),
  //             _random.nextInt(256),
  //             _random.nextInt(256),
  //             _random.nextInt(256),
  //           );
  //           _color2 = Color.fromARGB(
  //             //or with fromRGBO with fourth arg as _random.nextDouble(),
  //             _random.nextInt(256),
  //             _random.nextInt(256),
  //             _random.nextInt(256),
  //             _random.nextInt(256),
  //           );
  //         });
  //       }
  //     },
  //   );
  // }
  //
  // @override
  // void dispose() {
  //   super.dispose();
  //   // _timer.cancel();
  // }

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
        Future<List<ProductList>> items=userdata;
        List<ProductList> filter=new List<ProductList>();
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
  Future<List<ProductList>> _refresh1() async
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
                        text: "Inventory".toUpperCase(),
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
                  child: FutureBuilder<List<ProductList>>(
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
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors:
                                  [
                                    Color(0xFF0E50F6).withOpacity(0.3),
                                    Color(0xFFFFFFFF).withOpacity(0.2),
                                  ],
                                  stops: [0.5, 2],),
                              ),
                              margin: new EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 5.0),

                              child: InkWell(
                                onTap: ()
                                {
                                  Fluttertoast.showToast(msg: data.product_name +" ( "+ data.order_qty+" Quantity )", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, fontSize: 12);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                  child: Row(
                                    children: [
                                      (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 80, height: 80,)):ClipOval(child: new Image.asset('images/logo.png', width: 80, height: 80,)),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data.product_name==""?"":data.product_name,
                                            style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w700, color: maincolor),
                                          ),
                                          SizedBox(
                                            height: spacing_standard,
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
                                                  Color(0xFF0E50F6).withOpacity(0.4),
                                                  Color(0xFFFF5722).withOpacity(0.8),
                                                ],
                                                stops: [0.2, 2],),

                                            ),
                                            // color : maincolor,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(7,5,7,5),
                                              child: Text(
                                                data.order_qty+" Quantity",
                                                style: TextStyle(fontSize: textSizeSmall,fontWeight: FontWeight.w700, color: whitecolor),
                                              ),
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
