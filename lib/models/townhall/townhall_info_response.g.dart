// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'townhall_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TownhallInfoResponse _$TownhallInfoResponseFromJson(
        Map<String, dynamic> json) =>
    TownhallInfoResponse(
      status: (json['status'] as num).toInt(),
      msg: json['msg'] as String?,
      data: (json['data'] as List<dynamic>)
          .map((e) => InfoData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TownhallInfoResponseToJson(
        TownhallInfoResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

InfoData _$InfoDataFromJson(Map<String, dynamic> json) => InfoData(
      section: json['section'],
      section_tag: json['section_tag'] as String?,
      orientation: json['orientation'] as String?,
      action_type: json['action_type'] as String?,
      section_id: json['section_id'],
      body: (json['body'] as List<dynamic>?)
          ?.map((e) => BodyData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InfoDataToJson(InfoData instance) => <String, dynamic>{
      'section': instance.section,
      'orientation': instance.orientation,
      'section_tag': instance.section_tag,
      'action_type': instance.action_type,
      'section_id': instance.section_id,
      'body': instance.body,
    };

BodyData _$BodyDataFromJson(Map<String, dynamic> json) => BodyData(
      image: json['image'],
      body: json['body'],
      link: json['link'],
      audio: json['audio'],
      is_this_a_more: json['is_this_a_more'],
      last_shown_id: json['last_shown_id'],
      show_follow: json['show_follow'],
      user_id: json['user_id'],
      action_type: json['action_type'] as String?,
    );

Map<String, dynamic> _$BodyDataToJson(BodyData instance) => <String, dynamic>{
      'image': instance.image,
      'body': instance.body,
      'link': instance.link,
      'audio': instance.audio,
      'is_this_a_more': instance.is_this_a_more,
      'last_shown_id': instance.last_shown_id,
      'show_follow': instance.show_follow,
      'user_id': instance.user_id,
      'action_type': instance.action_type,
    };
