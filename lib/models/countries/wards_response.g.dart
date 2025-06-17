// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wards_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WardsResponse _$WardsResponseFromJson(Map<String, dynamic> json) =>
    WardsResponse(
      status: (json['status'] as num).toInt(),
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => WardData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WardsResponseToJson(WardsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

WardData _$WardDataFromJson(Map<String, dynamic> json) => WardData(
      id: (json['id'] as num).toInt(),
      ward_name: json['ward_name'] as String,
    );

Map<String, dynamic> _$WardDataToJson(WardData instance) => <String, dynamic>{
      'id': instance.id,
      'ward_name': instance.ward_name,
    };
