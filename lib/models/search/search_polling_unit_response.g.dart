// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_polling_unit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchPollingUnitResponse _$SearchPollingUnitResponseFromJson(
        Map<String, dynamic> json) =>
    SearchPollingUnitResponse(
      status: (json['status'] as num).toInt(),
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => PollingData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchPollingUnitResponseToJson(
        SearchPollingUnitResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

PollingData _$PollingDataFromJson(Map<String, dynamic> json) => PollingData(
      id: json['id'],
      pu_name: json['pu_name'],
      pu_official_id: json['pu_official_id'],
      pu_ward_id: json['pu_ward_id'],
    );

Map<String, dynamic> _$PollingDataToJson(PollingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pu_name': instance.pu_name,
      'pu_official_id': instance.pu_official_id,
      'pu_ward_id': instance.pu_ward_id,
    };
