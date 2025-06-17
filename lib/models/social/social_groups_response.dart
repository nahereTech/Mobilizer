import 'package:json_annotation/json_annotation.dart';
part 'social_groups_response.g.dart';

@JsonSerializable()
class SocialGroupsResponse {
  SocialGroupsResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<SocialData> data;

  factory SocialGroupsResponse.fromJson(Map<String, dynamic> json) {
    //print(json);
    return _$SocialGroupsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SocialGroupsResponseToJson(this);
}

@JsonSerializable()
class SocialData {
  SocialData(
      {this.id,
      this.parent_org_id,
      this.name,
      this.app_id,
      this.users_permitted,
      this.active_status,
      this.del_status});

  dynamic id;
  dynamic parent_org_id;
  dynamic name;
  dynamic app_id;
  dynamic users_permitted;
  dynamic active_status;
  dynamic del_status;

  factory SocialData.fromJson(Map<String, dynamic> json) =>
      _$SocialDataFromJson(json);

  Map<String, dynamic> toJson() => _$SocialDataToJson(this);
}
