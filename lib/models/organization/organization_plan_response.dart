import 'package:json_annotation/json_annotation.dart';
part 'organization_plan_response.g.dart';

@JsonSerializable()
class OrganizationPlanResponse {
  OrganizationPlanResponse({
    this.status,
    this.msg,
    this.data,
  });

  int? status;
  String? msg;
  List<PlanData>? data;

  factory OrganizationPlanResponse.fromJson(Map<String, dynamic> json) {
    //print(json);
    return _$OrganizationPlanResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrganizationPlanResponseToJson(this);
}

@JsonSerializable()
class PlanData {
  PlanData({
    required this.id,
    required this.name,
    required this.desc,
    this.temp_creation_id,
  });
  int id;
  String name;
  String desc;
  String? temp_creation_id;

  factory PlanData.fromJson(Map<String, dynamic> json) =>
      _$PlanDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlanDataToJson(this);
}
