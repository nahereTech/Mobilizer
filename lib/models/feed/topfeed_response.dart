import 'package:json_annotation/json_annotation.dart';

part 'topfeed_response.g.dart';

@JsonSerializable()
class TopFeedResponse {
  TopFeedResponse({
    required this.status,
    required this.msg,
    this.tag,
    this.show_townhalls_on_top = false,
    this.data,
  });

  dynamic status;
  dynamic msg;
  String? tag;
  bool show_townhalls_on_top;
  List<TopFeedData>? data;

  factory TopFeedResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$TopFeedResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TopFeedResponseToJson(this);
}

@JsonSerializable()
class TopFeedData {
  TopFeedData({
    this.townhall_id,
    this.townhall_name,
    this.townhall_type,
    this.state_id,
    this.state_name,
    this.federal_constituency_id,
    this.senatorial_zone_id,
    this.lga_id,
    this.ward_id,
    this.state_const_id,
    this.country_id,
    this.country_name,
    this.reps_id,
    this.townhall_suffix,
    this.rep_fullnames,
    this.rep_picture,
    this.rep_picture_mid,
    this.townhall_display_name,
    this.townhall_full_name,
    this.entry_message,
    this.org_id,
    this.can_post,
    this.can_post_polls,
    this.can_show_townhall_info,
    this.show_result_button,
    this.is_townhall_leader,
    this.member_count,
    required this.circle_reduction_percentage,
    required this.unread,
  });

  dynamic townhall_id;
  dynamic townhall_name;
  dynamic townhall_type;
  dynamic state_id;
  dynamic state_name;
  dynamic federal_constituency_id;
  dynamic senatorial_zone_id;
  dynamic lga_id;
  dynamic ward_id;
  dynamic state_const_id;
  dynamic country_id;
  dynamic country_name;
  dynamic reps_id;
  dynamic townhall_suffix;
  dynamic rep_fullnames;
  dynamic rep_picture;
  dynamic rep_picture_mid;
  dynamic townhall_display_name;
  dynamic townhall_full_name;
  dynamic entry_message;
  dynamic can_post;
  dynamic can_post_polls;
  dynamic org_id;
  dynamic can_show_townhall_info;
  dynamic show_result_button;
  dynamic is_townhall_leader;
  dynamic member_count;
  dynamic circle_reduction_percentage;
  int unread = 0;

  factory TopFeedData.fromJson(Map<String, dynamic> json) =>
      _$TopFeedDataFromJson(json);

  Map<String, dynamic> toJson() => _$TopFeedDataToJson(this);
}
