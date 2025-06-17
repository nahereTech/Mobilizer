import 'package:json_annotation/json_annotation.dart';
part 'join_organization_response.g.dart';

@JsonSerializable()
class JoinOrganizationResponse {
  JoinOrganizationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory JoinOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$JoinOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$JoinOrganizationResponseToJson(this);
}
