import 'package:flutter/material.dart';
class PaymentList {
  final String payment_id;
  final String user_id;
  final String razorpay_payment_id;
  // final String payment_amt;
  final String tbl_tilte;
  final String ubl_amount;
  final String payment_type;
  final String payment_status;
  final String ubl_date;


  PaymentList({
    @required this.payment_id,
    @required this.user_id,
    @required this.razorpay_payment_id,
    // @required this.payment_amt,
    @required this.tbl_tilte,
    @required this.ubl_amount,
    @required this.payment_type,
    @required this.payment_status,
    @required this.ubl_date,
  });

  factory PaymentList.fromJson(Map<String, dynamic> json) {
    return PaymentList(
      payment_id: json['payment_id'],
      user_id: json['user_id'],
      razorpay_payment_id: json['razorpay_payment_id'],
      // payment_amt: json['payment_amt'],
      tbl_tilte: json['tbl_tilte'],
      ubl_amount: json['ubl_amount'],
      payment_type: json['payment_type'],
      payment_status: json['payment_status'],
      ubl_date: json['ubl_date'],
    );
  }
}
