// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_result_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostResultResponse _$PostResultResponseFromJson(Map<String, dynamic> json) =>
    PostResultResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$PostResultResponseToJson(PostResultResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
