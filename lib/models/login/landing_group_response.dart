import 'package:json_annotation/json_annotation.dart';

part 'landing_group_response.g.dart';

@JsonSerializable()
class LandingGroupResponse {
  LandingGroupResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  int status;
  String msg;
  LandingData? data;

  factory LandingGroupResponse.fromJson(Map<String, dynamic> json) =>
      _$LandingGroupResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LandingGroupResponseToJson(this);
}

@JsonSerializable()
class LandingData {
  LandingData(
      {required this.org_id,
      required this.townhall_id,
      required this.is_leader,
      required this.org_name});

  dynamic org_id;
  dynamic townhall_id;
  String is_leader;
  String org_name;

  factory LandingData.fromJson(Map<String, dynamic> json) {
    // print(json);
    return _$LandingDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LandingDataToJson(this);
}
