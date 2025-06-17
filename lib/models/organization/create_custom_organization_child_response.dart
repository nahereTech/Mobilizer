import 'package:json_annotation/json_annotation.dart';
part 'create_custom_organization_child_response.g.dart';

@JsonSerializable()
class CreateCustomOrganizationChildResponse {
  CreateCustomOrganizationChildResponse(
      {required this.status, required this.msg, required this.data});

  int status;
  String msg;
  Data? data;
  factory CreateCustomOrganizationChildResponse.fromJson(
      Map<String, dynamic> json) {
    print(json);
    return _$CreateCustomOrganizationChildResponseFromJson(json);
  }

  Map<String, dynamic> toJson() =>
      _$CreateCustomOrganizationChildResponseToJson(this);
}

@JsonSerializable()
class Data {
  Data({
    required this.townhall_id,
  });

  int townhall_id;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
