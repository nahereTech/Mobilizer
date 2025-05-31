import 'package:json_annotation/json_annotation.dart';
part 'disable_account_response.g.dart';

@JsonSerializable()
class DisableAccountResponse {
  DisableAccountResponse(
      {required this.status, required this.msg, required this.tag});
  int status;
  String msg;
  String tag;

  factory DisableAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$DisableAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DisableAccountResponseToJson(this);
}
