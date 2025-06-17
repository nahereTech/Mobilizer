import 'package:json_annotation/json_annotation.dart';

part 'delete_feed_response.g.dart';

@JsonSerializable()
class DeleteFeedResponse {
  DeleteFeedResponse({
    required this.status,
    required this.msg,
  });

  int status;
  String msg;

  factory DeleteFeedResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteFeedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteFeedResponseToJson(this);
}
