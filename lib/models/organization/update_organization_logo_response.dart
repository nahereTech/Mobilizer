import 'package:json_annotation/json_annotation.dart';
part 'update_organization_logo_response.g.dart';

@JsonSerializable()
class UpdateOrganizationLogoResponse {
  UpdateOrganizationLogoResponse({
    required this.status,
    required this.msg,
    this.data,
  });

  int status;
  String msg;
  Data? data;

  factory UpdateOrganizationLogoResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$UpdateOrganizationLogoResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UpdateOrganizationLogoResponseToJson(this);
}

@JsonSerializable()
class Data {
  Data({
    required this.logoimage,
  });

  String logoimage;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
