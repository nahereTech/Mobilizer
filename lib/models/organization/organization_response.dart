import 'package:json_annotation/json_annotation.dart';
part 'organization_response.g.dart';

@JsonSerializable()
class OrganizationResponse {
  OrganizationResponse({
    required this.status,
    required this.msg,
    required this.data,
    max_follow,
  });

  int status;
  String msg;
  dynamic max_follow;
  List<OrganizationData> data;

  factory OrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$OrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrganizationResponseToJson(this);
}

@JsonSerializable()
class OrganizationData {
  OrganizationData(
      {required this.org_id,
      this.townhall_id,
      required this.org_name,
      required this.org_bg,
      required this.org_member_count,
      required this.join_status,
      this.org_username,
      required this.org_about,
      required this.missing_custom_org_townhalls,
      required this.picture,
      required this.member,
      required this.is_leader,
      required this.verified,
      required this.can_update_subtownhalls,
      required this.unread,
      required this.pinned});
  int? org_id;
  String? townhall_id;
  String? org_name;
  String? org_bg;
  String? org_member_count;
  String? join_status;
  String? org_username;
  String? org_about;
  bool missing_custom_org_townhalls;
  String? picture;
  String? verified;
  String? is_leader;
  String? member;
  int? unread;
  String? pinned;
  bool can_update_subtownhalls;

  factory OrganizationData.fromJson(Map<String, dynamic> json) =>
      _$OrganizationDataFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationDataToJson(this);
}
