import 'package:json_annotation/json_annotation.dart';

part 'account_deactivation_response.g.dart';

@JsonSerializable()
class AccountDeactivationResponse {
  AccountDeactivationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory AccountDeactivationResponse.fromJson(Map<String, dynamic> json) {
    return _$AccountDeactivationResponseFromJson(json);
    print(json);
  }

  Map<String, dynamic> toJson() => _$AccountDeactivationResponseToJson(this);
}
