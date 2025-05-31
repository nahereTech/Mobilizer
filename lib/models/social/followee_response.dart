import 'package:json_annotation/json_annotation.dart';
part 'followee_response.g.dart';

@JsonSerializable()
class FolloweeResponse {
  FolloweeResponse({
    required this.status,
    required this.msg,
    required this.total_rows,
    required this.data,
  });

  int status;
  String msg;
  int total_rows;
  List<FolloweeData>? data;

  factory FolloweeResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$FolloweeResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FolloweeResponseToJson(this);
}

@JsonSerializable()
class FolloweeData {
  FolloweeData({
    this.followeeID,
    this.followeePics,
    this.photo_path,
    this.followeeName,
    this.followeeProfession,
    this.isFollowing,
  });

  String? followeeID;
  String? followeePics;
  String? photo_path;
  String? followeeName;
  String? followeeProfession;
  String? isFollowing;

  factory FolloweeData.fromJson(Map<String, dynamic> json) =>
      _$FolloweeDataFromJson(json);

  Map<String, dynamic> toJson() => _$FolloweeDataToJson(this);
}
