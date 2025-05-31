import 'package:json_annotation/json_annotation.dart';

part 'register_otp_response.g.dart';

@JsonSerializable()
class RegisterOTPResponse {
  RegisterOTPResponse({required this.status, required this.msg, this.data});

  String status;
  String msg;
  UserData? data;

  factory RegisterOTPResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterOTPResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterOTPResponseToJson(this);
}

@JsonSerializable()
class UserData {
  UserData({
    required this.user_id,
    required this.landing_page,
    required this.last_visted,
    required this.landing_page_id,
    required this.token,
  });

  String user_id;
  String? last_visted;
  String landing_page;
  String landing_page_id;
  String token;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
