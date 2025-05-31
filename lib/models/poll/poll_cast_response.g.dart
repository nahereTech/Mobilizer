// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_cast_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollCastResponse _$PollCastResponseFromJson(Map<String, dynamic> json) =>
    PollCastResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String,
      data: PollData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PollCastResponseToJson(PollCastResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

PollData _$PollDataFromJson(Map<String, dynamic> json) => PollData(
      post_id: json['post_id'],
      user_option: json['user_option'] as String,
    );

Map<String, dynamic> _$PollDataToJson(PollData instance) => <String, dynamic>{
      'post_id': instance.post_id,
      'user_option': instance.user_option,
    };
