// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LikeResponse _$LikeResponseFromJson(Map<String, dynamic> json) => LikeResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$LikeResponseToJson(LikeResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
