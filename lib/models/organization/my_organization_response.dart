import 'package:json_annotation/json_annotation.dart';
part 'my_organization_response.g.dart';

@JsonSerializable()
class MyOrganizationResponse {
  MyOrganizationResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  int status;
  String msg;
  List<OrganizationData>? data;

  factory MyOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$MyOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MyOrganizationResponseToJson(this);
}

@JsonSerializable()
class OrganizationData {
  OrganizationData({
    required this.org_id,
    required this.org_name,
    required this.org_desc,
    required this.org_username,
    required this.org_image,
    required this.org_banner,
    required this.org_plan,
    required this.org_plan_name,
    required this.org_full_url,
    required this.org_member_count,
    required this.active_status,
    required this.created_by_user,
    this.requires_confirmation,
    this.org_privacy,
    this.available_townhalls,
    this.postable_townhalls,
    required this.custom_townhall_tree,
  });
  int? org_id;
  String? org_name;
  String? org_desc;
  String? org_username;
  String? org_image;
  String org_banner;
  int? org_plan;
  String? org_plan_name;
  String? org_full_url;
  int org_member_count;
  String? active_status;
  String? created_by_user;
  String? requires_confirmation;
  String? org_privacy;
  List<AvailableTownhallData>? available_townhalls;
  List<PostableTownhallData>? postable_townhalls;
  List<CustomTownhallData> custom_townhall_tree;

  factory OrganizationData.fromJson(Map<String, dynamic> json) =>
      _$OrganizationDataFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationDataToJson(this);
}

@JsonSerializable()
class AvailableTownhallData {
  AvailableTownhallData(
      {required this.name,
      required this.pic,
      required this.is_checked,
      required this.circle_reduction_percentage});
  String name;
  String pic;
  String is_checked;
  int circle_reduction_percentage;

  factory AvailableTownhallData.fromJson(Map<String, dynamic> json) =>
      _$AvailableTownhallDataFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableTownhallDataToJson(this);
}

@JsonSerializable()
class PostableTownhallData {
  PostableTownhallData(
      {required this.name,
      required this.pic,
      required this.is_checked,
      required this.circle_reduction_percentage});
  String name;
  String pic;
  String is_checked;
  int circle_reduction_percentage;

  factory PostableTownhallData.fromJson(Map<String, dynamic> json) =>
      _$PostableTownhallDataFromJson(json);

  Map<String, dynamic> toJson() => _$PostableTownhallDataToJson(this);
}

@JsonSerializable()
class CustomTownhallData {
  CustomTownhallData(
      {required this.id,
      this.name,
      required this.parent_id,
      this.level,
      this.level_name});
  int id;
  String? name;
  int parent_id;
  String? level;
  String? level_name;

  factory CustomTownhallData.fromJson(Map<String, dynamic> json) =>
      _$CustomTownhallDataFromJson(json);

  Map<String, dynamic> toJson() => _$CustomTownhallDataToJson(this);
}
