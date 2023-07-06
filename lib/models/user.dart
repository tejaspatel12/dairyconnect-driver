class Users {
  String user_id;
  String deliveryboy_id;
  String deliveryboy_name;
  String user_first_name;
  String user_last_name;
  String user_email;
  String user_mobile_number;
  String user_address;
  String user_balance;
  String area_name;
  String sorting_no;
  String user_time;
  String time_slot_name;
  String time_slot_cutoff_time;
  String user_status;


  Users({
    this.user_id,
    this.deliveryboy_id,
    this.deliveryboy_name,
    this.user_first_name,
    this.user_last_name,
    this.user_email,
    this.user_mobile_number,
    this.user_address,
    this.user_balance,
    this.area_name,
    this.sorting_no,
    this.user_time,
    this.time_slot_name,
    this.time_slot_cutoff_time,
    this.user_status,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      user_id: json['user_id'],
      deliveryboy_id: json['deliveryboy_id'],
      deliveryboy_name: json['deliveryboy_name'],
      user_first_name: json['user_first_name'],
      user_last_name: json['user_last_name'],
      user_email: json['user_email'],
      user_mobile_number: json['user_mobile_number'],
      user_address: json['user_address'],
      user_balance: json['user_balance'],
      area_name: json['area_name'],
      sorting_no: json['sorting_no'],
      user_time: json['user_time'],
      time_slot_name: json['time_slot_name'],
      time_slot_cutoff_time: json['time_slot_cutoff_time'],
      user_status: json['user_status'],
    );
  }

}