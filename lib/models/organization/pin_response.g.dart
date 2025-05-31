// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PinResponse _$PinResponseFromJson(Map<String, dynamic> json) => PinResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$PinResponseToJson(PinResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
    };
