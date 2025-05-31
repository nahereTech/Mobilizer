// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_abuse_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportAbuseResponse _$ReportAbuseResponseFromJson(Map<String, dynamic> json) =>
    ReportAbuseResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$ReportAbuseResponseToJson(
        ReportAbuseResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
