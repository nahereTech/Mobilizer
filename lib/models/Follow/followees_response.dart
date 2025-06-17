import 'package:json_annotation/json_annotation.dart';
part 'followees_response.g.dart';

@JsonSerializable()
class FolloweesResponse {
  FolloweesResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  String status;
  String msg;
  List<FolloweesData>? data;

  factory FolloweesResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    return _$FolloweesResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FolloweesResponseToJson(this);
}

@JsonSerializable()
class FolloweesData {
  FolloweesData(
      {this.username,
      this.followeeID,
      this.followeePics,
      this.photo_path,
      this.followeeName,
      this.state_name,
      this.lga_name,
      this.followeeProfession,
      this.isFollowing,
      this.total});

  dynamic username;
  dynamic followeeID;
  dynamic followeePics;
  dynamic photo_path;
  dynamic followeeName;
  dynamic state_name;
  dynamic lga_name;
  dynamic followeeProfession;
  dynamic isFollowing;
  dynamic total;

  factory FolloweesData.fromJson(Map<String, dynamic> json) =>
      _$FolloweesDataFromJson(json);

  Map<String, dynamic> toJson() => _$FolloweesDataToJson(this);
}
