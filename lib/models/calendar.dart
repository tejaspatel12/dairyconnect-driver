import 'package:flutter/material.dart';
class CalendarList {
  final String oc_id;
  final String order_id;
  final String user_id;
  final int order_qty;
  final String order_date;
  final String product_id;
  final String delivery_schedule;
  final String order_instructions;
  final String order_ring_bell;
  final String product_name;
  final String product_image;
  final int product_regular_price;
  final int product_normal_price;
  final String user_type;
  final String oc_is_delivered;


  CalendarList({
    @required this.oc_id,
    @required this.order_id,
    @required this.user_id,
    @required this.order_qty,
    @required this.order_date,
    @required this.product_id,
    @required this.delivery_schedule,
    @required this.order_instructions,
    @required this.order_ring_bell,
    @required this.product_name,
    @required this.product_image,
    @required this.product_regular_price,
    @required this.product_normal_price,
    @required this.user_type,
    @required this.oc_is_delivered,
  });

  factory CalendarList.fromJson(Map<String, dynamic> json) {
    return CalendarList(
      oc_id: json['oc_id'],
      order_id: json['order_id'],
      user_id: json['user_id'],
      order_qty: json['order_qty'],
      order_date: json['order_date'],
      product_id: json['product_id'],
      delivery_schedule: json['delivery_schedule'],
      order_instructions: json['order_instructions'],
      order_ring_bell: json['order_ring_bell'],
      product_name: json['product_name'],
      product_image: json['product_image'],
      product_regular_price: json['product_regular_price'],
      product_normal_price: json['product_normal_price'],
      user_type: json['user_type'],
      oc_is_delivered: json['oc_is_delivered'],
    );
  }
}
