import 'package:json_annotation/json_annotation.dart';
part 'verify_followed_response.g.dart';

@JsonSerializable()
class GetVerifyFollowedResponse {
  GetVerifyFollowedResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  String status;
  String msg;
  FollowData? data;

  factory GetVerifyFollowedResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$GetVerifyFollowedResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GetVerifyFollowedResponseToJson(this);
}

@JsonSerializable()
class FollowData {
  FollowData({
    required this.isFollowed,
  });

  String isFollowed;

  factory FollowData.fromJson(Map<String, dynamic> json) =>
      _$FollowDataFromJson(json);

  Map<String, dynamic> toJson() => _$FollowDataToJson(this);
}
