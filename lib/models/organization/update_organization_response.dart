import 'package:json_annotation/json_annotation.dart';
part 'update_organization_response.g.dart';

@JsonSerializable()
class UpdateOrganizationResponse {
  UpdateOrganizationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory UpdateOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$UpdateOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UpdateOrganizationResponseToJson(this);
}
