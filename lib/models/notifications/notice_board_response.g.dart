// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_board_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeBoardResponse _$NoticeBoardResponseFromJson(Map<String, dynamic> json) =>
    NoticeBoardResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NoticeBoardResponseToJson(
        NoticeBoardResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      message: json['message'] as String,
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'message': instance.message,
    };
