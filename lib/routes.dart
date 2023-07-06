
import 'package:flutter/material.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/contact_us/contact_us_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/home/home_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/inventory/inventory_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/json/json_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/login/check_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/login/login_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/login/otp_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/login/time_slot_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/order/order_detail_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/order/order_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/register/register_done_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/register/register_first_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/register/register_otp_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/register/register_sec_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/register/register_thread_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/add_user_balance_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/add_user_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_balance_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_order_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_orders/user_not_subscription_product_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_orders/user_onec_product_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/user/user_screen.dart';
import 'package:nooranidairyfarm_deliveryboy/screens/wallet/balance_log_screen.dart';
import 'main.dart';

final routes = {
  '/' :          (BuildContext context) => new SplashScreen(),
  // '/' :          (BuildContext context) => new RegisterDoneScreen(),
  //Home
  '/login' :          (BuildContext context) => new LoginScreen(),
  '/otp' :          (BuildContext context) => new OTPScreen(),
  '/register' :          (BuildContext context) => new RegisterFirstScreen(),
  '/registerotp' :          (BuildContext context) => new RegisterOTPScreen(),
  '/registersec' :          (BuildContext context) => new RegisterSecScreen(),
  '/registertrd' :          (BuildContext context) => new RegisterTrdScreen(),
  '/registerdone' :          (BuildContext context) => new RegisterDoneScreen(),
  '/check' :          (BuildContext context) => new CheckScreen(),
  '/selecttime' :          (BuildContext context) => new SelectTimeSlot(),

  '/bottomhome' :          (BuildContext context) => new HomeScreen(),
  '/contactus' :          (BuildContext context) => new ContactUsScreen(),
  '/inventory' :          (BuildContext context) => new InventoryScreen(),


  '/paymentlist' :          (BuildContext context) => new PaymentListScreen(),

  '/user' :          (BuildContext context) => new UserScreen(),
  '/adduser' :          (BuildContext context) => new AddUserScreen(),
  '/userbalance' :          (BuildContext context) => new UserBalanceListScreen(),
  '/adduserbalance' :          (BuildContext context) => new AddUserBalanceScreen(),
  '/userorder' :          (BuildContext context) => new UserOrderScreen(),

  '/usernotsubpro' :          (BuildContext context) => new UserNotSubscriptionProductScreen(),
  '/useronespro' :          (BuildContext context) => new UserOnecProductScreen(),
  '/json' :          (BuildContext context) => new JSONScreen(),

  '/order' :          (BuildContext context) => new OrderScreen(),
  '/orderdetail' :          (BuildContext context) => new OrderDetailScreen(),
  //Home
};