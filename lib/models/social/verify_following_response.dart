import 'package:json_annotation/json_annotation.dart';

part 'verify_following_response.g.dart';

@JsonSerializable()
class VerifyFollowingResponse {
  VerifyFollowingResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  String status;
  String msg;
  List<FollowingData> data;

  factory VerifyFollowingResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyFollowingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyFollowingResponseToJson(this);
}

@JsonSerializable()
class FollowingData {
  FollowingData({
    this.isFollowing,
  });

  String? isFollowing;

  factory FollowingData.fromJson(Map<String, dynamic> json) =>
      _$FollowingDataFromJson(json);

  Map<String, dynamic> toJson() => _$FollowingDataToJson(this);
}
