import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:lottie/lottie.dart';
import 'package:nooranidairyfarm_deliveryboy/data/database_helper.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth.dart';

class DrawerNavigationBarController extends StatefulWidget {
  @override
  _DrawerNavigationBarControllerState createState() =>
      _DrawerNavigationBarControllerState();
}

class _DrawerNavigationBarControllerState
    extends State<DrawerNavigationBarController> implements AuthStateListener{


  String deliveryboy_id,deliveryboy_name="Patel",deliveryboy_mobile="1234567890";

  SharedPreferences prefs;
  // _loadPref() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // prefs = await SharedPreferences.getInstance();
  //   user_id= prefs.getString("user_id") ?? '';
  //   user_first_name= prefs.getString("user_first_name") ?? '';
  //   user_last_name= prefs.getString("user_last_name") ?? '';
  //   user_mobile_number= prefs.getString("user_mobile_number") ?? '';
  // }
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      deliveryboy_id= prefs.getString("deliveryboy_id") ?? '';
      deliveryboy_name= prefs.getString("deliveryboy_name") ?? '';
      deliveryboy_mobile= prefs.getString("deliveryboy_mobile") ?? '';
    });
    print("deliveryboy_id " + deliveryboy_id);
    print("deliveryboy_name " + deliveryboy_name);
    print("deliveryboy_mobile " + deliveryboy_mobile);
  }

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

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
            DrawerHeader(
            padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
            // child:  Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(user_first_name==""?"":user_first_name,
            //       style: TextStyle(
            //           color: Colors.white,fontSize: 14.0,fontWeight: FontWeight.bold),
            //     ),
            //     SizedBox(
            //       height: 10,
            //     ),
            //     Text(user_mobile_number==""?"":user_mobile_number,
            //       style: TextStyle(
            //           color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold),
            //     ),
            //   ],
            // ),

            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: Colors.white, // button color
                          child: Image.asset(
                            'images/logo.png',
                            width: MediaQuery.of(context).size.width * 0.15,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            // first_name+" "+ last_name,
                            "Welcome, "+deliveryboy_name,maxLines: 1,overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 22,fontWeight: FontWeight.w700, color: whitecolor),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "+91"+deliveryboy_mobile,
                            style: TextStyle(fontSize: 16,color: whitecolor,),
                          ),

                          // Row(
                          //   children: [
                          //     Text(
                          //       user_first_name==null?"":user_first_name,
                          //       style: TextStyle(fontSize: 16,color: Colors.white,),
                          //     ),
                          //     SizedBox(
                          //       width: 5,
                          //     ),
                          //     Text(
                          //       user_last_name==null?"":user_last_name,
                          //       style: TextStyle(fontSize: 16,color: Colors.white,),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
                color: maincolor,
            ),
          ),


          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.home_outlined, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Home',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: blackcolor),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: blackcolor, size: 13.0,
                ),
              ],
            ),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/bottomhome");
            },
          ),


          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.call_outlined, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Contact Us',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: blackcolor),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: blackcolor, size: 13.0,
                ),
              ],
            ),
            onTap: (){
              // Navigator.of(context).pushReplacementNamed("/contactus");
              Navigator.of(context).pushNamed("/contactus");
            },
          ),

          ListTile(
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.logout, color: maincolor, size: 22.0,),
                    SizedBox(
                      width: 18,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Logout',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700, color: blackcolor),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios, color: blackcolor, size: 13.0,
                ),
              ],
            ),
            onTap: () async {
              // logout();
              SharedPreferences preferences = await SharedPreferences.getInstance();
              await preferences.clear();
              Navigator.of(context).pushReplacementNamed("/login");
            },
          ),


          _divider(),
          SizedBox(
            height: 10,
          ),
          new Center(
            child: new Text(appver,style: TextStyle(color:maincolor)),
          ),
          SizedBox(
            height: 5,
          ),
          // new Center(
          //   child: new Text("Developed by " + titlecapital,style: TextStyle(fontSize: 12.0, color: blackcolor)),
          // ),
          // SizedBox(
          //   height: 10,
          // ),
        ],
      ),
    );
  }

  void logout() async
  {
    // var authStateProvider = new AuthStateProvider();
    // authStateProvider.dispose(this);
    // var db = new DatabaseHelper();
    // await db.deleteUsers();
    // authStateProvider.notify(AuthState.LOGGED_OUT);

    Navigator.of(context).pushReplacementNamed("/login");
  }

  @override
  void onAuthStateChanged(AuthState state) {
    // TODO: implement onAuthStateChanged
  }

}