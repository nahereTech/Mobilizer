import 'package:json_annotation/json_annotation.dart';

part 'register_otp_request.g.dart';

@JsonSerializable()
class RegisterOTPRequest {
  RegisterOTPRequest({
    this.email,
    this.code,
  });

  dynamic email;
  dynamic code;

  factory RegisterOTPRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterOTPRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterOTPRequestToJson(this);
}
