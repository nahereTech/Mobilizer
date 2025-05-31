import 'package:json_annotation/json_annotation.dart';
part 'confirm_password_response.g.dart';

@JsonSerializable()
class ConfirmPasswordResponse {
  ConfirmPasswordResponse(
      {required this.status, required this.msg, required this.tag});
  int status;
  String msg;
  String tag;

  factory ConfirmPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ConfirmPasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmPasswordResponseToJson(this);
}
