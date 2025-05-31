// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_users_townhalls_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUsersTownhallsResponse _$UpdateUsersTownhallsResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateUsersTownhallsResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$UpdateUsersTownhallsResponseToJson(
        UpdateUsersTownhallsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
