import 'dart:async';

import 'package:nooranidairyfarm_deliveryboy/models/admin.dart';
import 'package:nooranidairyfarm_deliveryboy/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL = "https://7047cem.activeit.in/";

  static final BASE_URL_APP = BASE_URL + "api/";

  static final GET_USER_DASHBOARD = BASE_URL_APP + "client_dashboard.php";

  static final GET_DELIVEYBOY = BASE_URL_APP + "deliveryboy_api.php";

  static final APP_SETTING = BASE_URL_APP + "app_setting.php";
  static final LOGIN = BASE_URL_APP + "deliveryboy_login.php";
  static final GET_DELIVERYBOY_DASHBOARD = BASE_URL_APP + "deliveryboy_dashboard.php";
  static final ORDER = BASE_URL_APP + "deliveryboy_order.php";
  // static final NEW_ORDER = BASE_URL_APP + "deliveryboy_order_old.php";
  static final NEW_ORDER = BASE_URL_APP + "deliveryboy_order.php";
  static final ORDER_DETAIL = BASE_URL_APP + "deliveryboy_orderdetail.php";
  static final USER = BASE_URL_APP + "deliveryboy_user.php";
  static final DELIVERYBOY_USER_SORT = BASE_URL_APP + "deliveryboy_usersorting.php";
  static final DELIVERYBOY_ORDER_STATUS = BASE_URL_APP + "deliveryboy_order_status.php";
  static final DELIVERYBOY_INVENTORY = BASE_URL_APP + "deliveryboy_inventory.php";

  static final LOCATION = BASE_URL_APP + "location.php";
  static final CATEGORY = BASE_URL_APP + "category.php";
  static final PRODUCT = BASE_URL_APP + "product.php";
  static final PAYMENT = BASE_URL_APP + "payment.php";
  static final CALENDAR = BASE_URL_APP + "calendar.php";
  static final FAQ = BASE_URL_APP + "faq.php";
  static final NOTIFICATION = BASE_URL_APP + "notification.php";

  static final BASE_INDEX = BASE_URL_APP + "index.php";
  static final GET_BANNER = BASE_URL_APP + "slider.php";

  //PRODUCT CODE
  //Category
  static final GET_DASHBOARD = BASE_URL_APP + "deliveryboy_order.php";
  static final GET_CATEGORY_DASHBOARD = BASE_URL_APP + "category.php";
  static final GET_PRODUCT_DASHBOARD = BASE_URL_APP + "product.php";


  static final GET_ABOUT = BASE_URL_APP + "about.php";
  static final GET_SERVICE = BASE_URL_APP + "service.php";
  static final GET_PROJECT = BASE_URL_APP + "project.php";

  static final GET_PRODUCT = BASE_URL_APP + "product.php";
  static final GET_PRODUCT_ALL_DETAIL = BASE_URL_APP + "product_detail.php";

  static final GET_OFFER = BASE_URL_APP + "offer.php";
  static final GET_GALLERY = BASE_URL_APP + "gallery.php";

  static final SEND_APPOINTMENT = BASE_URL_APP + "send_appointment.php";

  static final SEND_SERVICE_INQUIRY = BASE_URL_APP + "send_service_inquiry.php";

  static final SEND_PRODUCT_INQUIRY = BASE_URL_APP + "send_product_inquiry.php";

  static final SEND_OFFER_INQUIRY = BASE_URL_APP + "send_offer_inquiry.php";

  static final SEND_CONTACT_US = BASE_URL_APP + "send_contact.php";


  // Image Path

  static final SLIDER_IMAGE = BASE_URL + "images/slider/";
  static final PRODUCT_IMAGE = BASE_URL + "images/product/";
  static final CATEGORY_IMAGE = BASE_URL + "images/category/";
  static final AREA_IMAGE = BASE_URL + "images/area/";
  static final MORE_IMAGE = BASE_URL + "images/more/";

  Future<Admin> login(String last_id,String deliveryboy_id, String otp) {
    return _netUtil.post(LOGIN, body: {
      "action":"deliveryboyotplogin",
      "last_id": last_id,
      "deliveryboy_id": deliveryboy_id,
      "otp": otp
    }).then((dynamic res) async {
      print(res.toString());
      if(res["status"]=="no") throw new Exception(res["message"]);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("deliveryboy_id", res["data"]["deliveryboy_id"]);
      prefs.setString("deliveryboy_name", res["data"]["deliveryboy_name"]);
      prefs.setString("deliveryboy_mobile", res["data"]["deliveryboy_mobile"]);
      return new Admin.map(res["data"]);
    });
  }

}