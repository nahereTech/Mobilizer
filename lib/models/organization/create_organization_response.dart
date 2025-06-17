import 'package:json_annotation/json_annotation.dart';
part 'create_organization_response.g.dart';

@JsonSerializable()
class CreateOrganizationResponse {
  CreateOrganizationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory CreateOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$CreateOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CreateOrganizationResponseToJson(this);
}
