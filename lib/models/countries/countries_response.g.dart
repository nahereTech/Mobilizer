// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countries_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountriesResponse _$CountriesResponseFromJson(Map<String, dynamic> json) =>
    CountriesResponse(
      status: (json['status'] as num).toInt(),
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => CountriesData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CountriesResponseToJson(CountriesResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

CountriesData _$CountriesDataFromJson(Map<String, dynamic> json) =>
    CountriesData(
      country_id: (json['country_id'] as num).toInt(),
      country_name: json['country_name'] as String,
    );

Map<String, dynamic> _$CountriesDataToJson(CountriesData instance) =>
    <String, dynamic>{
      'country_id': instance.country_id,
      'country_name': instance.country_name,
    };
