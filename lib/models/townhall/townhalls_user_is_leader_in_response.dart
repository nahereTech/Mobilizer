import 'package:json_annotation/json_annotation.dart';
part 'townhalls_user_is_leader_in_response.g.dart';

@JsonSerializable()
class TownhallsLeaderIsResponse {
  TownhallsLeaderIsResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String? msg;
  List<Data> data;

  factory TownhallsLeaderIsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$TownhallsLeaderIsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TownhallsLeaderIsResponseToJson(this);
}

@JsonSerializable()
class Data {
  Data({
    this.townhall_id,
    this.townhall_name,
    this.org_name,
    this.org_id,
    this.designation,
  });

  dynamic townhall_id;
  dynamic townhall_name;
  dynamic org_name;
  dynamic org_id;
  dynamic designation;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
