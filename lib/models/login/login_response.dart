import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  LoginResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  dynamic status;
  String msg;
  UserData? data;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class UserData {
  UserData({
    required this.user_id,
    this.firstname,
    this.lastname,
    this.username,
    this.landing_page,
    this.profile_photo,
    required this.photo_path,
    required this.photo_path_mid,
    required this.photo_path_lg,
    required this.token,
  });

  String user_id;
  String? firstname;
  String? lastname;
  String? username;
  String? landing_page;
  String? profile_photo;
  String photo_path;
  String photo_path_mid;
  String photo_path_lg;
  String token;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
