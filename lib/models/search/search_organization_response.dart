import 'package:json_annotation/json_annotation.dart';
part 'search_organization_response.g.dart';

@JsonSerializable()
class SearchOrganizationResponse {
  SearchOrganizationResponse({
    required this.status,
    required this.msg,
    List<OrganizationData>? data,
    max_follow,
  }) : data = data ?? [];

  int status;
  String msg;
  dynamic max_follow;
  List<OrganizationData>? data;

  factory SearchOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$SearchOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchOrganizationResponseToJson(this);
}

@JsonSerializable()
class OrganizationData {
  OrganizationData({
    required this.org_id,
    required this.org_name,
    required this.org_bg,
    required this.org_member_count,
    required this.join_status,
    this.org_username,
    required this.org_about,
    required this.picture,
    required this.is_member,
    this.is_leader,
    required this.verified,
    required this.unread,
    required this.pinned,
    required this.requires_confirmation,
  });
  dynamic org_id;
  String? org_name;
  String? org_bg;
  String? org_member_count;
  String? join_status;
  String? org_username;
  String? org_about;
  String? picture;
  String? verified;
  String? is_leader;
  String? is_member;
  int? unread;
  String? pinned;
  String requires_confirmation;

  factory OrganizationData.fromJson(Map<String, dynamic> json) =>
      _$OrganizationDataFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationDataToJson(this);
}
