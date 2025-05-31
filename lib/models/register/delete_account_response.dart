import 'package:json_annotation/json_annotation.dart';
part 'delete_account_response.g.dart';

@JsonSerializable()
class DeleteAccountResponse {
  DeleteAccountResponse(
      {required this.status, required this.msg, required this.tag});
  int status;
  String msg;
  String tag;

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAccountResponseToJson(this);
}
