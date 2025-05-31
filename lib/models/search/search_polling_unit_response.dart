import 'package:json_annotation/json_annotation.dart';
part 'search_polling_unit_response.g.dart';

@JsonSerializable()
class SearchPollingUnitResponse {
  SearchPollingUnitResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  int status;
  String message;
  List<PollingData> data;

  factory SearchPollingUnitResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$SearchPollingUnitResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchPollingUnitResponseToJson(this);
}

@JsonSerializable()
class PollingData {
  PollingData({
    required this.id,
    required this.pu_name,
    required this.pu_official_id,
    required this.pu_ward_id,
  });
  dynamic id;
  dynamic pu_name;
  dynamic pu_official_id;
  dynamic pu_ward_id;

  factory PollingData.fromJson(Map<String, dynamic> json) =>
      _$PollingDataFromJson(json);

  Map<String, dynamic> toJson() => _$PollingDataToJson(this);
}
