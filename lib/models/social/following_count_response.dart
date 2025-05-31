import 'package:json_annotation/json_annotation.dart';
part 'following_count_response.g.dart';

@JsonSerializable()
class FollowingResponseCount {
  FollowingResponseCount({
    required this.status,
    required this.msg,
    required this.count,
  });

  String status;
  String msg;
  int count;

  factory FollowingResponseCount.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$FollowingResponseCountFromJson(json);
  }
  Map<String, dynamic> toJson() => _$FollowingResponseCountToJson(this);
}
