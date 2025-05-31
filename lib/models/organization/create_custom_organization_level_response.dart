import 'package:json_annotation/json_annotation.dart';
part 'create_custom_organization_level_response.g.dart';

@JsonSerializable()
class CreateCustomOrganizationLevelResponse {
  CreateCustomOrganizationLevelResponse(
      {required this.status, required this.msg, required this.townhall_id});

  int status;
  String msg;
  String townhall_id;

  factory CreateCustomOrganizationLevelResponse.fromJson(
      Map<String, dynamic> json) {
    print(json);
    return _$CreateCustomOrganizationLevelResponseFromJson(json);
  }

  Map<String, dynamic> toJson() =>
      _$CreateCustomOrganizationLevelResponseToJson(this);
}
