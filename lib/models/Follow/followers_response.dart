import 'package:json_annotation/json_annotation.dart';
part 'followers_response.g.dart';

@JsonSerializable()
class FollowersResponse {
  FollowersResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  String status;
  String msg;
  List<FollowersData>? data;

  factory FollowersResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$FollowersResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FollowersResponseToJson(this);
}

@JsonSerializable()
class FollowersData {
  FollowersData(
      {this.username,
      this.followerID,
      this.followerPics,
      this.photo_path,
      this.followerName,
      this.state_name,
      this.lga_name,
      this.followerProfession,
      this.amFollowing,
      this.total});

  dynamic username;
  dynamic followerID;
  dynamic followerPics;
  dynamic photo_path;
  dynamic followerName;
  dynamic state_name;
  dynamic lga_name;
  dynamic followerProfession;
  dynamic amFollowing;
  dynamic total;

  factory FollowersData.fromJson(Map<String, dynamic> json) =>
      _$FollowersDataFromJson(json);

  Map<String, dynamic> toJson() => _$FollowersDataToJson(this);
}
