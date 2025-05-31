import 'package:json_annotation/json_annotation.dart';
part 'create_custom_organization_temp_response.g.dart';

@JsonSerializable()
class CreateCustomOrganizationTempResponse {
  CreateCustomOrganizationTempResponse(
      {required this.status, required this.msg, required this.data});

  int status;
  String msg;
  Data data;

  factory CreateCustomOrganizationTempResponse.fromJson(
      Map<String, dynamic> json) {
    print("json");
    return _$CreateCustomOrganizationTempResponseFromJson(json);
  }

  Map<String, dynamic> toJson() =>
      _$CreateCustomOrganizationTempResponseToJson(this);
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
