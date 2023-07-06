
import 'package:flutter/material.dart';
class OnceOrderList {
  final String oc_id;
  final String order_id;
  final String user_id;
  int order_qty_int;
  // final int order_qty;
  // final double order_qty;
  final String order_qty;
  final String delivered_qty;
  final String not_delivered_qty;
  final String product_id;
  final String attribute_id;
  final String product_name;
  final String product_image;
  final String product_des;
  final String product_price;
  final String product_status;
  final String attribute_name;
  final String product_att_value;
  final String attribute_status;
  final String attribute_value;
  final String start_date;
  final String delivery_schedule;
  final String order_instructions;
  final String order_ring_bell;
  final String added_time;
  final String user_balance;
  final String order_subscription_status;
  final String product_regular_price;
  final String product_normal_price;
  final String order_one_unit_price;
  final String user_type;
  final String oc_is_delivered;


  OnceOrderList({
    @required this.oc_id,
    @required this.order_id,
    @required this.user_id,
    @required this.order_qty,
    @required this.order_qty_int,
    @required this.delivered_qty,
    @required this.not_delivered_qty,
    @required this.product_id,
    @required this.attribute_id,
    @required this.product_name,
    @required this.product_image,
    @required this.product_des,
    @required this.product_price,
    @required this.product_status,
    @required this.attribute_name,
    @required this.product_att_value,
    @required this.attribute_status,
    @required this.attribute_value,
    @required this.start_date,
    @required this.delivery_schedule,
    @required this.order_instructions,
    @required this.order_ring_bell,
    @required this.added_time,
    @required this.user_balance,
    @required this.order_subscription_status,
    @required this.product_regular_price,
    @required this.product_normal_price,
    @required this.order_one_unit_price,
    @required this.user_type,
    @required this.oc_is_delivered,
  });

  factory OnceOrderList.fromJson(Map<String, dynamic> json) {
    return OnceOrderList(
      oc_id: json['oc_id'],
      order_id: json['order_id'],
      user_id: json['user_id'],
      order_qty: json['order_qty'],
      order_qty_int: json['order_qty_int'],
      delivered_qty: json['delivered_qty'],
      not_delivered_qty: json['not_delivered_qty'],
      product_id: json['product_id'],
      attribute_id: json['attribute_id'],
      product_name: json['product_name'],
      product_image: json['product_image'],
      product_des: json['product_des'],
      product_price: json['product_price'],
      product_status: json['product_status'],
      attribute_name: json['attribute_name'],
      product_att_value: json['product_att_value'],
      attribute_status: json['attribute_status'],
      attribute_value: json['attribute_value'],
      start_date: json['start_date'],
      delivery_schedule: json['delivery_schedule'],
      order_instructions: json['order_instructions'],
      order_ring_bell: json['order_ring_bell'],
      added_time: json['added_time'],
      user_balance: json['user_balance'],
      order_subscription_status: json['order_subscription_status'],
      product_regular_price: json['product_regular_price'],
      product_normal_price: json['product_normal_price'],
      order_one_unit_price: json['order_one_unit_price'],
      user_type: json['user_type'],
      oc_is_delivered: json['oc_is_delivered'],
    );
  }
}
