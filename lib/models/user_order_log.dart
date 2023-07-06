import 'package:flutter/material.dart';
class UserOrderLogList {
  final String oc_id;
  final String order_id;
  final String product_id;
  final String user_id;
  final String order_qty;
  final String delivered_qty;
  final String not_delivered_qty;
  final String order_one_unit_price;
  final String order_total_amt;
  final String order_date;
  final String oc_cutoff_time;
  final String oc_date;
  final String oc_notdelivered_issue;
  final String oc_is_delivered;
  final String oc_admin_approve;
  final String product_type;
  final String product_name;
  final String product_image;
  final String attribute_name;


  UserOrderLogList({
    @required this.oc_id,
    @required this.order_id,
    @required this.product_id,
    @required this.user_id,
    @required this.order_qty,
    @required this.delivered_qty,
    @required this.not_delivered_qty,
    @required this.order_one_unit_price,
    @required this.order_total_amt,
    @required this.order_date,
    @required this.oc_cutoff_time,
    @required this.oc_date,
    @required this.oc_notdelivered_issue,
    @required this.oc_is_delivered,
    @required this.oc_admin_approve,
    @required this.product_type,
    @required this.product_name,
    @required this.product_image,
    @required this.attribute_name,
  });

  factory UserOrderLogList.fromJson(Map<String, dynamic> json) {
    return UserOrderLogList(
      oc_id: json['oc_id'],
      order_id: json['order_id'],
      product_id: json['product_id'],
      user_id: json['user_id'],
      order_qty: json['order_qty'],
      delivered_qty: json['delivered_qty'],
      not_delivered_qty: json['not_delivered_qty'],
      order_one_unit_price: json['order_one_unit_price'],
      order_total_amt: json['order_total_amt'],
      order_date: json['order_date'],
      oc_cutoff_time: json['oc_cutoff_time'],
      oc_date: json['oc_date'],
      oc_notdelivered_issue: json['oc_notdelivered_issue'],
      oc_is_delivered: json['oc_is_delivered'],
      oc_admin_approve: json['oc_admin_approve'],
      product_type: json['product_type'],
      product_name: json['product_name'],
      product_image: json['product_image'],
      attribute_name: json['attribute_name'],
    );
  }
}
