// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_townhalls_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsersTownhallsResponse _$UsersTownhallsResponseFromJson(
        Map<String, dynamic> json) =>
    UsersTownhallsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => DataList.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UsersTownhallsResponseToJson(
        UsersTownhallsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

DataList _$DataListFromJson(Map<String, dynamic> json) => DataList(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$DataListToJson(DataList instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
