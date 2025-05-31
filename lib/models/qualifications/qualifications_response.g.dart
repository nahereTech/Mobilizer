// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qualifications_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QualificationResponse _$QualificationResponseFromJson(
        Map<String, dynamic> json) =>
    QualificationResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => QualificationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QualificationResponseToJson(
        QualificationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

QualificationData _$QualificationDataFromJson(Map<String, dynamic> json) =>
    QualificationData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$QualificationDataToJson(QualificationData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
