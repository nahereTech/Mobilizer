import 'package:json_annotation/json_annotation.dart';
part 'update_organization_banner_response.g.dart';

@JsonSerializable()
class UpdateOrganizationBannerResponse {
  UpdateOrganizationBannerResponse(
      {required this.status, required this.msg, this.data});

  int status;
  String msg;
  Data? data;

  factory UpdateOrganizationBannerResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$UpdateOrganizationBannerResponseFromJson(json);
  }

  Map<String, dynamic> toJson() =>
      _$UpdateOrganizationBannerResponseToJson(this);
}

@JsonSerializable()
class Data {
  Data({
    required this.bgimage,
  });

  String bgimage;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
