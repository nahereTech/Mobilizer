import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_otp_response.g.dart';

@JsonSerializable()
class ForgotPasswordOTPResponse {
  ForgotPasswordOTPResponse({
    required this.status,
    required this.msg,
  });

  String status;
  String msg;

  factory ForgotPasswordOTPResponse.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordOTPResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordOTPResponseToJson(this);
}
