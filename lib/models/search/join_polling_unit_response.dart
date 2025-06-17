import 'package:json_annotation/json_annotation.dart';
part 'join_polling_unit_response.g.dart';

@JsonSerializable()
class JoinPollingUnitResponse {
  JoinPollingUnitResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory JoinPollingUnitResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$JoinPollingUnitResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$JoinPollingUnitResponseToJson(this);
}
