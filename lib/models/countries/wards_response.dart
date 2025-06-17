import 'package:json_annotation/json_annotation.dart';

part 'wards_response.g.dart';

@JsonSerializable()
class WardsResponse {
  WardsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  int status;
  String message;
  List<WardData> data;

  factory WardsResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$WardsResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$WardsResponseToJson(this);
}

@JsonSerializable()
class WardData {
  WardData({
    required this.id,
    required this.ward_name,
  });

  int id;
  String ward_name;

  factory WardData.fromJson(Map<String, dynamic> json) =>
      _$WardDataFromJson(json);

  Map<String, dynamic> toJson() => _$WardDataToJson(this);
}
