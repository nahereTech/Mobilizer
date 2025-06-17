import 'package:json_annotation/json_annotation.dart';

part 'is_user_onboarded_response.g.dart';

@JsonSerializable()
class UserOnboardedResponse {
  UserOnboardedResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  dynamic status;
  String msg;
  Data? data;

  factory UserOnboardedResponse.fromJson(Map<String, dynamic> json) =>
      _$UserOnboardedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserOnboardedResponseToJson(this);
}

@JsonSerializable()
class Data {
  Data({
    required this.build_number,
    this.email,
    required this.action,
  });

  dynamic build_number;
  dynamic email;
  String action;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
