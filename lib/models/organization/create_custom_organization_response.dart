import 'package:json_annotation/json_annotation.dart';
part 'create_custom_organization_response.g.dart';

@JsonSerializable()
class CreateCustomOrganizationResponse {
  CreateCustomOrganizationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory CreateCustomOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$CreateCustomOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() =>
      _$CreateCustomOrganizationResponseToJson(this);
}
