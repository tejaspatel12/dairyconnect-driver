
import 'package:flutter/material.dart';
class OrderList {
  final String order_id;
  final String user_id;
  final String product_id;
  final String attribute_id;
  final String category_id;
  final String product_name;
  final String product_image;
  final String product_des;
  final String product_price;
  final String product_status;
  final String attribute_name;
  final String attribute_status;
  final String attribute_value;
  final String start_date;
  final String category_name;
  final String delivery_schedule;
  final String order_instructions;
  final String order_ring_bell;
  final String added_time;
  final String user_balance;
  final String order_subscription_status;
  final String user_first_name;
  final String user_last_name;
  final String user_email;
  final String user_mobile_number;
  final String user_address;
  final String user_subscription_status;
  final String accept_nagative_balance;
  final String user_type;
  final String user_status;
  final String oc_id;
  final String order_qty;
  final String uoc_status;
  final String ds_qty;

//CODE
  final String delivered_qty;
  final String not_delivered_qty;
  final String product_regular_price;
  final String product_normal_price;
  final String oc_is_delivered;


  OrderList({
    @required this.order_id,
    @required this.user_id,
    @required this.product_id,
    @required this.attribute_id,
    @required this.category_id,
    @required this.product_name,
    @required this.product_image,
    @required this.product_des,
    @required this.product_price,
    @required this.product_status,
    @required this.attribute_name,
    @required this.attribute_status,
    @required this.attribute_value,
    @required this.start_date,
    @required this.category_name,
    @required this.delivery_schedule,
    @required this.order_instructions,
    @required this.order_ring_bell,
    @required this.added_time,
    @required this.user_balance,
    @required this.order_subscription_status,
    @required this.user_first_name,
    @required this.user_last_name,
    @required this.user_email,
    @required this.user_mobile_number,
    @required this.user_address,
    @required this.user_subscription_status,
    @required this.accept_nagative_balance,
    @required this.user_type,
    @required this.user_status,
    @required this.oc_id,
    @required this.order_qty,
    @required this.uoc_status,
    @required this.ds_qty,

    //CODE
    @required this.delivered_qty,
    @required this.not_delivered_qty,
    @required this.product_regular_price,
    @required this.product_normal_price,
    @required this.oc_is_delivered,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) {
    return OrderList(
      order_id: json['order_id'],
      user_id: json['user_id'],
      product_id: json['product_id'],
      attribute_id: json['attribute_id'],
      category_id: json['category_id'],
      product_name: json['product_name'],
      product_image: json['product_image'],
      product_des: json['product_des'],
      product_price: json['product_price'],
      product_status: json['product_status'],
      attribute_name: json['attribute_name'],
      attribute_status: json['attribute_status'],
      attribute_value: json['attribute_value'],
      start_date: json['start_date'],
      category_name: json['category_name'],
      delivery_schedule: json['delivery_schedule'],
      order_instructions: json['order_instructions'],
      order_ring_bell: json['order_ring_bell'],
      added_time: json['added_time'],
      user_balance: json['user_balance'],
      order_subscription_status: json['order_subscription_status'],
      user_first_name: json['user_first_name'],
      user_last_name: json['user_last_name'],
      user_email: json['user_email'],
      user_mobile_number: json['user_mobile_number'],
      user_address: json['user_address'],
      user_subscription_status: json['user_subscription_status'],
      accept_nagative_balance: json['accept_nagative_balance'],
      user_type: json['user_type'],
      user_status: json['user_status'],
      oc_id: json['oc_id'],
      order_qty: json['order_qty'],
      uoc_status: json['uoc_status'],
      ds_qty: json['ds_qty'],

      //CODE
      delivered_qty: json['delivered_qty'],
      not_delivered_qty: json['not_delivered_qty'],
      product_regular_price: json['product_regular_price'],
      product_normal_price: json['product_normal_price'],
      oc_is_delivered: json['oc_is_delivered'],
    );
  }
}
