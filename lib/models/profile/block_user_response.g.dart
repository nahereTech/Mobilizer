// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockUserResponse _$BlockUserResponseFromJson(Map<String, dynamic> json) =>
    BlockUserResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$BlockUserResponseToJson(BlockUserResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
