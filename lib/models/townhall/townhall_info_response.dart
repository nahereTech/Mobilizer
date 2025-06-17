import 'package:json_annotation/json_annotation.dart';
part 'townhall_info_response.g.dart';

@JsonSerializable()
class TownhallInfoResponse {
  TownhallInfoResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String? msg;
  List<InfoData> data;

  factory TownhallInfoResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$TownhallInfoResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TownhallInfoResponseToJson(this);
}

@JsonSerializable()
class InfoData {
  InfoData({
    this.section,
    this.section_tag,
    this.orientation, //landscape or portrait
    this.action_type, //audio or view
    this.section_id,
    this.body,
  });

  dynamic section;
  String? orientation;
  String? section_tag;
  String? action_type;
  dynamic section_id;
  List<BodyData>? body;

  factory InfoData.fromJson(Map<String, dynamic> json) =>
      _$InfoDataFromJson(json);

  Map<String, dynamic> toJson() => _$InfoDataToJson(this);
}

@JsonSerializable()
class BodyData {
  BodyData(
      {this.image,
      this.body,
      this.link,
      this.audio,
      this.is_this_a_more,
      this.last_shown_id,
      this.show_follow,
      this.user_id,
      this.action_type});

  dynamic image;
  dynamic body;
  dynamic link;
  dynamic audio;
  dynamic is_this_a_more;
  dynamic last_shown_id;
  dynamic show_follow;
  dynamic user_id;
  String? action_type;
  factory BodyData.fromJson(Map<String, dynamic> json) =>
      _$BodyDataFromJson(json);

  Map<String, dynamic> toJson() => _$BodyDataToJson(this);
}
