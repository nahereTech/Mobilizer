import 'package:json_annotation/json_annotation.dart';
part 'verify_following_response.g.dart';

@JsonSerializable()
class GetVerifyFollowingResponse {
  GetVerifyFollowingResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  String status;
  String msg;
  FollowData? data;

  factory GetVerifyFollowingResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$GetVerifyFollowingResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetVerifyFollowingResponseToJson(this);
}

@JsonSerializable()
class FollowData {
  FollowData({
    required this.isFollowing,
  });

  String isFollowing;

  factory FollowData.fromJson(Map<String, dynamic> json) =>
      _$FollowDataFromJson(json);

  Map<String, dynamic> toJson() => _$FollowDataToJson(this);
}
