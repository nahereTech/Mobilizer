import 'package:json_annotation/json_annotation.dart';

part 'request_otp_response.g.dart';

@JsonSerializable()
class RequestOTPResponse {
  RequestOTPResponse({required this.status, required this.msg});

  String status;
  String msg;

  factory RequestOTPResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestOTPResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RequestOTPResponseToJson(this);
}
