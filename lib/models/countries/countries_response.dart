import 'package:json_annotation/json_annotation.dart';

part 'countries_response.g.dart';

@JsonSerializable()
class CountriesResponse {
  CountriesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  int status;
  String message;
  List<CountriesData> data;

  factory CountriesResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$CountriesResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CountriesResponseToJson(this);
}

@JsonSerializable()
class CountriesData {
  CountriesData({
    required this.country_id,
    required this.country_name,
  });

  int country_id;
  String country_name;

  factory CountriesData.fromJson(Map<String, dynamic> json) =>
      _$CountriesDataFromJson(json);

  Map<String, dynamic> toJson() => _$CountriesDataToJson(this);
}
