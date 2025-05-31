import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_update_response.g.dart';

@JsonSerializable()
class ForgotPasswordUpdateResponse {
  ForgotPasswordUpdateResponse({
    required this.status,
    required this.msg,
  });

  String status;
  String msg;

  factory ForgotPasswordUpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordUpdateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordUpdateResponseToJson(this);
}
