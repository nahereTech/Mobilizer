import 'package:json_annotation/json_annotation.dart';
part 'delete_custom_organization_response.g.dart';

@JsonSerializable()
class DeleteCustomOrganizationResponse {
  DeleteCustomOrganizationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory DeleteCustomOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$DeleteCustomOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() =>
      _$DeleteCustomOrganizationResponseToJson(this);
}
