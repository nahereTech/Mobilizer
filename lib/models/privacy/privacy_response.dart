import 'package:json_annotation/json_annotation.dart';
part 'privacy_response.g.dart';

@JsonSerializable()
class PrivacyResponse {
  PrivacyResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  PrivacyData? data;

  factory PrivacyResponse.fromJson(Map<String, dynamic> json) {
    //print(json);
    return _$PrivacyResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PrivacyResponseToJson(this);
}

@JsonSerializable()
class PrivacyData {
  PrivacyData({
    required this.privacy,
  });

  String privacy;

  factory PrivacyData.fromJson(Map<String, dynamic> json) =>
      _$PrivacyDataFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacyDataToJson(this);
}
