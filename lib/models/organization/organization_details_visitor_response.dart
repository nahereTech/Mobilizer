import 'package:json_annotation/json_annotation.dart';
part 'organization_details_visitor_response.g.dart';

@JsonSerializable()
class OrganizationDetailsResponse {
  OrganizationDetailsResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  int status;
  String? msg;
  OrgData? data;

  factory OrganizationDetailsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$OrganizationDetailsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrganizationDetailsResponseToJson(this);
}

@JsonSerializable()
class OrgData {
  OrgData(
      {required this.id,
      required this.name,
      required this.username, //landscape or portrait
      required this.description, //audio or view
      required this.verified,
      required this.logo,
      required this.banner,
      required this.membership_count});
  int id;
  String name;
  String username;
  String description;
  String verified;
  String logo;
  String banner;
  int membership_count;

  factory OrgData.fromJson(Map<String, dynamic> json) =>
      _$OrgDataFromJson(json);

  Map<String, dynamic> toJson() => _$OrgDataToJson(this);
}
