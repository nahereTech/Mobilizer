// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_available_twh_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DefaultAvailableTWHResponse _$DefaultAvailableTWHResponseFromJson(
        Map<String, dynamic> json) =>
    DefaultAvailableTWHResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => AvailableData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DefaultAvailableTWHResponseToJson(
        DefaultAvailableTWHResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

AvailableData _$AvailableDataFromJson(Map<String, dynamic> json) =>
    AvailableData(
      name: json['name'] as String,
      pic: json['pic'] as String?,
      is_checked: json['is_checked'] as bool,
      circle_reduction_percentage:
          (json['circle_reduction_percentage'] as num).toInt(),
    );

Map<String, dynamic> _$AvailableDataToJson(AvailableData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pic': instance.pic,
      'is_checked': instance.is_checked,
      'circle_reduction_percentage': instance.circle_reduction_percentage,
    };
