import 'package:json_annotation/json_annotation.dart';
part 'followers_count_response.g.dart';

@JsonSerializable()
class FollowersResponseCount {
  FollowersResponseCount({
    required this.status,
    required this.msg,
    required this.count,
  });

  String status;
  String msg;
  int count;

  factory FollowersResponseCount.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$FollowersResponseCountFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FollowersResponseCountToJson(this);
}
