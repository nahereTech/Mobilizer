// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_types_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventTypesResponse _$EventTypesResponseFromJson(Map<String, dynamic> json) =>
    EventTypesResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => TypeData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EventTypesResponseToJson(EventTypesResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

TypeData _$TypeDataFromJson(Map<String, dynamic> json) => TypeData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$TypeDataToJson(TypeData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
