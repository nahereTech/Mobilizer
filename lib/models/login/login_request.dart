import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  LoginRequest({
    this.email,
    this.app_name,
    this.password,
    this.device_type,
    this.device_token,
  });

  dynamic email;
  dynamic app_name;
  dynamic password;
  dynamic device_type;
  dynamic device_token;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
