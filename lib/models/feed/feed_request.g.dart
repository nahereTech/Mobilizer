// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedRequest _$FeedRequestFromJson(Map<String, dynamic> json) => FeedRequest(
      isFirstFeedRequest: json['isFirstFeedRequest'] as bool,
      skipOnboarding: json['skipOnboarding'] as bool,
      skipTopFeed: json['skipTopFeed'] as bool,
      group_id: json['group_id'],
      org_id: json['org_id'],
      page: json['page'],
      townhall_tap: json['townhall_tap'] as bool,
      limit: json['limit'],
      older_or_newer: json['older_or_newer'],
      last_post_id: json['last_post_id'],
      page_owner: json['page_owner'],
      device_token: json['device_token'],
      device_type: json['device_type'],
    );

Map<String, dynamic> _$FeedRequestToJson(FeedRequest instance) =>
    <String, dynamic>{
      'isFirstFeedRequest': instance.isFirstFeedRequest,
      'skipOnboarding': instance.skipOnboarding,
      'skipTopFeed': instance.skipTopFeed,
      'townhall_tap': instance.townhall_tap,
      'group_id': instance.group_id,
      'org_id': instance.org_id,
      'limit': instance.limit,
      'page': instance.page,
      'older_or_newer': instance.older_or_newer,
      'last_post_id': instance.last_post_id,
      'page_owner': instance.page_owner,
      'device_token': instance.device_token,
      'device_type': instance.device_type,
    };
