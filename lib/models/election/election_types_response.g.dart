// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'election_types_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElectionTypesResponse _$ElectionTypesResponseFromJson(
        Map<String, dynamic> json) =>
    ElectionTypesResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => TypesData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ElectionTypesResponseToJson(
        ElectionTypesResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

TypesData _$TypesDataFromJson(Map<String, dynamic> json) => TypesData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$TypesDataToJson(TypesData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
