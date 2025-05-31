import 'package:json_annotation/json_annotation.dart';
part 'rename_custom_organization_response.g.dart';

@JsonSerializable()
class RenameCustomOrganizationResponse {
  RenameCustomOrganizationResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory RenameCustomOrganizationResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$RenameCustomOrganizationResponseFromJson(json);
  }

  Map<String, dynamic> toJson() =>
      _$RenameCustomOrganizationResponseToJson(this);
}
