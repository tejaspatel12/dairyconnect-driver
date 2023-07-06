
import 'package:flutter/material.dart';
class SliderList {
  final String slider_id;
  final String slider_img;
  final String slider_status;


  SliderList({
    @required this.slider_id,
    @required this.slider_img,
    @required this.slider_status,
  });

  factory SliderList.fromJson(Map<String, dynamic> json) {
    return SliderList(
      slider_id: json['slider_id'],
      slider_img: json['slider_img'],
      slider_status: json['slider_status'],
    );
  }
}
