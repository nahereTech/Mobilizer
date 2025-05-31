// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topfeed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopFeedResponse _$TopFeedResponseFromJson(Map<String, dynamic> json) =>
    TopFeedResponse(
      status: json['status'],
      msg: json['msg'],
      tag: json['tag'] as String?,
      show_townhalls_on_top: json['show_townhalls_on_top'] as bool? ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TopFeedData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TopFeedResponseToJson(TopFeedResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'tag': instance.tag,
      'show_townhalls_on_top': instance.show_townhalls_on_top,
      'data': instance.data,
    };

TopFeedData _$TopFeedDataFromJson(Map<String, dynamic> json) => TopFeedData(
      townhall_id: json['townhall_id'],
      townhall_name: json['townhall_name'],
      townhall_type: json['townhall_type'],
      state_id: json['state_id'],
      state_name: json['state_name'],
      federal_constituency_id: json['federal_constituency_id'],
      senatorial_zone_id: json['senatorial_zone_id'],
      lga_id: json['lga_id'],
      ward_id: json['ward_id'],
      state_const_id: json['state_const_id'],
      country_id: json['country_id'],
      country_name: json['country_name'],
      reps_id: json['reps_id'],
      townhall_suffix: json['townhall_suffix'],
      rep_fullnames: json['rep_fullnames'],
      rep_picture: json['rep_picture'],
      rep_picture_mid: json['rep_picture_mid'],
      townhall_display_name: json['townhall_display_name'],
      townhall_full_name: json['townhall_full_name'],
      entry_message: json['entry_message'],
      org_id: json['org_id'],
      can_post: json['can_post'],
      can_post_polls: json['can_post_polls'],
      can_show_townhall_info: json['can_show_townhall_info'],
      show_result_button: json['show_result_button'],
      is_townhall_leader: json['is_townhall_leader'],
      member_count: json['member_count'],
      circle_reduction_percentage: json['circle_reduction_percentage'],
      unread: (json['unread'] as num).toInt(),
    );

Map<String, dynamic> _$TopFeedDataToJson(TopFeedData instance) =>
    <String, dynamic>{
      'townhall_id': instance.townhall_id,
      'townhall_name': instance.townhall_name,
      'townhall_type': instance.townhall_type,
      'state_id': instance.state_id,
      'state_name': instance.state_name,
      'federal_constituency_id': instance.federal_constituency_id,
      'senatorial_zone_id': instance.senatorial_zone_id,
      'lga_id': instance.lga_id,
      'ward_id': instance.ward_id,
      'state_const_id': instance.state_const_id,
      'country_id': instance.country_id,
      'country_name': instance.country_name,
      'reps_id': instance.reps_id,
      'townhall_suffix': instance.townhall_suffix,
      'rep_fullnames': instance.rep_fullnames,
      'rep_picture': instance.rep_picture,
      'rep_picture_mid': instance.rep_picture_mid,
      'townhall_display_name': instance.townhall_display_name,
      'townhall_full_name': instance.townhall_full_name,
      'entry_message': instance.entry_message,
      'can_post': instance.can_post,
      'can_post_polls': instance.can_post_polls,
      'org_id': instance.org_id,
      'can_show_townhall_info': instance.can_show_townhall_info,
      'show_result_button': instance.show_result_button,
      'is_townhall_leader': instance.is_townhall_leader,
      'member_count': instance.member_count,
      'circle_reduction_percentage': instance.circle_reduction_percentage,
      'unread': instance.unread,
    };
