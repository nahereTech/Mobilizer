import 'package:json_annotation/json_annotation.dart';

part 'feed_request.g.dart';

@JsonSerializable()
class FeedRequest {
  FeedRequest(
      {required this.isFirstFeedRequest,
      required this.skipOnboarding,
      required this.skipTopFeed,
      this.group_id,
      this.org_id,
      this.page,
      required this.townhall_tap,
      this.limit,
      this.older_or_newer,
      this.last_post_id,
      this.page_owner,
      this.device_token,
      this.device_type});

  bool isFirstFeedRequest;
  bool skipOnboarding;
  bool skipTopFeed;
  bool townhall_tap;
  dynamic group_id;
  dynamic org_id;
  dynamic limit;
  dynamic page;
  dynamic older_or_newer;
  dynamic last_post_id;
  dynamic page_owner;
  dynamic device_token;
  dynamic device_type;

  factory FeedRequest.fromJson(Map<String, dynamic> json) =>
      _$FeedRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FeedRequestToJson(this);
}
