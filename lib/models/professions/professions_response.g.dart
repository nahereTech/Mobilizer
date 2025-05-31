// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfessionResponse _$ProfessionResponseFromJson(Map<String, dynamic> json) =>
    ProfessionResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => ProfessionData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProfessionResponseToJson(ProfessionResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

ProfessionData _$ProfessionDataFromJson(Map<String, dynamic> json) =>
    ProfessionData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ProfessionDataToJson(ProfessionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
