import 'package:json_annotation/json_annotation.dart';

part 'follow_response.g.dart';

@JsonSerializable()
class FollowResponse {
  FollowResponse({
    required this.status,
    required this.msg,
  });

  String status;
  String msg;

  factory FollowResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$FollowResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FollowResponseToJson(this);
}
