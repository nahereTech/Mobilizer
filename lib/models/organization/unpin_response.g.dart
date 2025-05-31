// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unpin_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnpinResponse _$UnpinResponseFromJson(Map<String, dynamic> json) =>
    UnpinResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$UnpinResponseToJson(UnpinResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
