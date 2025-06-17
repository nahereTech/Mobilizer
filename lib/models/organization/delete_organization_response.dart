import 'package:json_annotation/json_annotation.dart';
part 'delete_organization_response.g.dart';

@JsonSerializable()
class DeleteOrganizationResponse {
  DeleteOrganizationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory DeleteOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$DeleteOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DeleteOrganizationResponseToJson(this);
}
