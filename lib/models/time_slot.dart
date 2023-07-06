import 'package:flutter/material.dart';
class TimeSlotList {
  final String time_slot_id;
  final String time_slot_name;
  final String time_slot_status;
  final String time_slot_cutoff_time;


  TimeSlotList({
    @required this.time_slot_id,
    @required this.time_slot_name,
    @required this.time_slot_status,
    @required this.time_slot_cutoff_time,
  });

  factory TimeSlotList.fromJson(Map<String, dynamic> json) {
    return TimeSlotList(
      time_slot_id: json['time_slot_id'],
      time_slot_name: json['time_slot_name'],
      time_slot_status: json['time_slot_status'],
      time_slot_cutoff_time: json['time_slot_cutoff_time'],
    );
  }
}
