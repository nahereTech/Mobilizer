// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_comments_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCommentsRequest _$CreateCommentsRequestFromJson(
        Map<String, dynamic> json) =>
    CreateCommentsRequest(
      party_townhall: json['party_townhall'] as String,
      post_id: json['post_id'] as String,
      message: json['message'] as String,
      group: json['group'] as String,
      org_id: json['org_id'] as String,
      parent_id: json['parent_id'] as String,
    );

Map<String, dynamic> _$CreateCommentsRequestToJson(
        CreateCommentsRequest instance) =>
    <String, dynamic>{
      'post_id': instance.post_id,
      'message': instance.message,
      'party_townhall': instance.party_townhall,
      'group': instance.group,
      'org_id': instance.org_id,
      'parent_id': instance.parent_id,
    };
