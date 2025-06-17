// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TermResponse _$TermResponseFromJson(Map<String, dynamic> json) => TermResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : TermData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TermResponseToJson(TermResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

TermData _$TermDataFromJson(Map<String, dynamic> json) => TermData(
      terms: json['terms'] as String,
    );

Map<String, dynamic> _$TermDataToJson(TermData instance) => <String, dynamic>{
      'terms': instance.terms,
    };
