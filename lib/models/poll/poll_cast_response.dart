import 'package:json_annotation/json_annotation.dart';
part 'poll_cast_response.g.dart';

@JsonSerializable()
class PollCastResponse {
  PollCastResponse(
      {required this.status, required this.msg, required this.data});
  int status;
  String msg;
  PollData data;

  factory PollCastResponse.fromJson(Map<String, dynamic> json) =>
      _$PollCastResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PollCastResponseToJson(this);
}

@JsonSerializable()
class PollData {
  PollData({required this.post_id, required this.user_option});

  dynamic post_id;
  String user_option;

  factory PollData.fromJson(Map<String, dynamic> json) =>
      _$PollDataFromJson(json);

  Map<String, dynamic> toJson() => _$PollDataToJson(this);
}
