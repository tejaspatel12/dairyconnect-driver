
import 'package:flutter/material.dart';
class EveryOrderList {
  final String order_id;
  final String user_id;
  final String product_id;
  final String attribute_id;
  final String start_date;
  final String delivery_schedule;
  final String order_instructions;
  final String order_ring_bell;
  final String order_subscription_status;
  final String push_date;
  final String resume_date;
  final String added_time;
  final String delivery_schedule_id;
  final String ds_type;
  final String ds_qty;
  final String product_type;
  final String product_name;
  final String product_image;
  final String product_regular_price;
  final String product_normal_price;
  final String product_att_value;
  final String product_min_qty;
  final String product_status;
  final String product_sequence;


  EveryOrderList({
    @required this.order_id,
    @required this.user_id,
    @required this.product_id,
    @required this.attribute_id,
    @required this.start_date,
    @required this.delivery_schedule,
    @required this.order_instructions,
    @required this.order_ring_bell,
    @required this.order_subscription_status,
    @required this.push_date,
    @required this.resume_date,
    @required this.added_time,
    @required this.delivery_schedule_id,
    @required this.ds_type,
    @required this.ds_qty,
    @required this.product_type,
    @required this.product_name,
    @required this.product_image,
    @required this.product_regular_price,
    @required this.product_normal_price,
    @required this.product_att_value,
    @required this.product_min_qty,
    @required this.product_status,
    @required this.product_sequence,
  });

  factory EveryOrderList.fromJson(Map<String, dynamic> json) {
    return EveryOrderList(
      order_id: json['order_id'],
      user_id: json['user_id'],
      product_id: json['product_id'],
      attribute_id: json['attribute_id'],
      start_date: json['start_date'],
      delivery_schedule: json['delivery_schedule'],
      order_instructions: json['order_instructions'],
      order_ring_bell: json['order_ring_bell'],
      order_subscription_status: json['order_subscription_status'],
      push_date: json['push_date'],
      resume_date: json['resume_date'],
      added_time: json['added_time'],
      delivery_schedule_id: json['delivery_schedule_id,'],
      ds_type: json['ds_type'],
      ds_qty: json['ds_qty'],
      product_type: json['product_type'],
      product_name: json['product_name'],
      product_image: json['product_image'],
      product_regular_price: json['product_regular_price'],
      product_normal_price: json['product_normal_price'],
      product_att_value: json['product_att_value'],
      product_min_qty: json['product_min_qty'],
      product_status: json['product_status'],
      product_sequence: json['product_sequence'],

    );
  }
}
