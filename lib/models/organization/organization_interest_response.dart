import 'package:json_annotation/json_annotation.dart';
part 'organization_interest_response.g.dart';

@JsonSerializable()
class OrganizationInterestResponse {
  OrganizationInterestResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<InterestData> data;

  factory OrganizationInterestResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$OrganizationInterestResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrganizationInterestResponseToJson(this);
}

@JsonSerializable()
class InterestData {
  InterestData({
    required this.id,
    required this.name,
  });
  int id;
  String name;

  factory InterestData.fromJson(Map<String, dynamic> json) =>
      _$InterestDataFromJson(json);

  Map<String, dynamic> toJson() => _$InterestDataToJson(this);
}
