import 'package:json_annotation/json_annotation.dart';

part 'password_verification_response.g.dart';

@JsonSerializable()
class PasswordVerificationResponse {
  PasswordVerificationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;
  factory PasswordVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$PasswordVerificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordVerificationResponseToJson(this);
}
