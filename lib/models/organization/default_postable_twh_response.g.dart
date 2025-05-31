// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_postable_twh_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DefaultPostableTWHResponse _$DefaultPostableTWHResponseFromJson(
        Map<String, dynamic> json) =>
    DefaultPostableTWHResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => PostableData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DefaultPostableTWHResponseToJson(
        DefaultPostableTWHResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

PostableData _$PostableDataFromJson(Map<String, dynamic> json) => PostableData(
      name: json['name'] as String,
      pic: json['pic'] as String?,
      is_checked: json['is_checked'] as bool,
      circle_reduction_percentage:
          (json['circle_reduction_percentage'] as num).toInt(),
    );

Map<String, dynamic> _$PostableDataToJson(PostableData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pic': instance.pic,
      'is_checked': instance.is_checked,
      'circle_reduction_percentage': instance.circle_reduction_percentage,
    };
