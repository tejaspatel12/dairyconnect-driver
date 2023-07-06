import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:nooranidairyfarm_deliveryboy/data/rest_ds.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/Constant.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/color.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/connectionStatusSingleton.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/flash_helper.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/internetconnection.dart';
import 'package:flutter/material.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth.dart';

class RegisterTrdScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RegisterTrdScreenState();
  }
}

class RegisterTrdScreenState extends State<RegisterTrdScreen>{
  BuildContext _ctx;

  bool _isLoading = false;
  String deliveryboy_mobile,deliveryboy_id;


  File _adharf = null,_adharb = null,_drivingf = null,_drivingb = null;
  bool _af=false,_ab=false,_lf=false,_lb=false;


  SharedPreferences prefs;
  NetworkUtil _netUtil = new NetworkUtil();

  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {

    });
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
    // startTime();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  // ImagePicker imagePicker = ImagePicker();

  //Profile IMG
  _imgFromCameraPro() async {
    // var image = await imagePicker.getImage(source: ImageSource.camera);
    // var image = await ImagePicker.pickImage(
    //     source: ImageSource.camera, imageQuality: 50);
    var image = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      _adharf = File(image.path);
    });
  }

  _imgFromGalleryPro() async {
    // var image = await ImagePicker.pickImage(
    //     source: ImageSource.gallery, imageQuality: 50);
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _adharf = File(image.path);
    });
  }

  void _showPickerAdhar(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              // elevation: 2.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: maincolor, width: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              margin: new EdgeInsets.symmetric(
                  horizontal: 0.0, vertical: 5.0),
              child: Container(
                color: blackcolor,
                child: new Wrap(
                  children: <Widget>[
                    new ListTile(
                        leading: new Icon(Icons.photo_library,color: maincolor,),
                        title: new Text('Photo Library',style: TextStyle(fontSize: textSizeSMedium,color:maincolor)),
                        onTap: () {
                          _imgFromGalleryPro();
                          Navigator.of(context).pop();
                        }),
                    new ListTile(
                      leading: new Icon(Icons.photo_camera,color: maincolor,),
                      title: new Text('Camera',style: TextStyle(fontSize: textSizeSMedium,color:maincolor)),
                      onTap: () {
                        _imgFromCameraPro();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  //Profile IMG
  _imgFromCameraAdharb() async {
    // var image = await ImagePicker.pickImage(
    //     source: ImageSource.camera, imageQuality: 50);
    var image = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      _adharb = File(image.path);
    });
  }


  _imgFromGalleryAdharb() async {
    // var image = await ImagePicker.pickImage(
    //     source: ImageSource.gallery, imageQuality: 50);
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _adharb = File(image.path);
    });
  }

  void _showPickerAdharb(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              // elevation: 2.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: maincolor, width: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              margin: new EdgeInsets.symmetric(
                  horizontal: 0.0, vertical: 5.0),
              child: Container(
                color: blackcolor,
                child: new Wrap(
                  children: <Widget>[
                    new ListTile(
                        leading: new Icon(Icons.photo_library,color: maincolor,),
                        title: new Text('Photo Library',style: TextStyle(fontSize: textSizeSMedium,color:maincolor)),
                        onTap: () {
                          _imgFromGalleryAdharb();
                          Navigator.of(context).pop();
                        }),
                    new ListTile(
                      leading: new Icon(Icons.photo_camera,color: maincolor,),
                      title: new Text('Camera',style: TextStyle(fontSize: textSizeSMedium,color:maincolor)),
                      onTap: () {
                        _imgFromCameraAdharb();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  //Drivingf IMG
  _imgFromCameraDrivingf() async {
    // var image = await ImagePicker.pickImage(
    //     source: ImageSource.camera, imageQuality: 50);
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      // _drivingf = image;
      _drivingf = File(image.path);
    });
  }

  _imgFromGalleryDrivingf() async {
    // var image = await ImagePicker.pickImage(
    //     source: ImageSource.gallery, imageQuality: 50);

    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      // _drivingf = image;
      _drivingf = File(image.path);
    });
  }

  void _showPickerDrivingf(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              // elevation: 2.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: maincolor, width: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              margin: new EdgeInsets.symmetric(
                  horizontal: 0.0, vertical: 5.0),
              child: Container(
                color: blackcolor,
                child: new Wrap(
                  children: <Widget>[
                    new ListTile(
                        leading: new Icon(Icons.photo_library,color: maincolor,),
                        title: new Text('Photo Library',style: TextStyle(fontSize: textSizeSMedium,color:maincolor)),
                        onTap: () {
                          _imgFromGalleryDrivingf();
                          Navigator.of(context).pop();
                        }),
                    new ListTile(
                      leading: new Icon(Icons.photo_camera,color: maincolor,),
                      title: new Text('Camera',style: TextStyle(fontSize: textSizeSMedium,color:maincolor)),
                      onTap: () {
                        _imgFromCameraDrivingf();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  //Drivingb IMG
  _imgFromCameraDrivingb() async {
    // var image = await ImagePicker.pickImage(
    //     source: ImageSource.camera, imageQuality: 50);
    var image = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      // _drivingb = image;
      _drivingb = File(image.path);
    });
  }

  _imgFromGalleryDrivingb() async {
    // var image = await ImagePicker.pickImage(
    //     source: ImageSource.gallery, imageQuality: 50);
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      // _drivingb = image;
      _drivingb = File(image.path);
    });
  }

  void _showPickerDrivingb(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              // elevation: 2.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: maincolor, width: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              margin: new EdgeInsets.symmetric(
                  horizontal: 0.0, vertical: 5.0),
              child: Container(
                color: blackcolor,
                child: new Wrap(
                  children: <Widget>[
                    new ListTile(
                        leading: new Icon(Icons.photo_library,color: maincolor,),
                        title: new Text('Photo Library',style: TextStyle(fontSize: textSizeSMedium,color:maincolor)),
                        onTap: () {
                          _imgFromGalleryDrivingb();
                          Navigator.of(context).pop();
                        }),
                    new ListTile(
                      leading: new Icon(Icons.photo_camera,color: maincolor,),
                      title: new Text('Camera',style: TextStyle(fontSize: textSizeSMedium,color:maincolor)),
                      onTap: () {
                        _imgFromCameraDrivingb();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    _ctx = context;
    setState(() {
      final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
      deliveryboy_mobile = arguments['deliveryboy_mobile'];
      deliveryboy_id = arguments['deliveryboy_id'];
    });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        // backgroundColor: shadecolor,
        body:SafeArea(
          child: Stack(
            children: [

              NestedScrollView(
                headerSliverBuilder: (BuildContext context,
                    bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      centerTitle: true,
                      backgroundColor: maincolor,
                      title: Text("Register",
                        style: TextStyle(color: Colors.white),),
                      iconTheme: IconThemeData(color: Colors.white),

                      pinned: true,
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                    ),
                  ];
                },
                body:ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Container(
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Adhar Card or Driving Licence", style: TextStyle(color: maincolor,fontSize: textSizeLargeMedium),),
                                    Text("Front Image", style: TextStyle(color: whitecolor,fontSize: textSizeLargeMedium),),
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.04,
                                ),

                                _adharf != null
                                    ? Center(
                                  child: Container(
                                    width : MediaQuery.of(context).size.width * 0.50,
                                    // width: MediaQuery.of(context).size.width * 0.04,
                                    child: (
                                        Image.file(
                                          _adharf, fit: BoxFit.fitWidth,
                                        )),
                                  ),
                                )
                                    : (
                                    Container(
                                    )
                                ),

                                SizedBox(
                                  height: textSizeSMedium,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: ()
                                      {
                                        _showPickerAdhar(context);
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
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(9, 8, 9, 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.camera_alt,color: whitecolor,size: 16,),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Select Image",
                                                style: TextStyle(
                                                  color: whitecolor,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: textSizeSmall,
                                    ),
                                    InkWell(
                                      onTap: () {

                                        NetworkUtil _netUtil = new NetworkUtil();
                                        String base64Image = base64Encode(_adharf.readAsBytesSync());
                                        _netUtil.post(RestDatasource.LOGIN, body: {
                                          'action': "adharfront",
                                          "deliveryboy_id": deliveryboy_id,
                                          // "deliveryboy_id": "2",
                                          "adhar_front_img": base64Image,
                                        }).then((dynamic res) async {
                                          if(res["status"] == "yes")
                                          {
                                            setState(() {
                                              _af = true;
                                            });
                                            // FlashHelper.successBar(context, message: res['message']);
                                          }
                                          else {
                                            // FlashHelper.errorBar(context, message: res['message']);
                                          }
                                        });

                                      },
                                      child: _af == true?Container(
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
                                          padding: EdgeInsets.fromLTRB(9, 8, 9, 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.upload_sharp,color: whitecolor,size: 16,),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Upload Successful",
                                                style: TextStyle(
                                                  color: whitecolor,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ):Container(
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
                                          padding: EdgeInsets.fromLTRB(9, 8, 9, 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.upload_sharp,color: whitecolor,size: 16,),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Upload Image",
                                                style: TextStyle(
                                                  color: whitecolor,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.04,
                          ),
                          Container(
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Adhar Card or Driving Licence", style: TextStyle(color: maincolor,fontSize: textSizeLargeMedium),),
                                    Text("Back Image", style: TextStyle(color: whitecolor,fontSize: textSizeLargeMedium),),
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.04,
                                ),

                                _adharb != null
                                    ? Center(
                                  child: Container(
                                    width : MediaQuery.of(context).size.width * 0.50,
                                    // width: MediaQuery.of(context).size.width * 0.04,
                                    child: (
                                        Image.file(
                                          _adharb, fit: BoxFit.fitWidth,
                                        )),
                                  ),
                                )
                                    : (
                                    Container(
                                    )
                                ),

                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: ()
                                      {
                                        _showPickerAdharb(context);
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
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(9, 8, 9, 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.camera_alt,color: whitecolor,size: 16,),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Select Image",
                                                style: TextStyle(
                                                  color: whitecolor,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: spacing_standard,
                                    ),
                                    InkWell(
                                      onTap: () {

                                        NetworkUtil _netUtil = new NetworkUtil();
                                        String base64Image = base64Encode(_adharb.readAsBytesSync());
                                        _netUtil.post(RestDatasource.LOGIN, body: {
                                          'action': "adharback",
                                          "deliveryboy_id": deliveryboy_id,
                                          // "deliveryboy_id": "2",
                                          "adhar_back_img": base64Image,
                                        }).then((dynamic res) async {
                                          if(res["status"] == "yes")
                                          {
                                            setState(() {
                                              _ab = true;
                                            });
                                            // FlashHelper.successBar(context, message: res['message']);
                                          }
                                          else {
                                            // FlashHelper.errorBar(context, message: res['message']);
                                          }
                                        });

                                      },
                                      child: _ab == true?Container(
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
                                          padding: EdgeInsets.fromLTRB(9, 8, 9, 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.upload_sharp,color: whitecolor,size: 16,),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Upload Successful",
                                                style: TextStyle(
                                                  color: whitecolor,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ):Container(
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
                                          padding: EdgeInsets.fromLTRB(9, 8, 9, 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.upload_sharp,color: whitecolor,size: 16,),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Upload Image",
                                                style: TextStyle(
                                                  color: whitecolor,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.25,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  Container(
                    color: blackcolor,
                    child: Column(
                      children: [


                        Padding(
                          padding: const EdgeInsets.fromLTRB(20,10, 20, 0),
                          child: InkWell(
                            onTap: ()
                            {
                              if(_af==false)
                              {
                                // FlashHelper.errorBar(context, message: "Please Upload Adhar Card or Driving Licence Front Image");
                              }
                              else if(_ab==false)
                              {
                                // FlashHelper.errorBar(context, message: "Please Upload Adhar Card or Driving Licence Back Image");
                              }
                              else
                              {
                                NetworkUtil _netUtil = new NetworkUtil();
                                _netUtil.post(RestDatasource.LOGIN, body: {
                                  'action': "deliveryboycomplateregister",
                                  "deliveryboy_id": deliveryboy_id,
                                  // "deliveryboy_id": "2",
                                }).then((dynamic res) async {
                                  if(res["status"] == "yes")
                                  {
                                    // FlashHelper.successBar(context, message: res['message']);
                                    Navigator.of(context).pushReplacementNamed("/registerdone");
                                  }
                                  else {
                                    // FlashHelper.errorBar(context, message: res['message']);
                                  }
                                });
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 10),
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("NEXT",
                                    style: TextStyle(
                                        color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.02,
                        ),



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
